// FakeSubscriptionRepository 单测（Task 1.3）
//
// 覆盖 5 个核心场景：
//   1.3.a addSubscription：新增后 watchAll 含它
//   1.3.b deleteSubscription：删除后列表不含
//   1.3.c setActiveByType(cnFestival, true)：批量生成 9 项中国节日 Subscription
//   1.3.d setActiveByType(westernFestival, true)：批量生成 6 项西方节日
//   1.3.e setActiveByType(cnFestival, false)：批量设 active=false（不删除）
//
// 约定：
// - mock 数据已含 9 项 cnFestival（id 1-9，title 为简称如"元宵"/"清明"）
// - cn 节日预设 9 项 title 为全称如"元宵节"/"清明节"
// - setActiveByType(true) 的 upsert 策略：同 type+同 title 视为同一条记录
//   故"春节"/"七夕"匹配现有，"元宵节"/"清明节"等不匹配则新建
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/subscription.dart';
import 'package:kurashi/data/repositories/fake/fake_subscription_repository.dart';

void main() {
  late FakeSubscriptionRepository repo;

  setUp(() {
    repo = FakeSubscriptionRepository();
  });

  group('FakeSubscriptionRepository', () {
    // ── 1.3.a addSubscription：新增后 watchAll 含它 ───────────────────
    test('addSubscription：新增后 watchAll 含它', () async {
      final sub = Subscription(
        title: '每周复盘',
        type: SubType.custom,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 7,
        leadDays: 0,
        active: true,
        createdAt: DateTime(2026, 7, 6),
      );
      final id = await repo.addSubscription(sub);

      final list = await repo.watchAll().first;
      expect(list.any((s) => s.id == id), isTrue);
      expect(list.firstWhere((s) => s.id == id).title, '每周复盘');
    });

    // ── 1.3.b deleteSubscription：删除后列表不含 ──────────────────────
    test('deleteSubscription：删除后列表不含', () async {
      await repo.deleteSubscription(1);
      final list = await repo.watchAll().first;
      expect(list.any((s) => s.id == 1), isFalse);
    });

    // ── 1.3.c setActiveByType(cnFestival, true)：批量生成 9 项中国节日 ─
    test('setActiveByType(cnFestival, true)：批量生成 9 项中国节日预设', () async {
      await repo.setActiveByType(SubType.cnFestival, true);

      final list = await repo.watchAll().first;
      // cn 节日预设 9 项 title 全部存在（含已匹配现有简称 + 新建全称）
      const expectedTitles = [
        '元旦', '春节', '元宵节', '清明节', '端午节',
        '七夕', '中秋节', '国庆节', '腊八节',
      ];
      for (final title in expectedTitles) {
        expect(
          list.any((s) => s.type == SubType.cnFestival && s.title == title),
          isTrue,
          reason: '缺少 cnFestival 预设：$title',
        );
      }
      // 所有 cnFestival 项均 active=true
      final cnFestivals = list.where((s) => s.type == SubType.cnFestival);
      for (final s in cnFestivals) {
        expect(s.active, isTrue, reason: '${s.title} 应 active=true');
      }
    });

    // ── 1.3.d setActiveByType(westernFestival, true)：批量生成 6 项 ────
    test('setActiveByType(westernFestival, true)：批量生成 6 项西方节日', () async {
      await repo.setActiveByType(SubType.westernFestival, true);

      final list = await repo.watchAll().first;
      const expectedTitles = [
        '情人节', '母亲节', '父亲节', '万圣节', '感恩节', '圣诞节',
      ];
      // mock 数据初始 0 项 westernFestival，setActiveByType 后应新增 6 项
      final westerns = list.where((s) => s.type == SubType.westernFestival).toList();
      expect(westerns.length, 6);
      for (final title in expectedTitles) {
        expect(
          westerns.any((s) => s.title == title),
          isTrue,
          reason: '缺少 westernFestival 预设：$title',
        );
      }
      for (final s in westerns) {
        expect(s.active, isTrue, reason: '${s.title} 应 active=true');
      }
    });

    // ── 1.3.e setActiveByType(cnFestival, false)：批量设 active=false ──
    test('setActiveByType(cnFestival, false)：批量设 active=false（不删除）', () async {
      // 先全部激活，再反置
      await repo.setActiveByType(SubType.cnFestival, true);
      final listAfterOn = await repo.watchAll().first;
      final cnCountAfterOn =
          listAfterOn.where((s) => s.type == SubType.cnFestival).length;

      await repo.setActiveByType(SubType.cnFestival, false);
      final listAfterOff = await repo.watchAll().first;
      final cnFestivalsAfterOff =
          listAfterOff.where((s) => s.type == SubType.cnFestival).toList();

      // 数量不变（仅改 active 标志，不删除）
      expect(cnFestivalsAfterOff.length, cnCountAfterOn);
      // 全部 active=false
      for (final s in cnFestivalsAfterOff) {
        expect(s.active, isFalse, reason: '${s.title} 应 active=false');
      }
    });
  });
}
