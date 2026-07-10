import 'dart:io';

import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../data/models/fridge_item.dart';
import '../../data/models/habit.dart';
import '../../data/models/subscription.dart';
import '../../data/models/todo_item.dart';
import '../database/schemas.dart';
import '../lunar/lunar_service.dart';
import 'notification_scheduler.dart';

/// 后台重算 worker —— 阶段 2.3 Task 14。
///
/// workmanager 在后台 isolate 中运行 [callbackDispatcher]，每日凌晨 03:00 重算
/// 全部通知调度。策略：cancelAll 清场 + 重新调度未来 7 天内的项目，简单可靠，
/// 避免增量 diff 复杂度。
///
/// 后台 isolate 不能共享主 isolate 的 Isar 实例 / Riverpod Provider / timezone
/// 状态，故在 [callbackDispatcher] 中：
/// 1. 重新初始化 timezone 数据（zonedSchedule 依赖）
/// 2. 重新打开 Isar（[_openIsarForBackground]，独立于 isarProvider）
/// 3. 直接调用 [notificationScheduler]（无状态全局单例）
///
/// workmanager 周期任务最短间隔 15 分钟（Android 限制），本任务用 24 小时周期 +
/// [durationToNext3AM] 对齐首次触发到凌晨 03:00。
///
/// 注册入口在 [NotificationInitializer.initialize] 中调用，由本文件导出的
/// [durationToNext3AM] 提供首次延迟计算。

/// workmanager 周期任务的 uniqueName / taskName。
const kDailyRecalcTaskName = 'kurashi-daily-recalc';

/// workmanager callback 入口 —— 必须是 top-level 函数 + `@pragma('vm:entry-point')`
/// 注解，才能在后台 isolate 中被 workmanager 反射调用。
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. 初始化 timezone（后台 isolate 独立于主 isolate 的 timezone 状态）
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // 2. 重新打开 Isar（后台 isolate 不能共享主 isolate 的 isarProvider 实例）
    final isar = await _openIsarForBackground();

    // 3. cancelAll 清场 —— 避免残留过期通知，后续全部重新调度
    await notificationScheduler.cancelAll();

    // 4. 遍历所有 active 数据 + 调度未来 7 天通知
    await _rescheduleAll(isar);

    return true;
  });
}

/// 遍历 4 类数据，重新调度未来 7 天内的通知。
///
/// 7 天窗口为简单可靠的上限：超过 7 天的项目不调度（避免 zonedSchedule 队列
/// 过长），次日凌晨 03:00 重算时再补齐。各 schedule 方法内部已过滤「已过时间」，
/// 故此处仅按 7 天窗口预筛，past-dated 项目由 scheduler 自行跳过。
Future<void> _rescheduleAll(Isar isar) async {
  final today = DateTime.now();
  final sevenDaysLater = today.add(const Duration(days: 7));

  // Todo：未完成且 dueDate 在 7 天内
  final todos = isar.todoItems.where().findAll();
  for (final t in todos) {
    if (!t.completed && t.dueDate != null && t.dueDate!.isBefore(sevenDaysLater)) {
      await notificationScheduler.scheduleTodoReminder(t);
    }
  }

  // Habit：有 reminderMinutes 的全部调度（每日重复通知，无 7 天窗口限制）
  final habits = isar.habits.where().findAll();
  for (final h in habits) {
    if (h.reminderMinutes != null) {
      await notificationScheduler.scheduleHabitReminder(h);
    }
  }

  // Subscription：active 且 nextTriggerDate 在 7 天内
  final subs = isar.subscriptions.where().findAll();
  for (final s in subs) {
    if (s.active) {
      final next = lunarService.nextTriggerDate(s);
      if (next.isBefore(sevenDaysLater)) {
        await notificationScheduler.scheduleSubscriptionReminder(s);
      }
    }
  }

  // Fridge：expiryDate 在 7 天内
  final items = isar.fridgeItems.where().findAll();
  for (final i in items) {
    if (i.expiryDate.isBefore(sevenDaysLater)) {
      await notificationScheduler.scheduleFridgeExpiry(i);
    }
  }
}

/// 在后台 isolate 中重新打开 Isar —— 独立于主 isolate 的 isarProvider 实例。
///
/// 复用同一数据库文件（getApplicationDocumentsDirectory 跨 isolate 返回同一路径），
/// inspector 关闭（后台 isolate 不需要调试工具）。
Future<Isar> _openIsarForBackground() async {
  final dir = await getApplicationDocumentsDirectory();
  try {
    return Isar.open(
      schemas: schemas,
      directory: dir.path,
      inspector: false,
    );
  } catch (e) {
    final dbName = 'default.isar';
    final dbFile = File('${dir.path}/$dbName');
    final lockFile = File('${dir.path}/$dbName.lock');
    try { if (dbFile.existsSync()) dbFile.deleteSync(); } catch (_) {}
    try { if (lockFile.existsSync()) lockFile.deleteSync(); } catch (_) {}
    return Isar.open(
      schemas: schemas,
      directory: dir.path,
      inspector: false,
    );
  }
}

/// 计算从当前时刻到下一个凌晨 03:00 的时长，用于 workmanager 周期任务的
/// [initialDelay]，使首次触发对齐到凌晨 03:00；后续按 24 小时周期循环。
///
/// 若当前时刻已过今日 03:00，则指向明日 03:00。
Duration durationToNext3AM() {
  final now = DateTime.now();
  var next3AM = DateTime(now.year, now.month, now.day, 3, 0, 0);
  if (next3AM.isBefore(now)) {
    next3AM = next3AM.add(const Duration(days: 1));
  }
  return next3AM.difference(now);
}
