import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/models/todo_item.dart';
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
  });

  group('buildAgenda 内联宽限期（grace period）', () {
    // 固定「今天」为 2026-07-13，避免依赖真实时钟。
    final today = DateTime(2026, 7, 13, 10, 0);
    final active = TodoItem(title: 'active', createdAt: today);
    final doneToday = TodoItem(
      title: 'done today',
      completed: true,
      completedAt: DateTime(2026, 7, 13, 9, 0),
      createdAt: today,
    );
    final doneYesterday = TodoItem(
      title: 'done yesterday',
      completed: true,
      completedAt: DateTime(2026, 7, 12, 9, 0),
      createdAt: today,
    );

    test('active todo 出现在 agenda', () {
      final agenda = buildAgenda([active], const [], const [], today: today);
      expect(
        agenda.whereType<TodoAgendaItem>().any((t) => t.item.title == 'active'),
        isTrue,
      );
    });

    test('completed-今天 出现在 agenda（内联保留）', () {
      final agenda = buildAgenda([doneToday], const [], const [], today: today);
      expect(
        agenda.whereType<TodoAgendaItem>().any(
          (t) => t.item.title == 'done today',
        ),
        isTrue,
      );
    });

    test('completed-昨天 不出现在 agenda（已归档）', () {
      final agenda = buildAgenda(
        [doneYesterday],
        const [],
        const [],
        today: today,
      );
      expect(agenda.whereType<TodoAgendaItem>(), isEmpty);
    });

    test('completed-今天 排序在 active 之后（置底）', () {
      final agenda = buildAgenda(
        [active, doneToday],
        const [],
        const [],
        today: today,
      );
      final todos = agenda.whereType<TodoAgendaItem>().toList();
      final activeIdx = todos.indexWhere((t) => t.item.title == 'active');
      final doneIdx = todos.indexWhere((t) => t.item.title == 'done today');
      expect(activeIdx, isNot(equals(-1)));
      expect(doneIdx, isNot(equals(-1)));
      expect(doneIdx, greaterThan(activeIdx));
    });

    test('completedAt 为 null 的遗留数据不内联', () {
      final legacy = TodoItem(
        title: 'legacy',
        completed: true,
        completedAt: null,
        createdAt: today,
      );
      final agenda = buildAgenda([legacy], const [], const [], today: today);
      expect(agenda.whereType<TodoAgendaItem>(), isEmpty);
    });
  });
}
