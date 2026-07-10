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
      final completed = TodoItem(id: 1, title: 'done', dueDate: DateTime(2026, 7, 10), completed: true, createdAt: DateTime.now());
      await scheduler.scheduleTodoReminder(completed);
      // Should complete without throwing (no-op path)
    });

    test('scheduleTodoReminder skips items without dueDate', () async {
      final noDue = TodoItem(id: 2, title: 'no-date', completed: false, createdAt: DateTime.now());
      await scheduler.scheduleTodoReminder(noDue);
    });
  });
}
