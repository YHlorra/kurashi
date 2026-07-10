import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurashi/data/repositories/fake/fake_todo_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_habit_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_subscription_repository.dart';
import 'package:kurashi/data/repositories/providers.dart';
import 'package:kurashi/feature/todo/providers/todays_agenda_provider.dart';

void main() {
  group('todaysAgendaProvider', () {
    late ProviderContainer container;
    setUp(() {
      container = ProviderContainer(overrides: [
        todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
        habitRepositoryProvider.overrideWithValue(FakeHabitRepository()),
        subscriptionRepositoryProvider.overrideWithValue(FakeSubscriptionRepository()),
      ]);
    });
    tearDown(() => container.dispose());

    test('emits agenda items on subscription', () async {
      final agenda = await container.read(todaysAgendaProvider.future);
      expect(agenda, isNotEmpty);
    });

    test('agenda contains todo and habit items', () async {
      final agenda = await container.read(todaysAgendaProvider.future);
      expect(agenda.whereType<TodoAgendaItem>(), isNotEmpty);
      expect(agenda.whereType<HabitAgendaItem>(), isNotEmpty);
    });

    test('completed todos filtered from agenda', () async {
      final agenda = await container.read(todaysAgendaProvider.future);
      final completedTodos = agenda.whereType<TodoAgendaItem>().where((t) => t.item.completed).toList();
      expect(completedTodos, isEmpty);
    });

    test('agenda first item is a todo (design order)', () async {
      final agenda = await container.read(todaysAgendaProvider.future);
      expect(agenda.first, isA<TodoAgendaItem>());
    });
  });
}
