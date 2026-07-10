import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/isar_provider.dart';
import 'app_settings_repository.dart';
import 'fridge_repository.dart';
import 'habit_repository.dart';
import 'isar/isar_app_settings_repository.dart';
import 'isar/isar_fridge_repository.dart';
import 'isar/isar_habit_repository.dart';
import 'isar/isar_subscription_repository.dart';
import 'isar/isar_todo_repository.dart';
import 'subscription_repository.dart';
import 'todo_repository.dart';

/// 待办事项仓库 Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarTodoRepository(isar);
});

/// 习惯仓库 Provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarHabitRepository(isar);
});

/// 订阅仓库 Provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarSubscriptionRepository(isar);
});

/// 冰箱仓库 Provider
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarFridgeRepository(isar);
});

/// 应用设置仓库 Provider
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) {
    throw StateError('Isar 未初始化完成；main.dart 应先 await isarProvider.future');
  }
  return IsarAppSettingsRepository(isar);
});
