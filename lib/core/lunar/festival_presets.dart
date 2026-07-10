import '../../data/models/subscription.dart';

/// 特殊节日类型（非固定月日，需特殊计算）。
///
/// 清明为节气（约 4/4-4/6），由 lunar 包的 JieQi 表计算；
/// 母亲节/父亲节/感恩节为"第 N 个周 X"模式，由 lunar_service 内部用 DateTime 计算。
enum SpecialFestivalType {
  qingming, // 清明：节气，约 4/4-4/6
  mothersDay, // 母亲节：5 月第 2 个周日
  fathersDay, // 父亲节：6 月第 3 个周日
  thanksgiving, // 感恩节：11 月第 4 个周四
}

/// 节日预设条目。
///
/// 用于 [Subscription] 的预设化：节日 [SubType.cnFestival] / [SubType.westernFestival]
/// 通过 `setActiveByType(true)` 批量生成 Subscription 记录（Task 9）。
///
/// 设计：
/// - 固定月日节日（如国庆 10/1、春节农历 1/1）填 [anchorMonth] / [anchorDay]，
///   [specialType] 为 null。
/// - 特殊节日（清明/母亲节/父亲节/感恩节）[anchorMonth] / [anchorDay] 留空，
///   [specialType] 标记类型，由 lunar_service.nextTriggerDate 识别并特殊计算。
class FestivalPreset {
  final String title;
  final SubType type;
  final Calendar calendar;
  final TriggerMode mode;
  final int? anchorMonth;
  final int? anchorDay;
  final int leadDays;
  final SpecialFestivalType? specialType;

  const FestivalPreset({
    required this.title,
    required this.type,
    required this.calendar,
    required this.mode,
    this.anchorMonth,
    this.anchorDay,
    this.leadDays = 7,
    this.specialType,
  });

  FestivalPreset copyWith({
    String? title,
    SubType? type,
    Calendar? calendar,
    TriggerMode? mode,
    int? anchorMonth,
    int? anchorDay,
    int? leadDays,
    SpecialFestivalType? specialType,
  }) {
    return FestivalPreset(
      title: title ?? this.title,
      type: type ?? this.type,
      calendar: calendar ?? this.calendar,
      mode: mode ?? this.mode,
      anchorMonth: anchorMonth ?? this.anchorMonth,
      anchorDay: anchorDay ?? this.anchorDay,
      leadDays: leadDays ?? this.leadDays,
      specialType: specialType ?? this.specialType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FestivalPreset &&
        other.title == title &&
        other.type == type &&
        other.calendar == calendar &&
        other.mode == mode &&
        other.anchorMonth == anchorMonth &&
        other.anchorDay == anchorDay &&
        other.leadDays == leadDays &&
        other.specialType == specialType;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      type,
      calendar,
      mode,
      anchorMonth,
      anchorDay,
      leadDays,
      specialType,
    );
  }
}

/// 中国节日预设（9 项）。
///
/// 对照设计图：元旦/春节/元宵/清明/端午/七夕/中秋/国庆/腊八。
/// - 公历：元旦 1/1、国庆 10/1
/// - 农历：春节 1/1、元宵 1/15、端午 5/5、七夕 7/7、中秋 8/15、腊八 12/8
/// - 节气：清明（specialType=qingming，约 4/4-4/6）
const List<FestivalPreset> cnFestivalPresets = [
  FestivalPreset(
    title: '元旦',
    type: SubType.cnFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 1,
    anchorDay: 1,
  ),
  FestivalPreset(
    title: '春节',
    type: SubType.cnFestival,
    calendar: Calendar.lunar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 1,
    anchorDay: 1,
  ),
  FestivalPreset(
    title: '元宵节',
    type: SubType.cnFestival,
    calendar: Calendar.lunar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 1,
    anchorDay: 15,
  ),
  FestivalPreset(
    title: '清明节',
    type: SubType.cnFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    specialType: SpecialFestivalType.qingming,
  ),
  FestivalPreset(
    title: '端午节',
    type: SubType.cnFestival,
    calendar: Calendar.lunar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 5,
    anchorDay: 5,
  ),
  FestivalPreset(
    title: '七夕',
    type: SubType.cnFestival,
    calendar: Calendar.lunar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 7,
    anchorDay: 7,
  ),
  FestivalPreset(
    title: '中秋节',
    type: SubType.cnFestival,
    calendar: Calendar.lunar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 8,
    anchorDay: 15,
  ),
  FestivalPreset(
    title: '国庆节',
    type: SubType.cnFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 10,
    anchorDay: 1,
  ),
  FestivalPreset(
    title: '腊八节',
    type: SubType.cnFestival,
    calendar: Calendar.lunar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 12,
    anchorDay: 8,
  ),
];

/// 西方节日预设（6 项）。
///
/// 对照设计图：情人节/母亲节/父亲节/万圣节/感恩节/圣诞节。
/// - 公历固定：情人节 2/14、万圣节 10/31、圣诞节 12/25
/// - "第 N 个周 X"：母亲节（5 月第 2 个周日）、父亲节（6 月第 3 个周日）、感恩节（11 月第 4 个周四）
const List<FestivalPreset> westernFestivalPresets = [
  FestivalPreset(
    title: '情人节',
    type: SubType.westernFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 2,
    anchorDay: 14,
  ),
  FestivalPreset(
    title: '母亲节',
    type: SubType.westernFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    specialType: SpecialFestivalType.mothersDay,
  ),
  FestivalPreset(
    title: '父亲节',
    type: SubType.westernFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    specialType: SpecialFestivalType.fathersDay,
  ),
  FestivalPreset(
    title: '万圣节',
    type: SubType.westernFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 10,
    anchorDay: 31,
  ),
  FestivalPreset(
    title: '感恩节',
    type: SubType.westernFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    specialType: SpecialFestivalType.thanksgiving,
  ),
  FestivalPreset(
    title: '圣诞节',
    type: SubType.westernFestival,
    calendar: Calendar.solar,
    mode: TriggerMode.anchorMonthly,
    anchorMonth: 12,
    anchorDay: 25,
  ),
];

/// 按 [SubType] 返回对应的节日预设列表。
///
/// - [SubType.cnFestival] → [cnFestivalPresets]（9 项）
/// - [SubType.westernFestival] → [westernFestivalPresets]（6 项）
/// - 其它 type 返回空列表（生日/还款/自定义无预设）。
List<FestivalPreset> presetsByType(SubType type) {
  switch (type) {
    case SubType.cnFestival:
      return cnFestivalPresets;
    case SubType.westernFestival:
      return westernFestivalPresets;
    case SubType.birthday:
    case SubType.bill:
    case SubType.custom:
    case SubType.homeMaintenance:
    case SubType.petCare:
    case SubType.document:
    case SubType.healthCheck:
    case SubType.vehicle:
      return const [];
  }
}
