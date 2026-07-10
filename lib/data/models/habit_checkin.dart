import 'package:isar_plus/isar_plus.dart';

part 'habit_checkin.g.dart';

/// 习惯打卡记录数据模型
///
/// 阶段 2.1：迁移为 isar_plus @collection。
/// 通过 `habitId` 字段关联 Habit（不用 IsarLinks，简化），并加索引加速查询。
@collection
class HabitCheckin {
  final int id;

  @index
  final int habitId;

  final DateTime date;

  const HabitCheckin({
    this.id = 0,
    required this.habitId,
    required this.date,
  });

  HabitCheckin copyWith({
    int? id,
    int? habitId,
    DateTime? date,
  }) {
    return HabitCheckin(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCheckin &&
        other.id == id &&
        other.habitId == habitId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(id, habitId, date);
  }
}
