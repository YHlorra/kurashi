import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/isar_provider.dart';
import 'app_settings_repository.dart';
import 'fake/fake_app_settings_repository.dart';
import 'fake/fake_fridge_repository.dart';
import 'fake/fake_habit_repository.dart';
import 'fake/fake_subscription_repository.dart';
import 'fake/fake_todo_repository.dart';
import 'fridge_repository.dart';
import 'habit_repository.dart';
import 'isar/isar_app_settings_repository.dart';
import 'isar/isar_fridge_repository.dart';
import 'isar/isar_habit_repository.dart';
import 'isar/isar_subscription_repository.dart';
import 'isar/isar_todo_repository.dart';
import 'subscription_repository.dart';
import 'todo_repository.dart';

/// 是否使用 Isar 持久化层。
///
/// isar_plus 的原生库仅面向移动端（Android/iOS），Windows/macOS/Linux/Web
/// 无原生二进制，运行时会因 `isar_plus_flutter_libs` symlink 缺失而失败。
/// 因此桌面/端预览走 Fake（内存 mock，重启即重置，仅供 UI 预览），
/// 移动端走 Isar（真机持久化，重启数据保留）。
///
/// 这与规划 §0.2「只做 Android + iOS」一致——桌面仅作阶段 1 UI 预览手段，
/// 阶段 2 引入原生库后桌面预览自然降级为 Fake。
bool get _useIsar => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// 待办事项仓库 Provider
///
/// 移动端：Isar 持久化（main.dart 预热 isarProvider 后非空）。
/// 桌面/Web：Fake 内存 mock（开发预览用，重启重置）。
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  if (!_useIsar) {
    return FakeTodoRepository();
  }
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarTodoRepository(isar);
});

/// 习惯仓库 Provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  if (!_useIsar) {
    return FakeHabitRepository();
  }
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarHabitRepository(isar);
});

/// 订阅仓库 Provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  if (!_useIsar) {
    return FakeSubscriptionRepository();
  }
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarSubscriptionRepository(isar);
});

/// 冰箱仓库 Provider
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  if (!_useIsar) {
    return FakeFridgeRepository();
  }
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarFridgeRepository(isar);
});

/// 应用设置仓库 Provider
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  if (!_useIsar) {
    return FakeAppSettingsRepository();
  }
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarAppSettingsRepository(isar);
});
