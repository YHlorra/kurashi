import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../data/models/fridge_change_log.dart';
import '../../../data/repositories/providers.dart';

/// 冰箱食材变更日志（倒序）。
///
/// 仓库层在 addItem / updateItem / removeItem / restoreItem 内部已经写日志，
/// 本 provider 仅做 stream → Widget 的胶水。
final fridgeChangeLogProvider = StreamProvider<List<FridgeChangeLog>>(
  (ref) => ref.watch(fridgeRepositoryProvider).watchChangeLog(),
);

/// 全局应用设置（单行 collection，id=0）。
///
/// 历史屏的 SegmentedControl + 设置 sheet 都 watch 本 provider；
/// 设置 sheet 修改后 `updateSettings()` 写 Isar → watchSettings → 通知本 provider。
final fridgeAppSettingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(fridgeRepositoryProvider).watchSettings(),
);

/// 冰箱食材记录红点 — 未读日志条数。
///
/// 规则：所有日志 id > `fridgeLogLastSeenId` 的条数。
/// `lastSeenId == null` 表示从未读过，全部现存日志都算未读。
///
/// ponytail：用 id（单调递增）而非 timestamp，避免毫秒撞档。
/// 即便全量清空日志后再写入新日志，新 id 必然 > 历史 max，自然从 0 unread 开始。
final fridgeUnreadCountProvider = Provider<int>((ref) {
  final logs = ref.watch(fridgeChangeLogProvider).valueOrNull ?? const [];
  final settings = ref.watch(fridgeAppSettingsProvider).valueOrNull;
  final lastSeenId = settings?.fridgeLogLastSeenId;
  if (logs.isEmpty) return 0;
  if (lastSeenId == null) return logs.length;
  return logs.where((e) => e.id > lastSeenId).length;
});
