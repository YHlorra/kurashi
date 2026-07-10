import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/app_settings.dart';
import 'package:kurashi/data/repositories/fake/fake_app_settings_repository.dart';

void main() {
  group('FakeAppSettingsRepository', () {
    late FakeAppSettingsRepository repo;
    setUp(() => repo = FakeAppSettingsRepository());

    test('getSettings returns default', () async {
      final settings = await repo.getSettings();
      expect(settings, isNotNull);
    });

    test('updateSettings + getSettings roundtrip', () async {
      final updated = AppSettings(fridgeLogRetentionDays: 30, fridgeLogLastCleanupAt: DateTime(2026, 7, 10));
      await repo.updateSettings(updated);
      final result = await repo.getSettings();
      expect(result.fridgeLogRetentionDays, 30);
    });

    test('watchSettings emits on subscription', () async {
      final value = await repo.watchSettings().first;
      expect(value, isNotNull);
    });
  });
}
