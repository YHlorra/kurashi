// notification_scheduler 单测（Task 16.1）
//
// 桌面测试环境（Windows）下 flutter_local_notifications 无法真正调度
// （无 Android/iOS runtime），notificationScheduler 内部 _isMobile=false
// 会让所有 schedule / cancel 方法走平台 fallback 静默 no-op。
//
// 本单测验证：
//   1. 4 类 schedule 在桌面环境不抛异常（平台 fallback 生效）
//   2. 4 类 schedule 的边界条件（completed / dueDate=null / active=false /
//      reminderMinutes=null）在桌面环境不抛异常
//   3. cancelAll / 4 类 cancel 在桌面环境不抛异常
//
// 不验证通知真的被调度（桌面环境无法验证）—— ID 计算规则的正确性由
// 代码审查 + 真机回归（阶段 3.4）保证。
//
// 注意：notificationScheduler 是全局单例，无需 setUp 初始化。
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/core/notifications/notification_scheduler.dart';
import 'package:kurashi/data/models/fridge_item.dart';
import 'package:kurashi/data/models/habit.dart';
import 'package:kurashi/data/models/subscription.dart';
import 'package:kurashi/data/models/todo_item.dart';

void main() {
  group('NotificationScheduler 桌面平台 fallback', () {
    // ── 4 类 schedule：正常入参 ─────────────────────────────────────────
    group('schedule 方法（正常入参）', () {
      test('scheduleTodoReminder 在桌面环境不抛异常', () async {
        final item = TodoItem(
          id: 1,
          title: '测试 todo',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
        );
        // 桌面环境 _isMobile=false，应静默 no-op
        await notificationScheduler.scheduleTodoReminder(item);
      });

      test('scheduleHabitReminder 在桌面环境不抛异常', () async {
        final habit = Habit(
          id: 1,
          title: '测试习惯',
          frequencyPerWeek: 3,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          createdAt: DateTime.now(),
        );
        await notificationScheduler.scheduleHabitReminder(habit);
      });

      test('scheduleSubscriptionReminder 在桌面环境不抛异常', () async {
        final sub = Subscription(
          id: 1,
          title: '国庆节',
          type: SubType.cnFestival,
          calendar: Calendar.solar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: 10,
          anchorDay: 1,
          leadDays: 7,
          active: true,
          createdAt: DateTime.now(),
        );
        await notificationScheduler.scheduleSubscriptionReminder(sub);
      });

      test('scheduleFridgeExpiry 在桌面环境不抛异常', () async {
        final item = FridgeItem(
          id: 1,
          name: '牛奶',
          quantity: '1L',
          addedDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 3)),

        );
        await notificationScheduler.scheduleFridgeExpiry(item);
      });
    });

    // ── 4 类 schedule：边界条件 ─────────────────────────────────────────
    group('schedule 方法（边界条件）', () {
      test('completed=true 的 todo 不调度且不抛异常', () async {
        final item = TodoItem(
          id: 2,
          title: '已完成 todo',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          completed: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await notificationScheduler.scheduleTodoReminder(item);
      });

      test('dueDate=null 的 todo 不调度且不抛异常', () async {
        final item = TodoItem(
          id: 3,
          title: '无截止日 todo',
          dueDate: null,
          createdAt: DateTime.now(),
        );
        await notificationScheduler.scheduleTodoReminder(item);
      });

      test('reminderMinutes=null 的 habit 不调度且不抛异常', () async {
        final habit = Habit(
          id: 2,
          title: '无提醒习惯',
          frequencyPerWeek: 3,
          reminderTime: null,
          createdAt: DateTime.now(),
        );
        await notificationScheduler.scheduleHabitReminder(habit);
      });

      test('active=false 的 subscription 不调度且不抛异常', () async {
        final sub = Subscription(
          id: 2,
          title: '已停用订阅',
          type: SubType.birthday,
          calendar: Calendar.lunar,
          mode: TriggerMode.anchorMonthly,
          anchorMonth: 8,
          anchorDay: 8,
          leadDays: 7,
          active: false,
          createdAt: DateTime.now(),
        );
        await notificationScheduler.scheduleSubscriptionReminder(sub);
      });

      test('已过期的 fridge expiryDate 不调度且不抛异常', () async {
        // expiryDate 在过去，前 1 天 / 前 3 天通知均已过 —— 桌面环境应静默 no-op
        final item = FridgeItem(
          id: 3,
          name: '过期牛奶',
          quantity: '1L',
          addedDate: DateTime.now().subtract(const Duration(days: 10)),
          expiryDate: DateTime.now().subtract(const Duration(days: 2)),

        );
        await notificationScheduler.scheduleFridgeExpiry(item);
      });
    });

    // ── cancel 方法 ────────────────────────────────────────────────────
    group('cancel 方法', () {
      test('cancelAll 在桌面环境不抛异常', () async {
        await notificationScheduler.cancelAll();
      });

      test('cancelTodo / cancelHabit / cancelSubscription / cancelFridge 在桌面环境不抛异常',
          () async {
        await notificationScheduler.cancelTodo(1);
        await notificationScheduler.cancelHabit(1);
        await notificationScheduler.cancelSubscription(1);
        await notificationScheduler.cancelFridge(1);
      });

      test('cancel 同一 id 多次调用不抛异常（幂等）', () async {
        await notificationScheduler.cancelTodo(42);
        await notificationScheduler.cancelTodo(42);
        await notificationScheduler.cancelFridge(42);
        await notificationScheduler.cancelFridge(42);
      });
    });
  });
}
