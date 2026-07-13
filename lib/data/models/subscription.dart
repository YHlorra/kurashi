import 'package:isar_plus/isar_plus.dart';

part 'subscription.g.dart';

/// 订阅类型枚举
enum SubType {
  cnFestival, // 中国节日
  westernFestival, // 西方节日
  birthday, // 生日/纪念日
  bill, // 还款/财务
  custom, // 自定义
  // --- new: append only, never insert before ---
  homeMaintenance, // 家居维护
  petCare, // 宠物
  document, // 证件
  healthCheck, // 健康
  vehicle, // 车辆
}

/// 历法枚举
enum Calendar {
  solar, // 公历
  lunar, // 农历
}

/// 触发模式枚举
enum TriggerMode {
  anchorMonthly, // 按月锚点（每月几号）
  intervalDays, // 按间隔天数
}

/// 订阅数据模型
///
/// 阶段 2.1：迁移为 isar_plus @collection。
/// isar_plus 自动检测枚举类型，默认按枚举 index（byte）序列化，
/// 无需 @Enumerated 注解；新增枚举值追加到末尾即可保持向后兼容。
@collection
class Subscription {
  final int id;

  final String title;
  final SubType type;
  final Calendar calendar;
  final TriggerMode mode;
  final int? anchorMonth;
  final int? anchorDay;
  final int? intervalDays;
  final int leadDays;
  final bool active;
  final bool
  isPack; // true=one-time pack (festivals), false=multi-instance (birthday/pet/doc/...)
  final DateTime createdAt;

  const Subscription({
    this.id = 0,
    required this.title,
    required this.type,
    required this.calendar,
    required this.mode,
    this.anchorMonth,
    this.anchorDay,
    this.intervalDays,
    required this.leadDays,
    this.active = true,
    this.isPack = false,
    required this.createdAt,
  });

  Subscription copyWith({
    int? id,
    String? title,
    SubType? type,
    Calendar? calendar,
    TriggerMode? mode,
    int? anchorMonth,
    int? anchorDay,
    int? intervalDays,
    int? leadDays,
    bool? active,
    bool? isPack,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      calendar: calendar ?? this.calendar,
      mode: mode ?? this.mode,
      anchorMonth: anchorMonth ?? this.anchorMonth,
      anchorDay: anchorDay ?? this.anchorDay,
      intervalDays: intervalDays ?? this.intervalDays,
      leadDays: leadDays ?? this.leadDays,
      active: active ?? this.active,
      isPack: isPack ?? this.isPack,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.calendar == calendar &&
        other.mode == mode &&
        other.anchorMonth == anchorMonth &&
        other.anchorDay == anchorDay &&
        other.intervalDays == intervalDays &&
        other.leadDays == leadDays &&
        other.active == active &&
        other.isPack == isPack &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      type,
      calendar,
      mode,
      anchorMonth,
      anchorDay,
      intervalDays,
      leadDays,
      active,
      isPack,
      createdAt,
    );
  }
}
