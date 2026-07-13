import 'package:flutter/material.dart';
import 'package:isar_plus/isar_plus.dart';

part 'habit.g.dart';

/// 习惯数据模型
///
/// 阶段 2.1：迁移为 isar_plus @collection。
/// isar_plus 不直接支持 TimeOfDay，故用 `reminderMinutes`（int?，0-1439，
/// hour*60+minute）作为存储字段；UI 通过计算属性 `reminderTime` 访问
/// TimeOfDay?，保持 lib/feature/* 零改动。
///
/// 构造函数同时接受 `reminderTime`（UI 用）和 `reminderMinutes`（isar 反序列化用），
/// 两者互斥：若 reminderTime 非 null 则用它换算，否则直接用 reminderMinutes。
/// `reminderTime` getter 用 @ignore 注解避免被 isar_plus 当作存储字段。
@collection
class Habit {
  final int id;

  final String title;
  final String? tag;
  final int frequencyPerWeek;

  /// 提醒时间存储字段：自 00:00 起的分钟数（0-1439）；null 表示无提醒。
  final int? reminderMinutes;

  final DateTime createdAt;

  Habit({
    this.id = 0,
    required this.title,
    this.tag,
    required this.frequencyPerWeek,
    TimeOfDay? reminderTime,
    int? reminderMinutes,
    required this.createdAt,
  }) : assert(
         reminderTime == null || reminderMinutes == null,
         'reminderTime 与 reminderMinutes 不可同时指定',
       ),
       reminderMinutes = reminderTime != null
           ? reminderTime.hour * 60 + reminderTime.minute
           : reminderMinutes;

  /// 运行时计算属性 —— UI 通过 habit.reminderTime 读取 TimeOfDay?，不被 Isar 存储。
  @ignore
  TimeOfDay? get reminderTime => reminderMinutes == null
      ? null
      : TimeOfDay(hour: reminderMinutes! ~/ 60, minute: reminderMinutes! % 60);

  Habit copyWith({
    int? id,
    String? title,
    String? tag,
    int? frequencyPerWeek,
    TimeOfDay? reminderTime,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      frequencyPerWeek: frequencyPerWeek ?? this.frequencyPerWeek,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.tag == tag &&
        other.frequencyPerWeek == frequencyPerWeek &&
        other.reminderMinutes == reminderMinutes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      tag,
      frequencyPerWeek,
      reminderMinutes,
      createdAt,
    );
  }
}
