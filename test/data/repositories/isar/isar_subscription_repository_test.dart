import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/models/subscription.dart';
import 'package:kurashi/data/repositories/isar/isar_subscription_repository.dart';

late Isar? isar;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final dir = Directory.systemTemp.createTempSync('test_isar_sub');
      isar = Isar.open(schemas: schemas, directory: dir.path);
    } catch (_) {
      isar = null;
    }
  });
  tearDownAll(() {
    isar?.close();
    try {
      if (isar != null)
        Directory('${isar!.directory}').deleteSync(recursive: true);
    } catch (_) {}
  });

  group('SubscriptionRepository — 用户行为', () {
    test('用户订阅新账单 → 列表出现该订阅', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarSubscriptionRepository(isar!);
      final before = await repo.watchAll().first;
      await repo.addSubscription(
        Subscription(
          title: 'New Bill',
          type: SubType.bill,
          calendar: Calendar.solar,
          mode: TriggerMode.anchorMonthly,
          anchorDay: 15,
          leadDays: 1,
          active: true,
          createdAt: DateTime.now(),
        ),
      );
      final after = await repo.watchAll().first;
      expect(after.length, before.length + 1);
      expect(after.any((s) => s.title == 'New Bill'), isTrue);
    });

    test('用户删除订阅 → 订阅消失', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarSubscriptionRepository(isar!);
      final before = await repo.watchAll().first;
      final id = before.first.id;
      await repo.deleteSubscription(id);
      final after = await repo.watchAll().first;
      expect(after.any((s) => s.id == id), isFalse);
    });

    test('用户激活节日整类 → 该类所有订阅变为 active', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      // ensure db ready
      final repo = IsarSubscriptionRepository(isar!);
      await repo.setActiveByType(SubType.cnFestival, true);
      final subs = await repo.watchAll().first;
      final festivals = subs
          .where((s) => s.type == SubType.cnFestival)
          .toList();
      expect(festivals, isNotEmpty);
      expect(festivals.every((s) => s.active), isTrue);
    });

    test('用户停用节日整类 → 该类所有订阅变为 inactive', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarSubscriptionRepository(isar!);
      await repo.setActiveByType(SubType.cnFestival, false);
      final subs = await repo.watchAll().first;
      final festivals = subs
          .where((s) => s.type == SubType.cnFestival)
          .toList();
      expect(festivals.every((s) => !s.active), isTrue);
    });
  });
}
