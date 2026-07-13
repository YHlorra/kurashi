import '../models/todo_item.dart';

/// 待办事项仓库抽象接口
abstract class TodoRepository {
  Stream<List<TodoItem>> watchAll();

  /// 新增待办，返回分配后的 id（用于通知调度）
  Future<int> addTodo(TodoItem item);
  Future<void> updateTodo(TodoItem item);
  Future<void> deleteTodo(int id);
  Future<void> toggleComplete(int id);
}
