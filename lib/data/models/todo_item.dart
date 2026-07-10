import 'package:isar_plus/isar_plus.dart';

part 'todo_item.g.dart';

/// 待办事项数据模型
///
/// 阶段 2.1：迁移为 isar_plus @collection。
/// id 字段默认 0 表示"未分配"，IsarXxxRepository.addTodo 时
/// 用 `isar.todoItems.autoIncrement()` 分配实际 id 后再 put。
@collection
class TodoItem {
  final int id;

  final String title;
  final String? tag;
  final DateTime? dueDate;
  final int? dueTimeMinutes;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;

  const TodoItem({
    this.id = 0,
    required this.title,
    this.tag,
    this.dueDate,
    this.dueTimeMinutes,
    this.completed = false,
    this.completedAt,
    required this.createdAt,
  });

  TodoItem copyWith({
    int? id,
    String? title,
    String? tag,
    DateTime? dueDate,
    int? dueTimeMinutes,
    bool? completed,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      dueDate: dueDate ?? this.dueDate,
      dueTimeMinutes: dueTimeMinutes ?? this.dueTimeMinutes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem &&
        other.id == id &&
        other.title == title &&
        other.tag == tag &&
        other.dueDate == dueDate &&
        other.dueTimeMinutes == dueTimeMinutes &&
        other.completed == completed &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      tag,
      dueDate,
      dueTimeMinutes,
      completed,
      completedAt,
      createdAt,
    );
  }
}
