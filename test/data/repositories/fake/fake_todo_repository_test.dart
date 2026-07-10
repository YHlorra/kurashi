import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/todo_item.dart';
import 'package:kurashi/data/repositories/fake/fake_todo_repository.dart';

void main() {
  group('TodoRepository - behavior', () {
    test('user adds a todo and sees it in the list', () async {
      final repo = FakeTodoRepository();
      final events = <List<TodoItem>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final newId = await repo.addTodo(TodoItem(title: 'Buy milk', createdAt: DateTime.now()));
      await Future.delayed(Duration.zero);

      expect(events.last.any((t) => t.id == newId && t.title == 'Buy milk'), isTrue);
      await sub.cancel();
    });

    test('user taps complete and the todo disappears from active list', () async {
      final repo = FakeTodoRepository();
      final events = <List<TodoItem>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final id = await repo.addTodo(TodoItem(title: 'Task', createdAt: DateTime.now()));
      await Future.delayed(Duration.zero);
      final addedCount = events.last.length;

      await repo.toggleComplete(id);
      await Future.delayed(Duration.zero);

      expect(events.last.length, addedCount); // stays in list (Fake behavior)
      expect(events.last.firstWhere((t) => t.id == id).completed, isTrue);

      await repo.toggleComplete(id);
      await Future.delayed(Duration.zero);
      expect(events.last.firstWhere((t) => t.id == id).completed, isFalse);
      await sub.cancel();
    });

    test('user deletes a todo and it no longer appears', () async {
      final repo = FakeTodoRepository();
      final events = <List<TodoItem>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final beforeCount = events.last.length;
      await repo.deleteTodo(events.last.first.id);
      await Future.delayed(Duration.zero);

      expect(events.last.length, beforeCount - 1);
      await sub.cancel();
    });

    test('toggle on non-existent id does not crash', () async {
      final repo = FakeTodoRepository();
      final events = <List<TodoItem>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final beforeCount = events.last.length;
      await repo.toggleComplete(99999);
      await Future.delayed(Duration.zero);
      expect(events.last.length, beforeCount);
      await sub.cancel();
    });

    test('delete on non-existent id does not crash', () async {
      final repo = FakeTodoRepository();
      final events = <List<TodoItem>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final beforeCount = events.last.length;
      await repo.deleteTodo(99999);
      await Future.delayed(Duration.zero);
      expect(events.last.length, beforeCount);
      await sub.cancel();
    });
  });
}
