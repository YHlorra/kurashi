import 'package:isar_plus/isar_plus.dart';

import '../../models/todo_item.dart';
import '../todo_repository.dart';

/// 待办事项仓库的 Isar 实现。
///
/// 所有写操作必须包在 `isar.write(...)` 里——isar_plus 的 put/delete
/// 不会自动开启事务，裸调会抛 WriteTxnRequiredError。
// TODO: integration test on real device
class IsarTodoRepository implements TodoRepository {
  final Isar isar;

  IsarTodoRepository(this.isar);

  @override
  Stream<List<TodoItem>> watchAll() {
    // watchLazy 在 collection 任意变更时触发；fireImmediately 立即推送初始快照。
    return isar.todoItems
        .watchLazy(fireImmediately: true)
        .map((_) => isar.todoItems.where().findAll());
  }

  @override
  Future<int> addTodo(TodoItem item) async {
    // id == 0 表示 UI 新建未分配，用 autoIncrement 取实际 id。
    final newItem = item.id == 0
        ? item.copyWith(id: isar.todoItems.autoIncrement())
        : item;
    return isar.write((isar) {
      isar.todoItems.put(newItem);
      return newItem.id;
    });
  }

  @override
  Future<void> updateTodo(TodoItem item) async {
    // Isar put 为 upsert：存在 id 则更新，否则插入。
    isar.write((isar) => isar.todoItems.put(item));
  }

  @override
  Future<void> deleteTodo(int id) async {
    isar.write((isar) => isar.todoItems.delete(id));
  }

  @override
  Future<void> toggleComplete(int id) async {
    isar.write((isar) {
      final item = isar.todoItems.get(id);
      if (item == null) return;
      final now = DateTime.now();
      isar.todoItems.put(
        item.copyWith(
          completed: !item.completed,
          completedAt: item.completed ? null : now,
        ),
      );
    });
  }
}
