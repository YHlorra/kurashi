// lunar_service 单测（Task 11）
//
// 覆盖 5 个核心场景：
//   11.1 公历节日 nextTriggerDate（国庆 10/1）
//   11.2 农历节日 nextTriggerDate（春节农历 1/1）
//   11.3 农历生日 nextTriggerDate（农历 8/8）
//   11.4 清明节气计算（特殊节日）
//   11.5 intervalDays 滚动
//
// 约定：
// - 所有 today 显式传入，不依赖系统时间
// - 农历日期期望值以 lunar ^1.7.8 实算为准，注释标注"经 lunar ^1.7.8 实算"
// - 使用全局 const lunarService 单例
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/core/lunar/lunar_service.dart';
import 'package:kurashi/data/models/subscription.dart';

void main() {
  group('lunar_service.nextTriggerDate', () {
    // ── 11.1 公历节日（国庆 10/1）──────────────────────────────────────
    group('公历节日（国庆 10/1）', () {
      test('今日 2026-07-02 → 今年国庆 2026-10-01', () {
        final sub = Subscription(
          title: '国庆节',
          type: SubType.cnFestival,
          calendar: Calendar.solar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: 10,
          anchorDay: 1,
          leadDays: 7,
          createdAt: DateTime(2026, 1, 1),
        );
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 7, 2),
        );
        expect(next, DateTime(2026, 10, 1));
      });

      test('今日 2026-10-02（今年国庆已过）→ 明年国庆 2027-10-01', () {
        final sub = Subscription(
          title: '国庆节',
          type: SubType.cnFestival,
          calendar: Calendar.solar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: 10,
          anchorDay: 1,
          leadDays: 7,
          createdAt: DateTime(2026, 1, 1),
        );
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 10, 2),
        );
        expect(next, DateTime(2027, 10, 1));
      });
    });

    // ── 11.2 农历节日（春节农历 1/1）───────────────────────────────────
    group('农历节日（春节农历 1/1）', () {
      test('今日 2026-07-02 → 农历 2027 年正月初一 = 2027-02-06', () {
        final sub = Subscription(
          title: '春节',
          type: SubType.cnFestival,
          calendar: Calendar.lunar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: 1,
          anchorDay: 1,
          leadDays: 7,
          createdAt: DateTime(2026, 1, 1),
        );
        // 农历 2026 年正月初一 = 2026-02-17（今日 2026-07-02 已过）
        // 农历 2027 年正月初一 = 2027-02-06（经 lunar ^1.7.8 实算）
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 7, 2),
        );
        expect(next, DateTime(2027, 2, 6));
      });
    });

    // ── 11.3 农历生日（农历 8/8）───────────────────────────────────────
    group('农历生日（农历 8/8）', () {
      test('今日 2026-07-02 → 农历 2026 年八月初八 = 2026-09-18', () {
        final sub = Subscription(
          title: '爸爸生日',
          type: SubType.birthday,
          calendar: Calendar.lunar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: 8,
          anchorDay: 8,
          leadDays: 7,
          createdAt: DateTime(2026, 1, 1),
        );
        // 农历 2026 年八月初八 = 2026-09-18（经 lunar ^1.7.8 实算）
        // 注：任务描述猜测为 2026-09-19，实际 lunar 包计算结果为 2026-09-18
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 7, 2),
        );
        expect(next, DateTime(2026, 9, 18));
      });
    });

    // ── 11.4 清明节气（特殊节日）──────────────────────────────────────
    group('清明节（节气，特殊节日）', () {
      test('今日 2026-01-01 → 2026 年清明 2026-04-05', () {
        final sub = Subscription(
          title: '清明节',
          type: SubType.cnFestival,
          calendar: Calendar.solar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: null,
          anchorDay: null,
          leadDays: 7,
          createdAt: DateTime(2026, 1, 1),
        );
        // 2026 年清明节气 = 2026-04-05（经 lunar ^1.7.8 实算，JieQi 表）
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 1, 1),
        );
        // 清明节气约落在 4/4-4/6，用范围断言以兼容不同年份的细微差异
        expect(next.month, 4);
        expect(next.day, inInclusiveRange(4, 6));
        // 精确值（2026 年）：2026-04-05
        expect(next, DateTime(2026, 4, 5));
      });

      test('今日 2026-07-02（今年清明已过）→ 明年清明 2027-04-05', () {
        final sub = Subscription(
          title: '清明节',
          type: SubType.cnFestival,
          calendar: Calendar.solar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: null,
          anchorDay: null,
          leadDays: 7,
          createdAt: DateTime(2026, 1, 1),
        );
        // 2027 年清明节气 = 2027-04-05（经 lunar ^1.7.8 实算）
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 7, 2),
        );
        expect(next.month, 4);
        expect(next.day, inInclusiveRange(4, 6));
        expect(next, DateTime(2027, 4, 5));
      });
    });

    // ── 11.5 intervalDays 滚动 ────────────────────────────────────────
    group('intervalDays 滚动', () {
      test('createdAt=2026-06-01, intervalDays=30, today=2026-07-02 → 2026-07-31', () {
        final sub = Subscription(
          title: '信用卡还款',
          type: SubType.bill,
          calendar: Calendar.solar,
          mode: TriggerMode.intervalDays,
          intervalDays: 30,
          leadDays: 3,
          createdAt: DateTime(2026, 6, 1),
        );
        // 滚动逻辑：
        //   2026-06-01 + 30 = 2026-07-01（<= today 2026-07-02，继续滚）
        //   2026-07-01 + 30 = 2026-07-31（> today，停止）
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 7, 2),
        );
        expect(next, DateTime(2026, 7, 31));
      });

      test('createdAt=2026-06-01, intervalDays=30, today=2026-06-01（含起止日）→ 2026-07-01', () {
        // today == createdAt 时，candidate=createdAt 不 > today，需滚动一次
        final sub = Subscription(
          title: '信用卡还款',
          type: SubType.bill,
          calendar: Calendar.solar,
          mode: TriggerMode.intervalDays,
          intervalDays: 30,
          leadDays: 3,
          createdAt: DateTime(2026, 6, 1),
        );
        final next = lunarService.nextTriggerDate(
          sub,
          today: DateTime(2026, 6, 1),
        );
        expect(next, DateTime(2026, 7, 1));
      });
    });
  });

  group('lunar_service.solarToLunarMonthDay', () {
    test('Solar 2026-03-15 → Lunar 1 月 27 日（经 lunar ^1.7.8 实算）', () {
      final (m, d) = lunarService.solarToLunarMonthDay(DateTime(2026, 3, 15));
      expect(m, 1);
      expect(d, 27);
    });
  });
}
