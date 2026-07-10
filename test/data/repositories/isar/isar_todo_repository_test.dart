import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/models/todo_item.dart';
import 'package:kurashi/data/repositories/isar/isar_todo_repository.dart';

late Isar? isar;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final dir = Directory.systemTemp.createTempSync('test_isar_todo');
      isar = Isar.open(schemas: schemas, directory: dir.path);
    } catch (_) {
      isar = null;
    }
  });
  tearDownAll(() {
    isar?.close();
    try { if (isar != null) Directory('${isar!.directory}').deleteSync(recursive: true); } catch (_) {}
  });

  group('TodoRepository — 用户行为', () {
    test('用户添加待办 → 列表出现该待办', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarTodoRepository(isar!);
      final before = await repo.watchAll().first;
      await repo.addTodo(TodoItem(title: '买牛奶', createdAt: DateTime.now()));
      final after = await repo.watchAll().first;
      expect(after.length, before.length + 1);
      expect(after.any((t) => t.title == '买牛奶'), isTrue);
    });

    test('用户标记完成 → 待办状态变为已完成', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarTodoRepository(isar!);
      final items = await repo.watchAll().first;
      expect(items, isNotEmpty);
      final target = items.first;
      await repo.updateTodo(target.copyWith(completed: true, completedAt: DateTime.now()));
      final after = await repo.watchAll().first;
      expect(after.firstWhere((t) => t.id == target.id).completed, isTrue);
    });

    test('用户删除待办 → 列表不再包含', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarTodoRepository(isar!);
      final items = await repo.watchAll().first;
      final target = items.first;
      await repo.deleteTodo(target.id);
      final after = await repo.watchAll().first;
      expect(after.any((t) => t.id == target.id), isFalse);
    });

    test('用户添加重复内容 → 两条都保存', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarTodoRepository(isar!);
      await repo.addTodo(TodoItem(title: '测试重复', createdAt: DateTime.now()));
      await repo.addTodo(TodoItem(title: '测试重复', createdAt: DateTime.now()));
      final after = await repo.watchAll().first;
      expect(after.where((t) => t.title == '测试重复').length, 2);
    });

    test('用户添加待办后 close 再 open → 数据持久化', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarTodoRepository(isar!);
      await repo.addTodo(TodoItem(title: '持久化测试', createdAt: DateTime.now()));
      final origDir = isar!.directory;
      isar!.close();
      isar = Isar.open(schemas: schemas, directory: origDir);
      final repo2 = IsarTodoRepository(isar!);
      final items = await repo2.watchAll().first;
      expect(items.any((t) => t.title == '持久化测试'), isTrue);
    });
  });
}
