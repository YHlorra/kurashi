import 'dart:convert';

import 'package:isar_plus/isar_plus.dart';

part 'app_settings.g.dart';

/// 全局设置（单行 collection，业务永远用 `id = 0`）。
///
/// 阶段 2.x：用于冰箱食材记录的保留时长 + 上次自动清理时间戳。
/// 若不存在由 isar_provider 在首次启动时 seed 默认值
/// `{fridgeLogRetentionDays: 0, fridgeLogLastCleanupAt: now}`。
///
/// 阶段 3.x：新增 `settingsJson` —— 应用级 JSON blob，用于跨域共享的轻量配置
/// （如 Todo 自定义标签列表）。避免为单一用例新增 Isar collection。
@collection
class AppSettings {
  final int id;

  /// 冰箱食材记录保留天数。
  /// `0` = 永久保留；`30` = 每月自动清理 30 天前的记录；`90` = 每季度自动清理 90 天前的记录。
  final int fridgeLogRetentionDays;

  /// 上次自动清理时间戳（用于跨月 / 跨季度判定，避免重复清理）。
  /// 策略为永久时不读此字段。
  final DateTime fridgeLogLastCleanupAt;

  /// 应用级 JSON 配置 blob（如 Todo 自定义标签列表）。null 表示未初始化。
  /// 写入前需先 [jsonEncode]，读取时用对应领域 helper（如 TagSettings.fromJson）解析。
  final String? settingsJson;

  const AppSettings({
    this.id = 0,
    required this.fridgeLogRetentionDays,
    required this.fridgeLogLastCleanupAt,
    this.settingsJson,
  });

  AppSettings copyWith({
    int? id,
    int? fridgeLogRetentionDays,
    DateTime? fridgeLogLastCleanupAt,
    String? settingsJson,
  }) {
    return AppSettings(
      id: id ?? this.id,
      fridgeLogRetentionDays:
          fridgeLogRetentionDays ?? this.fridgeLogRetentionDays,
      fridgeLogLastCleanupAt:
          fridgeLogLastCleanupAt ?? this.fridgeLogLastCleanupAt,
      settingsJson: settingsJson ?? this.settingsJson,
    );
  }

  /// Todo 标签预设（硬编码，不参与持久化）。
  static const _kDefaultTags = ['学习', '工作', '锻炼', '生活', '其他'];

  /// 解码 `settingsJson.userTags` 返回当前可用标签列表。
  ///
  /// - `settingsJson` 为 null 或不含 `userTags` 键 → 返回 5 项预设。
  /// - 否则返回 JSON 数组解码结果。
  List<String> get userTags {
    if (settingsJson == null || settingsJson!.isEmpty) {
      return List<String>.from(_kDefaultTags);
    }
    try {
      final m = jsonDecode(settingsJson!) as Map<String, dynamic>;
      final raw = m['userTags'];
      if (raw is List) {
        return List<String>.from(raw.cast<String>());
      }
      return List<String>.from(_kDefaultTags);
    } on FormatException {
      return List<String>.from(_kDefaultTags);
    }
  }

  /// 返回新实例，其 `settingsJson` 含 `userTags: tags`，其余字段保留。
  AppSettings copyWithUserTags(List<String> tags) {
    Map<String, dynamic> base;
    if (settingsJson == null || settingsJson!.isEmpty) {
      base = {};
    } else {
      try {
        base = Map<String, dynamic>.from(jsonDecode(settingsJson!));
      } on FormatException {
        base = {};
      }
    }
    base['userTags'] = tags;
    return copyWith(settingsJson: jsonEncode(base));
  }

  /// 自定义冰箱标签（蔬菜/水果/肉类之外的），持久化到 settingsJSON
  List<String> get fridgeTags {
    final raw = settingsJson;
    if (raw == null || raw.isEmpty) return [];
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final list = m['fridgeTags'];
      if (list is List) return list.cast<String>();
      return [];
    } catch (_) {
      return [];
    }
  }

  /// 返回新实例，其 `settingsJson` 含 `fridgeTags: tags`，其余字段保留。
  AppSettings withFridgeTags(List<String> tags) {
    final raw = settingsJson;
    Map<String, dynamic> base;
    if (raw == null || raw.isEmpty) {
      base = {};
    } else {
      try {
        base = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        base = {};
      }
    }
    base['fridgeTags'] = tags;
    return copyWith(settingsJson: jsonEncode(base));
  }

  /// 冰箱食材记录红点 — 用户最近一次"已读"的日志 id。
  ///
  /// `null` = 从未读过（所有现存日志都算未读）。
  /// 写入：`copyWithFridgeLogLastSeenId(int? id)`
  /// 读取：`fridgeLogLastSeenId`
  ///
  /// ponytail: 用 id（单调递增）而非 timestamp，避免毫秒撞档。
  /// Isar autoIncrement 不会回退；即便全量清空日志后再写入新日志，
  /// 新 id 必然 > 历史 max，自然从 0 unread 开始。
  int? get fridgeLogLastSeenId {
    final raw = settingsJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final v = m['fridgeLogLastSeenId'];
      if (v is int) return v;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 返回新实例，其 `settingsJson` 含 `fridgeLogLastSeenId: id`，其余字段保留。
  AppSettings copyWithFridgeLogLastSeenId(int? id) {
    final raw = settingsJson;
    Map<String, dynamic> base;
    if (raw == null || raw.isEmpty) {
      base = {};
    } else {
      try {
        base = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        base = {};
      }
    }
    if (id == null) {
      base.remove('fridgeLogLastSeenId');
    } else {
      base['fridgeLogLastSeenId'] = id;
    }
    return copyWith(settingsJson: jsonEncode(base));
  }
}
