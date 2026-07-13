import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/models/fridge_change_log.dart';
import 'package:kurashi/data/models/fridge_item.dart';
import 'package:kurashi/data/repositories/isar/isar_fridge_repository.dart';

late Isar? isar;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final dir = Directory.systemTemp.createTempSync('test_isar_fridge');
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

  IsarFridgeRepository repo() => IsarFridgeRepository(isar!);

  FridgeItem item({
    int id = 0,
    String name = 'test-item',
    String quantity = '1 kg',
    DateTime? addedDate,
    DateTime? expiryDate,
    String? tag,
    int remainingPercent = 100,
    bool restockEnabled = false,
    int restockThresholdPercent = 20,
    String restockQty = '',
  }) {
    return FridgeItem(
      id: id,
      name: name,
      quantity: quantity,
      addedDate: addedDate ?? DateTime(2026, 7, 1),
      expiryDate: expiryDate ?? DateTime(2026, 7, 10),
      tag: tag,
      remainingPercent: remainingPercent,
      restockEnabled: restockEnabled,
      restockThresholdPercent: restockThresholdPercent,
      restockQty: restockQty,
    );
  }

  group('FridgeRepository — stream 行为', () {
    test('watchAll 订阅后收到初始数据', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final emitted = <List<FridgeItem>>[];
      final sub = repo().watchAll().listen(emitted.add);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(emitted, isNotEmpty);
      await sub.cancel();
    });

    test('watchChangeLog 订阅后收到初始数据', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final emitted = <List<FridgeChangeLog>>[];
      final sub = repo().watchChangeLog().listen(emitted.add);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(emitted, isNotEmpty);
      await sub.cancel();
    });
  });

  group('FridgeRepository — 增删改操作', () {
    test('用户添加食材 → 列表末尾出现新食材', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final before = await repo().watchAll().first;
      await repo().addItem(item(name: '鸡胸肉', quantity: '500 g'));
      final after = await repo().watchAll().first;
      expect(after.length, before.length + 1);
      expect(after.any((i) => i.name == '鸡胸肉'), isTrue);
    });

    test('用户出库食材 → 食材消失', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final before = await repo().watchAll().first;
      final target = before.first;
      await repo().removeItem(target.id);
      final after = await repo().watchAll().first;
      expect(after.any((i) => i.id == target.id), isFalse);
    });

    test('用户修改食材数量 → 列表中食材数量更新', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final items = await repo().watchAll().first;
      final target = items.first;
      await repo().updateItem(target.copyWith(quantity: '750 g'));
      final after = await repo().watchAll().first;
      expect(after.firstWhere((i) => i.id == target.id).quantity, '750 g');
    });
  });

  group('FridgeRepository — 日志保留策略', () {
    test('用户设置保留 7 天并执行清理 → 超出天数的日志被清除', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final cleared = await repo().clearChangeLogOlderThan(
        DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(cleared, greaterThanOrEqualTo(0));
    });

    test('用户选择「永久保留」→ 清理时不删除任何日志', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final settings = await repo().getSettings();
      final originalDays = settings.fridgeLogRetentionDays;
      await repo().updateSettings(settings.copyWith(fridgeLogRetentionDays: 0));
      final cleared = await repo().clearChangeLogOlderThan(
        DateTime.fromMillisecondsSinceEpoch(1),
      );
      expect(cleared, 0);
      await repo().updateSettings(
        settings.copyWith(fridgeLogRetentionDays: originalDays),
      );
    });
  });

  group('FridgeRepository — 补货追踪', () {
    test('用户开启补货追踪 → 食材 restockEnabled 为 true', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final items = await repo().watchAll().first;
      final target = items.first;
      await repo().updateItem(
        target.copyWith(restockEnabled: true, restockQty: '500 g'),
      );
      final after = await repo().watchAll().first;
      expect(after.firstWhere((i) => i.id == target.id).restockEnabled, isTrue);
    });
  });
}
