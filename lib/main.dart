import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_provider.dart';
import 'core/notifications/notification_initializer.dart';
import 'data/repositories/providers.dart';

/// 应用入口 —— 预热 Isar 后 runApp。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 状态栏图标黑色 + 背景白色
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  final container = ProviderContainer();

  // 预热 Isar
  await container.read(isarProvider.future);

  // 初始化通知 + 请求权限
  await NotificationInitializer.initialize();

  // 阶段 2.x：冷启动跑一次冰箱食材记录保留策略 sweep。
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
