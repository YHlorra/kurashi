import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/fridge_item.dart';

void main() {
  group('FridgeItem.hasBusinessChange', () {
    final base = FridgeItem(
      id: 1,
      name: 'milk',
      quantity: '1 L',
      addedDate: DateTime(2026, 7, 1),
      expiryDate: DateTime(2026, 7, 10),
      tag: 'veg',
      remainingPercent: 100,
      restockEnabled: false,
      restockThresholdPercent: 20,
      restockQty: '1 L',
    );

    test(
      'false when only id differs',
      () => expect(base.hasBusinessChange(base.copyWith(id: 999)), isFalse),
    );
    test(
      'false when only addedDate differs',
      () => expect(
        base.hasBusinessChange(base.copyWith(addedDate: DateTime(2027, 1, 1))),
        isFalse,
      ),
    );
    test(
      'false when all fields identical',
      () => expect(base.hasBusinessChange(base.copyWith()), isFalse),
    );
    test(
      'true when name changes',
      () => expect(base.hasBusinessChange(base.copyWith(name: 'soy')), isTrue),
    );
    test(
      'true when quantity changes',
      () => expect(
        base.hasBusinessChange(base.copyWith(quantity: '500 ml')),
        isTrue,
      ),
    );
    test(
      'true when expiryDate changes',
      () => expect(
        base.hasBusinessChange(base.copyWith(expiryDate: DateTime(2026, 8, 1))),
        isTrue,
      ),
    );
    test(
      'true when tag changes',
      () => expect(base.hasBusinessChange(base.copyWith(tag: 'meat')), isTrue),
    );
    test(
      'true when remainingPercent changes',
      () => expect(
        base.hasBusinessChange(base.copyWith(remainingPercent: 50)),
        isTrue,
      ),
    );
    test(
      'true when restockEnabled changes',
      () => expect(
        base.hasBusinessChange(base.copyWith(restockEnabled: true)),
        isTrue,
      ),
    );
    test(
      'true when restockThresholdPercent changes',
      () => expect(
        base.hasBusinessChange(base.copyWith(restockThresholdPercent: 30)),
        isTrue,
      ),
    );
    test(
      'true when restockQty changes',
      () => expect(
        base.hasBusinessChange(base.copyWith(restockQty: '2 L')),
        isTrue,
      ),
    );
  });

  group('FridgeItem equality', () {
    test('same fields are equal', () {
      final a = FridgeItem(
        id: 1,
        name: 't',
        quantity: '1',
        addedDate: DateTime(2026, 1, 1),
        expiryDate: DateTime(2026, 2, 1),
      );
      final b = FridgeItem(
        id: 1,
        name: 't',
        quantity: '1',
        addedDate: DateTime(2026, 1, 1),
        expiryDate: DateTime(2026, 2, 1),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different name not equal', () {
      final a = FridgeItem(
        id: 1,
        name: 'a',
        quantity: '1',
        addedDate: DateTime(2026, 1, 1),
        expiryDate: DateTime(2026, 2, 1),
      );
      final b = FridgeItem(
        id: 1,
        name: 'b',
        quantity: '1',
        addedDate: DateTime(2026, 1, 1),
        expiryDate: DateTime(2026, 2, 1),
      );
      expect(a == b, isFalse);
    });
  });
}
