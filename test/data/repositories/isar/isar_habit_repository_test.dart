import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/models/habit.dart';
import 'package:kurashi/data/repositories/isar/isar_habit_repository.dart';

late Isar? isar;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final dir = Directory.systemTemp.createTempSync('test_isar_habit');
      isar = Isar.open(schemas: schemas, directory: dir.path);
    } catch (_) {
      isar = null;
    }
  });
  tearDownAll(() {
    isar?.close();
    try { if (isar != null) Directory('${isar!.directory}').deleteSync(recursive: true); } catch (_) {}
  });

  group('HabitRepository — 用户行为', () {
    test('用户添加习惯 → 列表出现该习惯', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarHabitRepository(isar!);
      final before = await repo.watchAll().first;
      await repo.addHabit(Habit(title: 'Meditate', frequencyPerWeek: 7, createdAt: DateTime.now()));
      final after = await repo.watchAll().first;
      expect(after.length, before.length + 1);
    });

    test('用户删除习惯 → 习惯消失', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarHabitRepository(isar!);
      final before = await repo.watchAll().first;
      final targetId = before.first.id;
      await repo.deleteHabit(targetId);
      final after = await repo.watchAll().first;
      expect(after.any((h) => h.id == targetId), isFalse);
    });

    test('用户在某天打卡 → 打卡记录出现', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarHabitRepository(isar!);
      final habits = await repo.watchAll().first;
      final id = habits.first.id;
      await repo.checkin(id, DateTime(2026, 8, 3));
      final checkins = await repo.watchCheckinsFor(id, DateTime(2026, 8, 1)).first;
      expect(checkins.any((c) => c.date.day == 3), isTrue);
    });

    test('用户同天打卡两次 → 只记一次（不重复计数）', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarHabitRepository(isar!);
      final habits = await repo.watchAll().first;
      final id = habits.first.id;
      await repo.checkin(id, DateTime(2026, 8, 4));
      await repo.checkin(id, DateTime(2026, 8, 4));
      final checkins = await repo.watchCheckinsFor(id, DateTime(2026, 8, 1)).first;
      expect(checkins.where((c) => c.date.day == 4).length, 1);
    });

    test('用户取消某天打卡 → 打卡记录消失', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarHabitRepository(isar!);
      final habits = await repo.watchAll().first;
      final id = habits.first.id;
      await repo.checkin(id, DateTime(2026, 8, 5));
      await repo.uncheckin(id, DateTime(2026, 8, 5));
      final checkins = await repo.watchCheckinsFor(id, DateTime(2026, 8, 1)).first;
      expect(checkins.any((c) => c.date.day == 5), isFalse);
    });
  });
}
