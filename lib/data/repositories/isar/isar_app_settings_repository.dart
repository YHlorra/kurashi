import 'package:isar_plus/isar_plus.dart';

import '../../models/app_settings.dart';
import '../app_settings_repository.dart';

/// 应用设置仓库的 Isar 实现（阶段 2.1 替换 FakeAppSettingsRepository）。
// TODO: integration test on real device
class IsarAppSettingsRepository implements AppSettingsRepository {
  final Isar isar;

  IsarAppSettingsRepository(this.isar);

  @override
  Stream<AppSettings> watchSettings() {
    return isar.appSettings
        .watchLazy(fireImmediately: true)
        .map((_) => isar.appSettings.get(0) ?? _defaultSettings);
  }

  @override
  Future<AppSettings> getSettings() async {
    return isar.appSettings.get(0) ?? _defaultSettings;
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    return isar.write((isar) {
      isar.appSettings.put(settings);
    });
  }

  @override
  Future<void> updateUserTags(List<String> tags) async {
    return isar.write((isar) {
      final current = isar.appSettings.get(0) ?? _defaultSettings;
      final updated = current.copyWithUserTags(tags);
      isar.appSettings.put(updated);
    });
  }

  @override
  Future<void> updateFridgeTags(List<String> tags) async {
    return isar.write((isar) {
      final settings = isar.appSettings.get(0) ?? _defaultSettings;
      isar.appSettings.put(settings.withFridgeTags(tags));
    });
  }

  static AppSettings get _defaultSettings => AppSettings(
        fridgeLogRetentionDays: 0,
        fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
}
