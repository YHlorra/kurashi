import 'dart:async';
import '../../models/todo_item.dart';
import '../todo_repository.dart';

/// 待办事项仓库的内存实现（阶段 1 用 mock 数据）
class FakeTodoRepository implements TodoRepository {
  final _controller = StreamController<List<TodoItem>>.broadcast();
  final List<TodoItem> _items;
  int _nextId = 100;

  FakeTodoRepository() : _items = _createMockData();

  static List<TodoItem> _createMockData() {
    final now = DateTime(2026, 7, 1);
    return [
      TodoItem(
        id: 1,
        title: '回邮件给导师',
        dueDate: DateTime(2026, 7, 1, 18, 0),
        completed: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TodoItem(
        id: 2,
        title: '买牛奶 + 鸡蛋',
        dueDate: DateTime(2026, 7, 2),
        completed: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      TodoItem(
        id: 3,
        title: '整理上周复盘',
        completed: true,
        completedAt: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TodoItem(
        id: 4,
        title: '续保家庭意外险',
        dueDate: DateTime(2026, 7, 2),
        completed: false,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  @override
  Stream<List<TodoItem>> watchAll() {
    Future.microtask(() => _controller.add(List.unmodifiable(_items)));
    return _controller.stream;
  }

  @override
  Future<int> addTodo(TodoItem item) async {
    final newItem = item.id == 0 ? item.copyWith(id: _nextId++) : item;
    _items.add(newItem);
    _controller.add(List.unmodifiable(_items));
    return newItem.id;
  }

  @override
  Future<void> updateTodo(TodoItem item) async {
    final index = _items.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    _items.removeWhere((item) => item.id == id);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> toggleComplete(int id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];
      final now = DateTime.now();
      _items[index] = item.copyWith(
        completed: !item.completed,
        completedAt: item.completed ? null : now,
      );
      _controller.add(List.unmodifiable(_items));
    }
  }
}
