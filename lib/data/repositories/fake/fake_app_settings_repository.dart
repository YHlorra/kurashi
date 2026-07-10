import 'dart:async';

import '../../models/app_settings.dart';
import '../app_settings_repository.dart';

/// 应用设置仓库的内存实现（阶段 1 / 桌面预览用）。
class FakeAppSettingsRepository implements AppSettingsRepository {
  final _controller = StreamController<AppSettings>.broadcast();
  AppSettings _settings = AppSettings(
    fridgeLogRetentionDays: 0,
    fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  Stream<AppSettings> watchSettings() {
    _controller.add(_settings);
    return _controller.stream;
  }

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    _controller.add(_settings);
  }

  @override
  Future<void> updateUserTags(List<String> tags) async {
    _settings = _settings.copyWithUserTags(tags);
    _controller.add(_settings);
  }

  @override
  Future<void> updateFridgeTags(List<String> tags) async {
    _settings = _settings.withFridgeTags(tags);
    _controller.add(_settings);
  }
}
