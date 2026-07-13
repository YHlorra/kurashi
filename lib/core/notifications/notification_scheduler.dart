import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/fridge_item.dart';
import '../../data/models/habit.dart';
import '../../data/models/subscription.dart';
import '../../data/models/todo_item.dart';
import '../lunar/lunar_service.dart';

/// 计算待办提醒的触发时间（纯函数，便于单元测试）。
///
/// 返回 null 表示应跳过：无 dueDate / 已完成 / 时间已过期。
/// 用户设置了具体时间（[TodoItem.dueTimeMinutes]）时按该时间触发；
/// 否则回退到 dueDate 当天 09:00 的「晨间摘要」行为。
DateTime? computeTodoReminderTime(TodoItem item, DateTime now) {
  if (item.dueDate == null || item.completed) return null;
  final due = item.dueDate!;
  final minuteOfDay = item.dueTimeMinutes;
  final scheduled = minuteOfDay != null
      ? DateTime(
          due.year,
          due.month,
          due.day,
          minuteOfDay ~/ 60,
          minuteOfDay % 60,
        )
      : DateTime(due.year, due.month, due.day, 9, 0);
  if (scheduled.isBefore(now)) return null;
  return scheduled;
}

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
  /// 触发时间：若用户设置了具体时间（dueTimeMinutes），按该时间触发；
  /// 否则回退到 dueDate 当天 09:00 的「晨间摘要」行为。
  /// 若计算出的时间已过，则跳过（无法提醒过去）。
  /// 通知标题：「待办提醒」，正文：item.title。
  Future<void> scheduleTodoReminder(TodoItem item) async {
    if (!_isMobile) {
      debugPrint('[notify-skip] todo ${item.id} (desktop/web)');
      return;
    }
    final scheduled = computeTodoReminderTime(item, DateTime.now());
    if (scheduled == null) {
      debugPrint(
        '[notify-skip] todo ${item.id} (no dueDate / completed / past)',
      );
      return;
    }

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

    // iOS 通知权限：延迟请求（与 NotificationInitializer 注释设计一致）。
    // _schedule 是四类提醒汇聚点，在此请求覆盖所有路径，恰为「首次创建提醒」时机。
    // Android 权限已在 NotificationInitializer 启动时请求，此处不重复。
    if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }

    final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);
    final mode = await _resolveAndroidScheduleMode();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: details,
      androidScheduleMode: mode,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }

  /// 决定 Android 精确闹钟调度模式（精确闹钟守卫）。
  ///
  /// 背景：Android 12+ (API 31+) 用 exactAllowWhileIdle 需要用户授予
  /// SCHEDULE_EXACT_ALARM；若未授权，zonedSchedule(exact) 会抛异常 / 静默不响，
  /// 导致所有提醒失效（vivo Android 16 直接命中）。
  ///
  /// 策略：
  /// - 非 Android（iOS）：exactAllowWhileIdle（iOS 无此权限概念，插件忽略模式差异）。
  /// - Android 且已授权：exactAllowWhileIdle（跨 Doze/待机持久，体验最佳）。
  /// - Android 但未授权：降级 inexactAllowWhileIdle——用 setAndAllowWhileIdle,
  ///   不需要 SCHEDULE_EXACT_ALARM 权限，能在 Doze 下触发，有 0-15 分钟延迟但保证能响。
  ///
  /// ponytail: 原降级用 alarmClock，但 flutter_local_notifications 22.x 原生层
  /// （FlutterLocalNotificationsPlugin.java:748）alarmClock 分支也调用
  /// checkCanScheduleExactAlarms()，未授权抛 ExactAlarmPermissionException，
  /// 被 unawaited+catchError 吞掉 → 通知恒不响。inexactAllowWhileIdle 走
  /// setAndAllowWhileIdle 路径，不检查权限，是真正的安全降级。
  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return AndroidScheduleMode.exactAllowWhileIdle;
    final canExact =
        await androidPlugin.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// 引导用户授予精确闹钟权限（请求系统权限，Android 12+ 会引导至设置页）。
  ///
  /// 当 [canScheduleExactNotifications] 返回 false 时调用，配合
  /// [_resolveAndroidScheduleMode] 的 alarmClock 降级，让用户在需要时升级为
  /// 跨 Doze 的精确提醒。
  /// 不自动在启动时调用（避免打扰），应由设置页 / 首次开启提醒的 UI 入口触发。
  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;
    if ((await androidPlugin.canScheduleExactNotifications()) != true) {
      await androidPlugin.requestExactAlarmsPermission();
    }
  }
}

/// 全局单例，UI / Repository / background_worker 通过此调用通知调度。
final notificationScheduler = NotificationScheduler();
