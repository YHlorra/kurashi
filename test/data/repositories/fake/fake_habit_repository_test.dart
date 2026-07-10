import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/habit.dart';
import 'package:kurashi/data/models/habit_checkin.dart';
import 'package:kurashi/data/repositories/fake/fake_habit_repository.dart';

void main() {
  group('HabitRepository - user behavior', () {
    test('user adds a habit and sees it in the list', () async {
      final repo = _createRepo();
      final before = await repo.watchAll().first;
      await repo.addHabit(Habit(title: 'Meditate', frequencyPerWeek: 7, createdAt: DateTime.now()));
      final after = await repo.watchAll().first;
      expect(after.length, before.length + 1);
    });

    test('user deletes a habit and it disappears', () async {
      final repo = _createRepo();
      final before = await repo.watchAll().first;
      final targetId = before.first.id;
      await repo.deleteHabit(targetId);
      final after = await repo.watchAll().first;
      expect(after.any((h) => h.id == targetId), isFalse);
    });

    test('user checks in on a day and sees it', () async {
      final repo = _createRepo();
      await repo.checkin(1, DateTime(2026, 8, 3));
      final checkins = await repo.watchCheckinsFor(1, DateTime(2026, 8, 1)).first;
      expect(checkins.any((c) => c.date.day == 3), isTrue);
    });

    test('checking in same day twice does not double-count', () async {
      final repo = _createRepo();
      await repo.checkin(1, DateTime(2026, 8, 3));
      await repo.checkin(1, DateTime(2026, 8, 3));
      final checkins = await repo.watchCheckinsFor(1, DateTime(2026, 8, 1)).first;
      expect(checkins.where((c) => c.date.day == 3).length, 1);
    });

    test('user unchecks a day and it disappears', () async {
      final repo = _createRepo();
      await repo.checkin(1, DateTime(2026, 8, 5));
      await repo.uncheckin(1, DateTime(2026, 8, 5));
      final checkins = await repo.watchCheckinsFor(1, DateTime(2026, 8, 1)).first;
      expect(checkins.any((c) => c.date.day == 5), isFalse);
    });
  });
}

/// Helper: uses FakeHabitRepository directly.
/// Each test gets a fresh instance, so broadcast stream conflicts don't accumulate.
FakeHabitRepository _createRepo() => FakeHabitRepository();
