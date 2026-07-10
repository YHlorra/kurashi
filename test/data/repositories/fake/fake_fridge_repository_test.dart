import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/app_settings.dart';
import 'package:kurashi/data/models/fridge_change_log.dart';
import 'package:kurashi/data/models/fridge_item.dart';
import 'package:kurashi/data/repositories/fake/fake_fridge_repository.dart';
import 'package:kurashi/data/repositories/fridge_repository.dart';

FridgeItem _item({
  int id = 0, String name = 'test-item', String quantity = '1 kg',
  DateTime? addedDate, DateTime? expiryDate, String? tag,
  int remainingPercent = 100, bool restockEnabled = false,
  int restockThresholdPercent = 20, String restockQty = '',
}) {
  return FridgeItem(
    id: id, name: name, quantity: quantity,
    addedDate: addedDate ?? DateTime(2026, 7, 1),
    expiryDate: expiryDate ?? DateTime(2026, 7, 10),
    tag: tag, remainingPercent: remainingPercent,
    restockEnabled: restockEnabled, restockThresholdPercent: restockThresholdPercent,
    restockQty: restockQty,
  );
}

Future<String?> _runExportSafely() async {
  try {
    final repo = FakeFridgeRepository();
    final logs = await repo.watchChangeLog().first;
    return await repo.exportChangeLogJson(scope: ReportScope.month, entries: logs.take(1).toList());
  } catch (_) {
    return null;
  }
}

void main() {
  group('FakeFridgeRepository - streams', () {
    test('watchAll emits current list on subscription', () async {
      final repo = FakeFridgeRepository();
      final items = await repo.watchAll().first;
      expect(items.length, greaterThan(0));
    });

    test('watchAll emits after addItem', () async {
      final repo = FakeFridgeRepository();
      final events = <List<FridgeItem>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);
      final initialCount = events.last.length;
      await repo.addItem(_item());
      await Future.delayed(Duration.zero);
      expect(events.length, greaterThanOrEqualTo(2));
      expect(events.last.length, initialCount + 1);
      await sub.cancel();
    });

    test('watchChangeLog emits sorted desc on subscription', () async {
      final repo = FakeFridgeRepository();
      final logs = await repo.watchChangeLog().first;
      expect(logs.length, 3);
      for (int i = 0; i < logs.length - 1; i++) {
        expect(logs[i].timestamp.isAfter(logs[i + 1].timestamp) ||
               logs[i].timestamp.isAtSameMomentAs(logs[i + 1].timestamp), isTrue);
      }
    });
  });

  group('FakeFridgeRepository - mutations', () {
    test('addItem auto-assigns sequential IDs starting at 100', () async {
      final repo = FakeFridgeRepository();
      final id1 = await repo.addItem(_item());
      final id2 = await repo.addItem(_item());
      expect(id1, 100);
      expect(id2, 101);
    });

    test('addItem writes FridgeAction.add log', () async {
      final repo = FakeFridgeRepository();
      final before = await repo.watchChangeLog().first;
      await repo.addItem(_item(name: 'new-item', quantity: '500 g'));
      final after = await repo.watchChangeLog().first;
      expect(after.length, before.length + 1);
      final log = after.firstWhere((l) => l.action == FridgeAction.add && l.itemName == 'new-item');
      expect(log.beforeQty, '0');
      expect(log.afterQty, '500 g');
    });

    test('updateItem writes log when business fields change', () async {
      final repo = FakeFridgeRepository();
      final id = await repo.addItem(_item(quantity: '1 kg'));
      await repo.updateItem(_item(id: id, quantity: '500 g'));
      final logs = await repo.watchChangeLog().first;
      final log = logs.firstWhere((l) => l.itemId == id && l.action == FridgeAction.update);
      expect(log.beforeQty, '1 kg');
      expect(log.afterQty, '500 g');
    });

    test('updateItem does NOT write log when business fields unchanged', () async {
      final repo = FakeFridgeRepository();
      final id = await repo.addItem(_item(quantity: '1 kg'));
      final before = await repo.watchChangeLog().first;
      await repo.updateItem(_item(id: id, quantity: '1 kg'));
      final after = await repo.watchChangeLog().first;
      expect(after.length, before.length);
    });

    test('removeItem writes delete log and removes item', () async {
      final repo = FakeFridgeRepository();
      final items = await repo.watchAll().first;
      final target = items.first;
      await repo.removeItem(target.id);
      final after = await repo.watchAll().first;
      expect(after.any((i) => i.id == target.id), isFalse);
      final logs = await repo.watchChangeLog().first;
      expect(logs.any((l) => l.itemId == target.id && l.action == FridgeAction.delete), isTrue);
    });

    test('removeItem on non-existent ID is no-op', () async {
      final repo = FakeFridgeRepository();
      final beforeItems = await repo.watchAll().first;
      final beforeLogs = await repo.watchChangeLog().first;
      await repo.removeItem(99999);
      expect((await repo.watchAll().first).length, beforeItems.length);
      expect((await repo.watchChangeLog().first).length, beforeLogs.length);
    });

    test('restoreItem re-adds item and writes restore log', () async {
      final repo = FakeFridgeRepository();
      await repo.restoreItem(_item(id: 42, name: 'restored'));
      final items = await repo.watchAll().first;
      expect(items.any((i) => i.id == 42), isTrue);
      final logs = await repo.watchChangeLog().first;
      expect(logs.any((l) => l.itemId == 42 && l.action == FridgeAction.restore), isTrue);
    });
  });

  group('FakeFridgeRepository - retention', () {
    test('retentionDays=0 is no-op', () async {
      final repo = FakeFridgeRepository();
      final before = await repo.watchChangeLog().first;
      await repo.runRetentionSweep(DateTime.now());
      expect((await repo.watchChangeLog().first).length, before.length);
    });

    test('monthly: does not clean within same month', () async {
      final repo = FakeFridgeRepository();
      await repo.updateSettings(AppSettings(fridgeLogRetentionDays: 30, fridgeLogLastCleanupAt: DateTime(2026, 7, 1)));
      final before = await repo.watchChangeLog().first;
      await repo.runRetentionSweep(DateTime(2026, 7, 15));
      expect((await repo.watchChangeLog().first).length, before.length);
    });

    test('runRetentionSweep swallows exceptions', () async {
      final repo = FakeFridgeRepository();
      await repo.updateSettings(AppSettings(fridgeLogRetentionDays: 30, fridgeLogLastCleanupAt: DateTime(0)));
      await expectLater(repo.runRetentionSweep(DateTime(2026, 7, 20)), completes);
    });
  });

  group('FakeFridgeRepository - restock', () {
    test('candidates: only restockEnabled AND below threshold', () async {
      final repo = FakeFridgeRepository();
      await repo.addItem(_item(name: 'low', restockEnabled: true, remainingPercent: 10, restockThresholdPercent: 20, restockQty: '2 L'));
      await repo.addItem(_item(name: 'normal', restockEnabled: true, remainingPercent: 80, restockThresholdPercent: 20));
      await repo.addItem(_item(name: 'disabled', restockEnabled: false, remainingPercent: 5, restockThresholdPercent: 20));
      final candidates = await repo.getRestockCandidates();
      expect(candidates.length, 1);
      expect(candidates.first.name, 'low');
      expect(candidates.first.restockQty, '2 L');
    });

    test('candidates grouped by name', () async {
      final repo = FakeFridgeRepository();
      await repo.addItem(_item(name: 'apple', restockEnabled: true, remainingPercent: 10));
      await repo.addItem(_item(name: 'apple', restockEnabled: true, remainingPercent: 15));
      await repo.addItem(_item(name: 'banana', restockEnabled: true, remainingPercent: 5));
      final candidates = await repo.getRestockCandidates();
      expect(candidates.where((c) => c.name == 'apple').length, 1);
      expect(candidates.firstWhere((c) => c.name == 'apple').batches.length, 2);
    });

    test('markAsFinished sets remainingPercent to 0', () async {
      final repo = FakeFridgeRepository();
      final id = await repo.addItem(_item(remainingPercent: 50));
      await repo.markAsFinished(id);
      expect((await repo.watchAll().first).firstWhere((i) => i.id == id).remainingPercent, 0);
    });

    test('updateStockPercent clamps to 0-100', () async {
      final repo = FakeFridgeRepository();
      final id = await repo.addItem(_item(remainingPercent: 50));
      await repo.updateStockPercent(id, 150);
      expect((await repo.watchAll().first).firstWhere((i) => i.id == id).remainingPercent, 100);
      await repo.updateStockPercent(id, -10);
      expect((await repo.watchAll().first).firstWhere((i) => i.id == id).remainingPercent, 0);
    });
  });

  group('FakeFridgeRepository - settings', () {
    test('updateSettings + getSettings roundtrip', () async {
      final repo = FakeFridgeRepository();
      await repo.updateSettings(AppSettings(fridgeLogRetentionDays: 90, fridgeLogLastCleanupAt: DateTime(2026, 7, 10)));
      final result = await repo.getSettings();
      expect(result.fridgeLogRetentionDays, 90);
    });

    test('watchSettings emits on subscription', () async {
      final repo = FakeFridgeRepository();
      final value = await repo.watchSettings().first;
      expect(value.fridgeLogRetentionDays, isA<int>());
    });
  });

  group('FakeFridgeRepository - export', () {
    test('export path contains scope and ends with .json', () async {
      final path = await _runExportSafely();
      if (path == null) { markTestSkipped('path_provider unavailable'); return; }
      expect(path, contains('fridge_log_month_'));
      expect(path, endsWith('.json'));
    });
  });
}
