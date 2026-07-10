import 'dart:convert';

/// Todo 自定义标签配置 —— 存在 AppSettings.settingsJson 中。
///
/// 字段：
/// - [customTags]: 用户手动添加的自定义标签列表（可空）。
/// - [deletedPresets]: 被用户"软删除"的内置 preset 标签集合。
///   软删除而非硬删除是为了支持 SnackBar 撤销；重新显示 = 从集合移除。
class TagSettings {
  final List<String> customTags;
  final Set<String> deletedPresets;

  const TagSettings({
    this.customTags = const [],
    this.deletedPresets = const {},
  });

  /// 从 [AppSettings.settingsJson] 反序列化。失败 / null / 空 → 默认空配置。
  factory TagSettings.fromJson(String? json) {
    if (json == null || json.isEmpty) return const TagSettings();
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return TagSettings(
        customTags: List<String>.from(
          (m['customTags'] as List?)?.cast<String>() ?? const [],
        ),
        deletedPresets: Set<String>.from(
          (m['deletedPresets'] as List?)?.cast<String>() ?? const [],
        ),
      );
    } catch (_) {
      // 解析失败兜底为空配置 —— 宁可丢数据也不让 app 崩
      return const TagSettings();
    }
  }

  /// 序列化为 JSON 字符串，写回 AppSettings.settingsJson。
  String toJson() => jsonEncode({
        'customTags': customTags,
        'deletedPresets': deletedPresets.toList(),
      });

  TagSettings copyWith({
    List<String>? customTags,
    Set<String>? deletedPresets,
  }) {
    return TagSettings(
      customTags: customTags ?? this.customTags,
      deletedPresets: deletedPresets ?? this.deletedPresets,
    );
  }
}

/// Todo 标签内置 preset —— 5 项，不参与持久化（写死常量）。
///
/// 设计意图：preset 是产品定义的核心分类，用户不应能"硬删"。
/// 用户能做的只是 [TagSettings.deletedPresets] 软删除（隐藏 + 可撤销）。
const List<String> kTodoTagPresets = [
  '学习',
  '工作',
  '锻炼',
  '生活',
  '其他',
];