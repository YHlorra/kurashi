import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/app_settings.dart';
import 'package:kurashi/data/repositories/fake/fake_app_settings_repository.dart';

void main() {
  group('FakeAppSettingsRepository', () {
    late FakeAppSettingsRepository repo;

    setUp(() {
      repo = FakeAppSettingsRepository();
    });

    test('updateUserTags 写回后 getSettings 含 userTags', () async {
      await repo.updateUserTags(['A', 'B']);
      final settings = await repo.getSettings();
      expect(settings.userTags, ['A', 'B']);
    });

    test('默认值 fallback：settingsJson 为 null 时返回 5 预设', () async {
      final settings = await repo.getSettings();
      expect(settings.userTags, ['学习', '工作', '锻炼', '生活', '其他']);
    });

    test('updateUserTags 覆盖旧值', () async {
      await repo.updateUserTags(['X']);
      await repo.updateUserTags(['Y', 'Z']);
      final settings = await repo.getSettings();
      expect(settings.userTags, ['Y', 'Z']);
    });

    test('watchSettings 推送变更', () async {
      final stream = repo.watchSettings();
      final values = <AppSettings>[];
      final sub = stream.listen(values.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repo.updateUserTags(['新']);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      expect(values.last.userTags, ['新']);
    });
  });
}
