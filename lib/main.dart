import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_provider.dart';
import 'core/notifications/notification_initializer.dart';
import 'data/repositories/providers.dart';

/// 阶段 2.1：入口改为预热 Isar 后再 runApp（仅移动端）。
/// 阶段 2.3：移动端额外初始化通知（flutter_local_notifications + workmanager 注册）。
/// 阶段 2.x：移动端跑一次冰箱食材记录的自动清理 sweep（永久策略时是 noop）。
///
/// isar_plus 原生库仅支持 Android/iOS，桌面/Web 跳过预热，providers.dart
/// 会自动降级为 Fake（内存 mock）。移动端通过 `await container
/// .read(isarProvider.future)` 等 Isar 初始化完成，然后用
/// UncontrolledProviderScope 复用同一 container，确保仓库 Provider 拿到非空 Isar。
/// 通知初始化 / retention sweep 走同样的平台 fallback —— 桌面/Web 同样跑（Fake 仓库内
/// 实现保证内存行为），不需要额外平台分支。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 状态栏图标黑色 + 背景白色
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  final container = ProviderContainer();

  // 仅移动端预热 Isar；桌面/Web 跳过，仓库 Provider 自动走 Fake。
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await container.read(isarProvider.future);
    // 阶段 2.3：初始化通知 + 请求权限（workmanager 注册在 Task 14 启用）。
    await NotificationInitializer.initialize();
  }

  // 阶段 2.x：冷启动跑一次冰箱食材记录保留策略 sweep。永久策略时是 noop；
  // 30 / 90 天策略且跨月 / 跨季度时清理过期日志。失败仅 log，不阻塞 app 启动。
  await container.read(fridgeRepositoryProvider).runRetentionSweep(
    DateTime.now(),
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KurashiApp(),
    ),
  );
}
