import 'package:lunar/lunar.dart';

import '../../data/models/subscription.dart';
import 'festival_presets.dart';

/// 农历服务：封装 lunar 包，提供公历/农历互转 + 订阅下次触发日计算。
///
/// 所有农历相关计算集中在此服务，UI 层不直接调 lunar 包。
///
/// 节日预设（[cnFestivalPresets] / [westernFestivalPresets]）的特殊节日
/// （清明/母亲节/父亲节/感恩节）通过 [SpecialFestivalType] 标记，由
/// [nextTriggerDate] 识别并调用 [nextSpecialFestivalDate] 计算。
///
/// lunar 包 API 关键点：
/// - `Lunar.fromYmd(year, month, day)` 不接受 isLeap 参数；闰月通过月份取负值
///   编码（如 -1 = 闰正月）。本服务对外保留 isLeap 参数，内部转换。
/// - `Lunar.fromDate(DateTime)` 从公历 DateTime 创建 Lunar 对象。
/// - `Lunar.getJieQiTable()` 返回 `Map<String, Solar>`，含 '清明' 键（节气表）。
/// - `Lunar.getSolar()` 返回对应公历 Solar 对象。
class LunarService {
  const LunarService();

  /// 公历转农历。
  ///
  /// 返回的 DateTime 的 year/month/day 字段携带农历 Y/M/D（注意：非真实公历时刻，
  /// 仅作为信息载体）。闰月信息丢失（DateTime 不支持负数 month，使用 abs() 折算），
  /// 如需保留闰月标记请直接使用 [lunarToSolar] 的反向查询或 lunar 包原生 API。
  DateTime solarToLunar(DateTime solar) {
    final lunar = Lunar.fromDate(solar);
    return DateTime(lunar.getYear(), lunar.getMonth().abs(), lunar.getDay());
  }

  /// 公历日期转农历月日（仅返回月日，不保留年）。
  (int month, int day) solarToLunarMonthDay(DateTime solar) {
    final lunar = Lunar.fromDate(solar);
    return (lunar.getMonth().abs(), lunar.getDay());
  }

  /// 农历转公历。
  ///
  /// [isLeap] 为 true 表示 [month] 是闰月。lunar 包通过月份取负值编码闰月，故内部
  /// 将 [month] 取负后传给 `Lunar.fromYmd`。
  DateTime lunarToSolar(int year, int month, int day, bool isLeap) {
    final lunarMonth = isLeap ? -month : month;
    final solar = Lunar.fromYmd(year, lunarMonth, day).getSolar();
    return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
  }

  /// 计算订阅的下次触发日（从 [today] 起）。
  ///
  /// 根据 [Subscription.calendar] / [Subscription.mode] / [Subscription.anchorMonth] /
  /// [Subscription.anchorDay] / [Subscription.intervalDays] 计算从 [today]（默认
  /// DateTime.now()）起的下次触发日。
  ///
  /// 三种模式：
  /// - **solar + anchorMonthly**：今年该月日，若已过则明年。
  ///   例：国庆 10/1，今日 2026-07-02 → 2026-10-01。
  /// - **lunar + anchorMonthly**：农历今年该月日转公历，若已过则农历明年。
  ///   例：春节农历 1/1，今日 2026-07-02 → 农历 2027 年正月初一 = 2027-02-06。
  /// - **intervalDays**：从 createdAt + intervalDays 向前滚动，直到 > today。
  ///   例：intervalDays=30，createdAt=2026-06-01，today=2026-07-02 → 2026-07-31。
  ///
  /// 特殊节日（清明/母亲节/父亲节/感恩节）：通过 [Subscription.title] 匹配
  /// 节日预设表的 [FestivalPreset.specialType]，调用 [nextSpecialFestivalDate]。
  DateTime nextTriggerDate(Subscription sub, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day); // strip time

    // 特殊节日识别（清明/母亲节/父亲节/感恩节）
    final specialType = _findSpecialFestivalByTitle(sub.title);
    if (specialType != null) {
      var date = nextSpecialFestivalDate(specialType, todayDate.year);
      if (!date.isAfter(todayDate)) {
        // 今年已过，取明年
        date = nextSpecialFestivalDate(specialType, todayDate.year + 1);
      }
      return date;
    }

    switch (sub.mode) {
      case TriggerMode.anchorMonthly:
        return sub.calendar == Calendar.solar
            ? _nextSolarAnchor(sub, todayDate)
            : _nextLunarAnchor(sub, todayDate);
      case TriggerMode.intervalDays:
        return _nextInterval(sub, todayDate);
    }
  }

  /// 距离下次触发的天数（[nextTriggerDate] - today 的天数，向下取整）。
  ///
  /// 例：国庆 10/1，今日 2026-07-01 → 92；今日 2026-07-02 → 91。
  int daysUntil(Subscription sub, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final next = nextTriggerDate(sub, today: now);
    return next.difference(todayDate).inDays;
  }

  /// 计算特殊节日在 [year] 年（公历）的日期。
  ///
  /// - [SpecialFestivalType.qingming]：用 lunar 包的 JieQi 节气表计算（约 4/4-4/6）。
  /// - [SpecialFestivalType.mothersDay]：5 月第 2 个周日。
  /// - [SpecialFestivalType.fathersDay]：6 月第 3 个周日。
  /// - [SpecialFestivalType.thanksgiving]：11 月第 4 个周四。
  DateTime nextSpecialFestivalDate(SpecialFestivalType type, int year) {
    switch (type) {
      case SpecialFestivalType.qingming:
        // lunar 包的 JieQi 表覆盖整个农历年，5/1 必落在农历 year 年内（农历年从
        // 公历 1-2 月开始），故 getJieQiTable()['清明'] 即为公历 year 年的清明。
        final solar = Lunar.fromDate(
          DateTime(year, 5, 1),
        ).getJieQiTable()['清明']!;
        return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
      case SpecialFestivalType.mothersDay:
        return _nthWeekdayOfMonth(year, 5, DateTime.sunday, 2);
      case SpecialFestivalType.fathersDay:
        return _nthWeekdayOfMonth(year, 6, DateTime.sunday, 3);
      case SpecialFestivalType.thanksgiving:
        return _nthWeekdayOfMonth(year, 11, DateTime.thursday, 4);
    }
  }

  // ── 内部辅助 ──────────────────────────────────────────────────────────

  /// 在节日预设表中按 title 查找特殊节日标记。
  ///
  /// 节日 Subscription 由 setActiveByType（Task 9）从预设表批量生成，title 与
  /// 预设一致；此处通过 title 反查 [FestivalPreset.specialType] 识别特殊节日。
  SpecialFestivalType? _findSpecialFestivalByTitle(String title) {
    for (final preset in cnFestivalPresets) {
      if (preset.title == title && preset.specialType != null) {
        return preset.specialType;
      }
    }
    for (final preset in westernFestivalPresets) {
      if (preset.title == title && preset.specialType != null) {
        return preset.specialType;
      }
    }
    return null;
  }

  /// 公历月日锚点的下次触发日。
  DateTime _nextSolarAnchor(Subscription sub, DateTime todayDate) {
    var candidate = DateTime(todayDate.year, sub.anchorMonth!, sub.anchorDay!);
    if (!candidate.isAfter(todayDate)) {
      // 今年该月日已过（含今日），取明年
      candidate = DateTime(
        todayDate.year + 1,
        sub.anchorMonth!,
        sub.anchorDay!,
      );
    }
    return candidate;
  }

  /// 农历月日锚点的下次触发日。
  ///
  /// 取今日对应的农历年，构造农历该年该月日 → 公历；若已过则用农历明年再算。
  DateTime _nextLunarAnchor(Subscription sub, DateTime todayDate) {
    final lunarYear = Lunar.fromDate(todayDate).getYear();
    var candidate = lunarToSolar(
      lunarYear,
      sub.anchorMonth!,
      sub.anchorDay!,
      false,
    );
    if (!candidate.isAfter(todayDate)) {
      candidate = lunarToSolar(
        lunarYear + 1,
        sub.anchorMonth!,
        sub.anchorDay!,
        false,
      );
    }
    return candidate;
  }

  /// intervalDays 滚动模式：从 createdAt + intervalDays 向前滚动，直到 > today。
  ///
  /// 阶段 2.1 schema 锁定，Subscription 无 lastTriggerDate 字段，故用 createdAt
  /// 作为起点向前滚动（Task 11 单测会验证滚动逻辑）。
  DateTime _nextInterval(Subscription sub, DateTime todayDate) {
    final interval = sub.intervalDays!;
    var candidate = DateTime(
      sub.createdAt.year,
      sub.createdAt.month,
      sub.createdAt.day,
    );
    while (!candidate.isAfter(todayDate)) {
      candidate = candidate.add(Duration(days: interval));
    }
    return candidate;
  }

  /// 计算 [year] 年 [month] 月第 [n] 个 [weekday] 的公历日期。
  ///
  /// [weekday] 取 `DateTime.monday`..`DateTime.sunday`（1..7）。
  DateTime _nthWeekdayOfMonth(int year, int month, int weekday, int n) {
    final firstOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstOfMonth.weekday; // Monday=1 .. Sunday=7
    final offset = (weekday - firstWeekday + 7) % 7;
    return DateTime(year, month, 1 + offset + (n - 1) * 7);
  }
}

/// 全局单例，UI/Repository 通过此调用农历服务。
const lunarService = LunarService();
