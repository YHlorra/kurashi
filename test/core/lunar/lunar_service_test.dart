import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/core/lunar/festival_presets.dart';
import 'package:kurashi/core/lunar/lunar_service.dart';
import 'package:kurashi/data/models/subscription.dart';

void main() {
  const service = LunarService();

  group('LunarService.nextTriggerDate - user behavior', () {
    test('user sets National Day reminder, sees it this year', () {
      final sub = Subscription(
        title: 'National Day', type: SubType.cnFestival, calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly, anchorMonth: 10, anchorDay: 1,
        leadDays: 0, active: true, createdAt: DateTime(2026, 1, 1),
      );
      final result = service.nextTriggerDate(sub, today: DateTime(2026, 7, 2));
      expect(result, DateTime(2026, 10, 1));
    });

    test('user sets New Year reminder in December, sees it next year', () {
      final sub = Subscription(
        title: 'New Year', type: SubType.cnFestival, calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly, anchorMonth: 1, anchorDay: 1,
        leadDays: 0, active: true, createdAt: DateTime(2026, 1, 1),
      );
      final result = service.nextTriggerDate(sub, today: DateTime(2026, 12, 31));
      expect(result, DateTime(2027, 1, 1));
    });

    test('user on the exact trigger date sees next years date', () {
      final sub = Subscription(
        title: 'National Day', type: SubType.cnFestival, calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly, anchorMonth: 10, anchorDay: 1,
        leadDays: 0, active: true, createdAt: DateTime(2026, 1, 1),
      );
      final result = service.nextTriggerDate(sub, today: DateTime(2026, 10, 1));
      expect(result, DateTime(2027, 10, 1));
    });

    test('user sets Spring Festival, gets next lunar new year', () {
      final sub = Subscription(
        title: 'Spring Festival', type: SubType.cnFestival, calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly, anchorMonth: 1, anchorDay: 1,
        leadDays: 0, active: true, createdAt: DateTime(2026, 1, 1),
      );
      final result = service.nextTriggerDate(sub, today: DateTime(2026, 7, 2));
      expect(result.year, 2027);
      expect(result.month, 2);
    });

    test('user sets 30-day rolling reminder, gets next future date', () {
      final sub = Subscription(
        title: 'Water filter', type: SubType.homeMaintenance, calendar: Calendar.solar,
        mode: TriggerMode.intervalDays, intervalDays: 30, leadDays: 7,
        active: true, createdAt: DateTime(2026, 6, 1),
      );
      final result = service.nextTriggerDate(sub, today: DateTime(2026, 7, 2));
      expect(result, DateTime(2026, 7, 31));
    });

    test('Qingming falls in April 4-6', () {
      for (int year = 2024; year <= 2028; year++) {
        final date = service.nextSpecialFestivalDate(SpecialFestivalType.qingming, year);
        expect(date.year, year);
        expect(date.month, 4);
        expect(date.day, inInclusiveRange(4, 6));
      }
    });

    test("Mother's Day = 2nd Sunday of May", () {
      for (int year = 2024; year <= 2028; year++) {
        final date = service.nextSpecialFestivalDate(SpecialFestivalType.mothersDay, year);
        expect(date.weekday, DateTime.sunday);
        expect(date.day, inInclusiveRange(8, 14));
      }
    });

    test('solarToLunar: 2026-02-17 is Spring Festival', () {
      final lunar = service.solarToLunar(DateTime(2026, 2, 17));
      expect(lunar.month, 1);
      expect(lunar.day, 1);
    });

    test('lunarToSolar: lunar new year 2026 = 2026-02-17', () {
      final solar = service.lunarToSolar(2026, 1, 1, false);
      expect(solar.year, 2026);
      expect(solar.month, 2);
      expect(solar.day, 17);
    });
  });

  group('LunarService.daysUntil - behavior', () {
    test('National Day from July 2 = 91 days', () {
      final sub = Subscription(
        title: 'National Day', type: SubType.cnFestival, calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly, anchorMonth: 10, anchorDay: 1,
        leadDays: 0, active: true, createdAt: DateTime(2026, 1, 1),
      );
      expect(service.daysUntil(sub, today: DateTime(2026, 7, 2)), 91);
    });
  });
}
