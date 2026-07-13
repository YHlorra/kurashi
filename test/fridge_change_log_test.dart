import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/fridge_change_log.dart';

void main() {
  group('FridgeChangeLog model', () {
    final base = FridgeChangeLog(
      id: 1,
      itemId: 10,
      itemName: 'Item',
      timestamp: DateTime(2026, 7, 5, 14, 30),
      action: FridgeAction.add,
      beforeQty: '0',
      afterQty: '1 L',
      beforeExpiry: DateTime(2026, 7, 1),
      afterExpiry: DateTime(2026, 7, 10),
    );

    test('fields are correctly assigned', () {
      expect(base.id, 1);
      expect(base.itemId, 10);
      expect(base.action, FridgeAction.add);
      expect(base.beforeQty, '0');
      expect(base.afterQty, '1 L');
    });

    test('default id is 0', () {
      final log = FridgeChangeLog(
        itemId: 1,
        itemName: 'test',
        timestamp: DateTime.now(),
        action: FridgeAction.add,
        beforeQty: '0',
        afterQty: '1',
        beforeExpiry: DateTime.now(),
        afterExpiry: DateTime.now(),
      );
      expect(log.id, 0);
    });

    test('all FridgeAction enum values exist', () {
      expect(FridgeAction.values.length, 4);
    });

    test('enum index is stable (Isar serialization)', () {
      expect(FridgeAction.add.index, 0);
      expect(FridgeAction.update.index, 1);
      expect(FridgeAction.delete.index, 2);
      expect(FridgeAction.restore.index, 3);
    });

    test('action name is accessible', () {
      expect(FridgeAction.add.name, 'add');
      expect(FridgeAction.delete.name, 'delete');
    });

    test('timestamp preserves time components', () {
      final ts = DateTime(2026, 7, 5, 14, 30, 45);
      final log = FridgeChangeLog(
        itemId: 1,
        itemName: 'test',
        timestamp: ts,
        action: FridgeAction.add,
        beforeQty: '0',
        afterQty: '1',
        beforeExpiry: DateTime.now(),
        afterExpiry: DateTime.now(),
      );
      expect(log.timestamp.hour, 14);
      expect(log.timestamp.minute, 30);
      expect(log.timestamp.second, 45);
    });

    test('itemId survives deletion (for history display)', () {
      final log = FridgeChangeLog(
        id: 42,
        itemId: 999,
        itemName: 'deleted',
        timestamp: DateTime.now(),
        action: FridgeAction.delete,
        beforeQty: '1',
        afterQty: '0',
        beforeExpiry: DateTime.now(),
        afterExpiry: DateTime.now(),
      );
      expect(log.itemId, 999);
    });
  });
}
