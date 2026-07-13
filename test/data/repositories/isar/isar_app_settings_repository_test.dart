import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:kurashi/core/database/schemas.dart';
import 'package:kurashi/data/models/app_settings.dart';
import 'package:kurashi/data/repositories/isar/isar_app_settings_repository.dart';

late Isar? isar;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final dir = Directory.systemTemp.createTempSync('test_isar_settings');
      isar = Isar.open(schemas: schemas, directory: dir.path);
    } catch (_) {
      // Isar 原生库在 Windows 主机单元测试中不可用 → 跳过
      isar = null;
    }
  });
  tearDownAll(() {
    isar?.close();
    try {
      if (isar != null)
        Directory('${isar!.directory}').deleteSync(recursive: true);
    } catch (_) {}
  });

  group('AppSettingsRepository — 用户行为', () {
    test('首次打开应用 → 设置返回默认值', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarAppSettingsRepository(isar!);
      final settings = await repo.getSettings();
      expect(settings, isNotNull);
      expect(settings.fridgeLogRetentionDays, 0);
    });

    test('用户修改日志保留天数 → 保存后读取一致', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarAppSettingsRepository(isar!);
      final updated = AppSettings(
        fridgeLogRetentionDays: 30,
        fridgeLogLastCleanupAt: DateTime(2026, 7, 10),
      );
      await repo.updateSettings(updated);
      final result = await repo.getSettings();
      expect(result.fridgeLogRetentionDays, 30);
    });

    test('用户监听设置变更 → 设置变化时收到通知', () async {
      if (isar == null) return markTestSkipped('Isar 原生库不可用');
      final repo = IsarAppSettingsRepository(isar!);
      final emitted = <AppSettings>[];
      final sub = repo.watchSettings().listen(emitted.add);
      await Future.delayed(const Duration(milliseconds: 50));
      await repo.updateSettings(
        AppSettings(
          fridgeLogRetentionDays: 7,
          fridgeLogLastCleanupAt: DateTime.now(),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emitted.length, greaterThanOrEqualTo(1));
      expect(emitted.last.fridgeLogRetentionDays, 7);
      await sub.cancel();
    });
  });
}
