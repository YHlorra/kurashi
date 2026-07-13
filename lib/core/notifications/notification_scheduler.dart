import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/fridge_item.dart';
import '../../data/models/habit.dart';
import '../../data/models/subscription.dart';
import '../../data/models/todo_item.dart';
import '../lunar/lunar_service.dart';

/// 通知调度器 —— 封装 flutter_local_notifications。
///
/// 通知 ID 规则：type 前缀 × 1000000 + entity id
///   Todo: 1xxx,xxx | Habit: 2xxx,xxx | Subscription: 3xxx,xxx | Fridge: 4xxx,xxx
///   Fridge 前 3 天通知额外加 [_fridgeAdvanceOffset]（100000）偏移区分。
///
/// 调度仅面向 Android/iOS（项目已移除 web/desktop 目标）。
/// `_isMobile` 守卫为防御性判断，在移动端恒为 true；保留以兼容潜在扩展。
///
/// 依赖 [NotificationInitializer.initialize] 中完成的 timezone 初始化
/// （tz_data.initializeTimeZones + setLocalLocation('Asia/Shanghai')）。
/// workmanager callbackDispatcher 在后台 isolate 中需重新初始化 timezone（Task 14）。
class NotificationScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _todoPrefix = 1;
  static const _habitPrefix = 2;
  static const _subPrefix = 3;
  static const _fridgePrefix = 4;
  static const _fridgeAdvanceOffset = 100000; // 前 3 天通知 ID 偏移

  /// 仅 Android/iOS 真正调度；`_isMobile` 在移动端恒为 true（防御性守卫）。
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ── 4 类 schedule 方法 ─────────────────────────────────────────────────

  /// 13.2 Todo 截止提醒。
  ///
  /// 仅当 `item.dueDate != null` 且 `!item.completed` 时调度。
  /// 触发时间：dueDate 当天 09:00（若已过则跳过）。
  /// 通知标题：「待办提醒」，正文：item.title。
  Future<void> scheduleTodoReminder(TodoItem item) async {
    if (!_isMobile) {
      debugPrint('[notify-skip] todo ${item.id} (desktop/web)');
      return;
    }
    if (item.dueDate == null || item.completed) return;

    final due = item.dueDate!;
    final now = DateTime.now();
    final scheduled = DateTime(due.year, due.month, due.day, 9, 0);
    if (scheduled.isBefore(now)) return; // 已过则跳过

    await _schedule(
      id: _todoPrefix * 1000000 + item.id,
      title: '待办提醒',
      body: item.title,
      scheduled: scheduled,
    );
  }

  /// 13.3 习惯每日提醒。
  ///
  /// 仅当 `habit.reminderMinutes != null` 时调度。
  /// 触发时间：每日 habit.reminderTime，用 zonedSchedule +
  /// matchDateTimeComponents.time 实现每日重复。
  /// 通知标题：「习惯提醒」，正文：habit.title。
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (!_isMobile) {
      debugPrint('[notify-skip] habit ${habit.id} (desktop/web)');
      return;
    }
    if (habit.reminderMinutes == null) return;

    final time = habit.reminderTime!;
    final now = DateTime.now();
    // 首次触发：今日该时间，若已过则明日
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _schedule(
      id: _habitPrefix * 1000000 + habit.id,
      title: '习惯提醒',
      body: habit.title,
      scheduled: scheduled,
      repeatDaily: true,
    );
  }

  /// 13.4 订阅提前提醒。
  ///
  /// 触发时间：lunarService.nextTriggerDate(sub) - leadDays 天，09:00。
  /// 若已过则跳过。仅当 sub.active = true 才调度。
  /// 通知标题：「订阅提醒」，正文：sub.title + "（M月D日）"。
  Future<void> scheduleSubscriptionReminder(Subscription sub) async {
    if (!_isMobile) {
      debugPrint('[notify-skip] sub ${sub.id} (desktop/web)');
      return;
    }
    if (!sub.active) return;

    final triggerDate = lunarService.nextTriggerDate(sub);
    final notifyDay = triggerDate.subtract(Duration(days: sub.leadDays));
    final now = DateTime.now();
    final scheduled = DateTime(
      notifyDay.year,
      notifyDay.month,
      notifyDay.day,
      9,
      0,
    );
    if (scheduled.isBefore(now)) return; // 已过则跳过

    final triggerStr = '${triggerDate.month}月${triggerDate.day}日';
    await _schedule(
      id: _subPrefix * 1000000 + sub.id,
      title: '订阅提醒',
      body: '${sub.title}（$triggerStr）',
      scheduled: scheduled,
    );
  }

  /// 13.5 食材过期提醒（两条通知：前 1 天 + 前 3 天）。
  ///
  /// 触发时间：expiryDate 前 1 天 09:00 + 前 3 天 09:00，各一条。
  /// 若已过则跳过该条。
  /// 通知 ID：前 1 天 = 4*1M+itemId，前 3 天 = 4*1M+100000+itemId。
  /// 通知标题：「食材提醒」，正文：item.name + "即将过期"。
  Future<void> scheduleFridgeExpiry(FridgeItem item) async {
    if (!_isMobile) {
      debugPrint('[notify-skip] fridge ${item.id} (desktop/web)');
      return;
    }

    final now = DateTime.now();
    final expiry = item.expiryDate;

    // 前 1 天通知
    final notify1 = DateTime(expiry.year, expiry.month, expiry.day - 1, 9, 0);
    if (!notify1.isBefore(now)) {
      await _schedule(
        id: _fridgePrefix * 1000000 + item.id,
        title: '食材提醒',
        body: '${item.name}即将过期',
        scheduled: notify1,
      );
    }

    // 前 3 天通知（ID 加偏移区分）
    final notify3 = DateTime(expiry.year, expiry.month, expiry.day - 3, 9, 0);
    if (!notify3.isBefore(now)) {
      await _schedule(
        id: _fridgePrefix * 1000000 + _fridgeAdvanceOffset + item.id,
        title: '食材提醒',
        body: '${item.name}即将过期',
        scheduled: notify3,
      );
    }
  }

  // ── cancel 方法 ────────────────────────────────────────────────────────

  /// 取消 Todo 通知。
  Future<void> cancelTodo(int id) async {
    if (!_isMobile) return;
    await _plugin.cancel(id: _todoPrefix * 1000000 + id);
  }

  /// 取消 Habit 通知。
  Future<void> cancelHabit(int id) async {
    if (!_isMobile) return;
    await _plugin.cancel(id: _habitPrefix * 1000000 + id);
  }

  /// 取消 Subscription 通知。
  Future<void> cancelSubscription(int id) async {
    if (!_isMobile) return;
    await _plugin.cancel(id: _subPrefix * 1000000 + id);
  }

  /// 取消 Fridge 通知（前 1 天 + 前 3 天两条）。
  Future<void> cancelFridge(int id) async {
    if (!_isMobile) return;
    await _plugin.cancel(id: _fridgePrefix * 1000000 + id);
    await _plugin.cancel(
      id: _fridgePrefix * 1000000 + _fridgeAdvanceOffset + id,
    );
  }

  /// 取消全部通知 —— 用于 background_worker 每日重排前清场。
  Future<void> cancelAll() async {
    if (!_isMobile) return;
    await _plugin.cancelAll();
  }

  // ── 内部调度辅助 ──────────────────────────────────────────────────────

  /// 统一调度入口：DateTime → TZDateTime 后调 zonedSchedule。
  ///
  /// [repeatDaily] 为 true 时用 matchDateTimeComponents.time 实现每日重复
  /// （用于习惯提醒）；其余为一次性通知。
  ///
  /// 必须用 zonedSchedule 而非 show + 定时器，才能实现「杀进程后通知仍响」。
  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduled,
    bool repeatDaily = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kurashi_reminders', // channel id
      '提醒', // channel name
      channelDescription: 'Todo / 习惯 / 订阅 / 食材提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }
}

/// 全局单例，UI / Repository / background_worker 通过此调用通知调度。
final notificationScheduler = NotificationScheduler();
