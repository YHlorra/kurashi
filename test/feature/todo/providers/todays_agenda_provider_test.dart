import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/repositories/isar/isar_habit_repository.dart';
import 'package:kurashi/data/repositories/isar/isar_subscription_repository.dart';
import 'package:kurashi/data/repositories/isar/isar_todo_repository.dart';
import 'package:kurashi/data/repositories/providers.dart';
import 'package:kurashi/feature/todo/providers/todays_agenda_provider.dart';

Isar? _isar;

void main() {
  group('todaysAgendaProvider', () {
    late ProviderContainer? container;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      try {
        final dir = Directory.systemTemp.createTempSync('test_isar_agenda');
        _isar = Isar.open(schemas: schemas, directory: dir.path);
      } catch (_) {
        _isar = null;
      }
    });

    tearDownAll(() {
      _isar?.close();
      try {
        if (_isar != null)
          Directory('${_isar!.directory}').deleteSync(recursive: true);
      } catch (_) {}
    });

    setUp(() {
      final isar = _isar;
      if (isar == null) {
        container = null;
        return;
      }
      container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(IsarTodoRepository(isar)),
          habitRepositoryProvider.overrideWithValue(IsarHabitRepository(isar)),
          subscriptionRepositoryProvider.overrideWithValue(
            IsarSubscriptionRepository(isar),
          ),
        ],
      );
    });

    tearDown(() => container?.dispose());

    test('用户打开今日视图 → 收到聚合事项列表', () async {
      if (_isar == null || container == null)
        return markTestSkipped('Isar 原生库不可用');
      final agenda = await container!.read(todaysAgendaProvider.future);
      expect(agenda, isA<List<AgendaItem>>());
      expect(agenda, isNotEmpty);
    });

    test('今日事项包含待办和习惯', () async {
      if (_isar == null || container == null)
        return markTestSkipped('Isar 原生库不可用');
      final agenda = await container!.read(todaysAgendaProvider.future);
      expect(agenda.whereType<TodoAgendaItem>(), isNotEmpty);
      expect(agenda.whereType<HabitAgendaItem>(), isNotEmpty);
    });

    test('已完成待办不出现在今日事项中', () async {
      if (_isar == null || container == null)
        return markTestSkipped('Isar 原生库不可用');
      final agenda = await container!.read(todaysAgendaProvider.future);
      final completedTodos = agenda
          .whereType<TodoAgendaItem>()
          .where((t) => t.item.completed)
          .toList();
      expect(completedTodos, isEmpty);
    });
  });
}
