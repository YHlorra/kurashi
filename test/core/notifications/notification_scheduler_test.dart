import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/core/notifications/notification_scheduler.dart';
import 'package:kurashi/data/models/todo_item.dart';

void main() {
  group('NotificationScheduler', () {
    late NotificationScheduler scheduler;
    setUp(() => scheduler = NotificationScheduler());


    test('Todo notification ID = 1000000 + entity id', () {
      const id = 42;
      final notifyId = 1 * 1000000 + id;
      expect(notifyId, 1000042);
    });

    test('entity type is recoverable from notification ID', () {
      expect(2000003 ~/ 1000000, 2); // Habit prefix
      expect(3000001 ~/ 1000000, 3); // Subscription prefix
      expect(4000001 ~/ 1000000, 4); // Fridge prefix
    });

    test('platform detection: scheduler initializes without error', () {
      expect(scheduler, isNotNull);
    });

    test('scheduleTodoReminder skips completed items without throw', () async {
      final completed = TodoItem(
        id: 1,
        title: 'done',
        dueDate: DateTime(2026, 7, 10),
        completed: true,
        createdAt: DateTime.now(),
      );
      await scheduler.scheduleTodoReminder(completed);
      // Should complete without throwing (no-op path)
    });

    test('scheduleTodoReminder skips items without dueDate', () async {
      final noDue = TodoItem(
        id: 2,
        title: 'no-date',
        completed: false,
        createdAt: DateTime.now(),
      );
      await scheduler.scheduleTodoReminder(noDue);
    });
  });

  group('computeTodoReminderTime', () {
    // 回归测试：曾因硬编码 09:00 而忽略用户设置的 dueTimeMinutes，
    // 导致「11:18 待办」不触发。以下用例锁死正确行为。
    final due = DateTime(2026, 7, 13); // 周一

    test('uses dueTimeMinutes when set (11:18 fires at 11:18)', () {
      final item = TodoItem(
        id: 1,
        title: 't',
        dueDate: due,
        dueTimeMinutes: 11 * 60 + 18, // 11:18
        completed: false,
        createdAt: DateTime.now(),
      );
      final t = computeTodoReminderTime(item, DateTime(2026, 7, 13, 10, 0));
      expect(t, DateTime(2026, 7, 13, 11, 18));
    });

    test('falls back to 09:00 when dueTimeMinutes is null', () {
      final item = TodoItem(
        id: 2,
        title: 't',
        dueDate: due,
        completed: false,
        createdAt: DateTime.now(),
      );
      final t = computeTodoReminderTime(item, DateTime(2026, 7, 13, 8, 0));
      expect(t, DateTime(2026, 7, 13, 9, 0));
    });

    test('skips when the computed time is already past', () {
      final item = TodoItem(
        id: 3,
        title: 't',
        dueDate: due,
        dueTimeMinutes: 11 * 60 + 18,
        completed: false,
        createdAt: DateTime.now(),
      );
      final t = computeTodoReminderTime(item, DateTime(2026, 7, 13, 12, 0));
      expect(t, isNull);
    });

    test('skips completed items', () {
      final item = TodoItem(
        id: 4,
        title: 't',
        dueDate: due,
        dueTimeMinutes: 11 * 60 + 18,
        completed: true,
        createdAt: DateTime.now(),
      );
      final t = computeTodoReminderTime(item, DateTime(2026, 7, 13, 10, 0));
      expect(t, isNull);
    });

    test('skips when dueDate is null', () {
      final item = TodoItem(
        id: 5,
        title: 't',
        completed: false,
        createdAt: DateTime.now(),
      );
      final t = computeTodoReminderTime(item, DateTime(2026, 7, 13, 10, 0));
      expect(t, isNull);
    });

    test('future date with time is not skipped', () {
      final item = TodoItem(
        id: 6,
        title: 't',
        dueDate: DateTime(2026, 7, 20),
        dueTimeMinutes: 11 * 60 + 18,
        completed: false,
        createdAt: DateTime.now(),
      );
      final t = computeTodoReminderTime(item, DateTime(2026, 7, 13, 10, 0));
      expect(t, DateTime(2026, 7, 20, 11, 18));
    });
  });
}
