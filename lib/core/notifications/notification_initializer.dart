import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'background_worker.dart';

/// 通知初始化器 —— 阶段 2.3 引入。
///
/// 仅在移动端调用（main.dart 中通过 Platform.isAndroid || Platform.isIOS 判断），
/// 桌面/Web 跳过，与 `isar_provider` 的平台 fallback 模式一致。
///
/// 职责：
/// 1. 初始化 flutter_local_notifications（Android 用 ic_launcher，iOS 暂不请求权限）。
/// 2. 请求 Android 13+ (API 33+) 的 POST_NOTIFICATIONS 运行时权限。
/// 3. workmanager 周期任务注册 —— 每日凌晨 03:00 重算全部通知调度（Task 14）。
class NotificationInitializer {
  /// 在 main.dart 的 isarProvider 预热之后调用。
  static Future<void> initialize() async {
    // 0. 初始化 timezone 数据 —— zonedSchedule 依赖 TZDateTime。
    //    本地时区固定为 Asia/Shanghai（App 面向中文用户）。
    //    workmanager callbackDispatcher 在后台 isolate 运行，需在其中
    //    重新调用 tz_data.initializeTimeZones() + setLocalLocation（见
    //    background_worker.dart callbackDispatcher）。
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // 1. flutter_local_notifications 初始化
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      // iOS 权限不在启动时请求，由 `requestPermissions` 在适当时机（如用户开启通知开关）请求。
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    // flutter_local_notifications 22.x API：initialize 改为命名参数 settings。
    await FlutterLocalNotificationsPlugin().initialize(settings: initSettings);

    // 2. 请求 Android 13+ 通知权限（POST_NOTIFICATIONS 运行时权限）。
    //    iOS 无对应调用，权限请求由后续 `requestPermissions()` 触发。
    //
    // 阶段 3.3 Task 7.1：权限弹窗文案由操作系统控制（Android 系统通知权限对话框 /
    // iOS 系统权限 alert），App 侧无法自定义文案。如需在请求前显示中文解释弹窗，
    // 应在调用方（如设置页通知开关）用 showDialog 自行实现 rationale，
    // 此处不引入额外 UI（lazy 原则：系统弹窗已足够清晰）。
    final androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // 3. workmanager 初始化 + 注册每日凌晨 03:00 重算任务（Task 14）。
    //    callbackDispatcher 在 background_worker.dart 定义，top-level 函数 +
    //    @pragma('vm:entry-point') 注解以便后台 isolate 反射调用。
    //    frequency=24h 周期，initialDelay 对齐首次触发到下一个凌晨 03:00。
    //    existingWorkPolicy=replace 确保重启 App 后覆盖旧任务（避免频率混淆）。
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      kDailyRecalcTaskName, // uniqueName
      kDailyRecalcTaskName, // taskName
      frequency: const Duration(hours: 24),
      initialDelay: durationToNext3AM(),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }
}
