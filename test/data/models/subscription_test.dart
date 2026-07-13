import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/subscription.dart';

void main() {
  group('Subscription model', () {
    final base = Subscription(
      id: 1,
      title: 'Spring Festival',
      type: SubType.cnFestival,
      calendar: Calendar.lunar,
      mode: TriggerMode.anchorMonthly,
      anchorMonth: 1,
      anchorDay: 1,
      leadDays: 0,
      active: false,
      isPack: true,
      createdAt: DateTime(2026, 7, 1),
    );

    test('copyWith preserves unchanged fields', () {
      final copy = base.copyWith(active: true);
      expect(copy.active, isTrue);
      expect(copy.title, 'Spring Festival');
    });

    test('copyWith overrides specified fields', () {
      final copy = base.copyWith(title: 'Lantern', anchorDay: 15);
      expect(copy.title, 'Lantern');
      expect(copy.anchorDay, 15);
    });

    test('equality: same fields equal', () {
      final b = Subscription(
        id: 1,
        title: 'Spring Festival',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 1,
        anchorDay: 1,
        leadDays: 0,
        active: false,
        isPack: true,
        createdAt: DateTime(2026, 7, 1),
      );
      expect(base, b);
      expect(base.hashCode, b.hashCode);
    });

    test('inequality: different title', () {
      expect(base == base.copyWith(title: 'Yuanxiao'), isFalse);
    });

    test('all SubType values exist', () => expect(SubType.values.length, 10));
    test('all Calendar values exist', () => expect(Calendar.values.length, 2));
    test(
      'all TriggerMode values exist',
      () => expect(TriggerMode.values.length, 2),
    );
  });
}
