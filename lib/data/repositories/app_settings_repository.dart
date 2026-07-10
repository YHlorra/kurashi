import '../models/app_settings.dart';

/// 应用设置仓库抽象接口。
abstract class AppSettingsRepository {
  /// 监听设置变更（始终返回 id=0 的单行）。
  Stream<AppSettings> watchSettings();

  /// 获取当前设置（id=0），不存在则返回默认值。
  Future<AppSettings> getSettings();

  /// 写回完整设置实例（upsert）。
  Future<void> updateSettings(AppSettings settings);

  /// 便捷方法：仅更新 userTags 字段。
  Future<void> updateUserTags(List<String> tags);
}
