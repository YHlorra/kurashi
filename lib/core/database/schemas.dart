import 'package:isar_plus/isar_plus.dart';

import '../../data/models/todo_item.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_checkin.dart';
import '../../data/models/subscription.dart';
import '../../data/models/fridge_item.dart';
import '../../data/models/fridge_change_log.dart';
import '../../data/models/app_settings.dart';

/// 全部 Isar @collection 实体的 Schema 列表。
///
/// Task 2 完成 model 迁移并跑 build_runner 生成 .g.dart 后，
/// TodoItemSchema / HabitSchema / HabitCheckinSchema / SubscriptionSchema /
/// FridgeItemSchema 常量才存在；此文件作为 isarProvider 的唯一 schemas 入口。
/// 阶段 2.x 追加 FridgeChangeLogSchema / AppSettingsSchema。
final schemas = <IsarGeneratedSchema>[
  TodoItemSchema,
  HabitSchema,
  HabitCheckinSchema,
  SubscriptionSchema,
  FridgeItemSchema,
  FridgeChangeLogSchema,
  AppSettingsSchema,
];
