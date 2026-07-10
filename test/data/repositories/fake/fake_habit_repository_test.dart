// FakeHabitRepository 单测（Task 1.2）
//
// 覆盖 4 个核心场景：
//   1.2.a addHabit：新增后 watchAll 含它
//   1.2.b checkin：写入 HabitCheckin，watchCheckinsFor 返回含指定日
//   1.2.c uncheckin：撤销指定日 checkin，watchCheckinsFor 不含指定日
//   1.2.d 同日重复 checkin：第二次不写入（幂等）
//
// 约定：
// - mock 数据 weekStart = 2026-06-29（周一），habit 1 已在 6/29、6/30 打卡
// - 测试用 2026-07-02（周四）作为打卡日，避开已有 checkin
// - Fake 是同步内存实现，watchCheckinsFor 通过 Future.microtask 推送
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/habit.dart';
import 'package:kurashi/data/repositories/fake/fake_habit_repository.dart';

void main() {
  late FakeHabitRepository repo;

  setUp(() {
    repo = FakeHabitRepository();
  });

  // mock 数据 weekStart（2026-06-29 周一），与 FakeHabitRepository._createMockCheckins 一致
  // DateTime 非 const 构造，用 final
  final weekStart = DateTime(2026, 6, 29);
  // 2026-07-02 周四，在 mock 周内且 habit 1 当日无 checkin
  final checkinDate = DateTime(2026, 7, 2);

  group('FakeHabitRepository', () {
    // ── 1.2.a addHabit：新增后 watchAll 含它 ──────────────────────────
    test('addHabit：新增后 watchAll 含它', () async {
      final habit = Habit(
        title: '冥想 10 分钟',
        frequencyPerWeek: 5,
        reminderTime: const TimeOfDay(hour: 7, minute: 30),
        createdAt: DateTime(2026, 7, 6),
      );
      final id = await repo.addHabit(habit);

      final list = await repo.watchAll().first;
      expect(list.any((h) => h.id == id), isTrue);
      expect(list.firstWhere((h) => h.id == id).title, '冥想 10 分钟');
    });

    // ── 1.2.b checkin：写入 HabitCheckin，watchCheckinsFor 返回含指定日 ─
    test('checkin：写入 HabitCheckin，watchCheckinsFor 返回含指定日', () async {
      await repo.checkin(1, checkinDate);

      final checkins = await repo.watchCheckinsFor(1, weekStart).first;
      expect(
        checkins.any((c) =>
            c.habitId == 1 &&
            c.date.year == checkinDate.year &&
            c.date.month == checkinDate.month &&
            c.date.day == checkinDate.day),
        isTrue,
      );
    });

    // ── 1.2.c uncheckin：撤销指定日 checkin ───────────────────────────
    test('uncheckin：撤销指定日 checkin，watchCheckinsFor 不含指定日', () async {
      // 先打卡再撤销
      await repo.checkin(1, checkinDate);
      await repo.uncheckin(1, checkinDate);

      final checkins = await repo.watchCheckinsFor(1, weekStart).first;
      expect(
        checkins.any((c) =>
            c.habitId == 1 &&
            c.date.year == checkinDate.year &&
            c.date.month == checkinDate.month &&
            c.date.day == checkinDate.day),
        isFalse,
      );
    });

    // ── 1.2.d 同日重复 checkin：第二次不写入（幂等）────────────────────
    test('同日重复 checkin：第二次不写入（幂等）', () async {
      await repo.checkin(1, checkinDate);
      await repo.checkin(1, checkinDate); // 应被忽略

      final checkins = await repo.watchCheckinsFor(1, weekStart).first;
      // 仅一条 habitId=1 + date=checkinDate 的记录（幂等不重复写入）
      final sameDayCount = checkins.where((c) =>
          c.habitId == 1 &&
          c.date.year == checkinDate.year &&
          c.date.month == checkinDate.month &&
          c.date.day == checkinDate.day).length;
      expect(sameDayCount, 1);
    });
  });
}
