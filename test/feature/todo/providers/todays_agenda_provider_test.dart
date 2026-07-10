// todays_agenda_provider 单测
//
// 覆盖 3 个核心场景：
//   2.1 固定顺序混排（仅 todo + habit）+ active 订阅按 daysUntil 升序追加；
//   2.2 daysUntil ≤ 365 过滤：超 365 天的 active sub 不出现在 agenda；
//   2.3 回归测试：订了多个 active festival，agenda 不应该只显示 1 条。
//
// 修复（2026-07-08）：订阅不再硬编码到 _agendaOrder；所有 active 订阅按
// daysUntil 升序追加。修复前：硬编码只列 sub 6 / sub 10，其它已订节日
// 全部消失（用户实际 bug：订了中西方节日，agenda 只显示 1 个七夕）。
//
// 阶段 2 修复（2026-07-10）：completed todo 从 agenda 提前过滤。mock 中
// todo id=3「整理上周复盘」completed=true 被过滤，所以固定顺序 7 项只
// 渲染 6 项（剩余 1 个槽位由 active sub 占用）。测试断言已相应更新。
//
// 约定：
// - Provider 是 StreamProvider，三个 repo 各 watchAll() 一次 → controller 共 emit 3 次。
//   用 container.listen 收集 AsyncValue emits，等满 3 次后取最后一项。
// - Fake 默认 active subs（≤365 天）随今日变动；测试以结构断言而非具体长度为主。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/core/lunar/lunar_service.dart';
import 'package:kurashi/data/models/subscription.dart';
import 'package:kurashi/data/repositories/fake/fake_habit_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_subscription_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_todo_repository.dart';
import 'package:kurashi/data/repositories/providers.dart';
import 'package:kurashi/feature/todo/providers/todays_agenda_provider.dart';

void main() {
  group('todaysAgendaProvider', () {
    /// 等待 StreamProvider 三连 emit 完成后取最后一条 agenda。
    Future<List<AgendaItem>> collectAgenda(ProviderContainer container) async {
      final emits = <List<AgendaItem>>[];
      final sub = container.listen(
        todaysAgendaProvider,
        (_, next) {
          if (next.hasValue) emits.add(next.requireValue);
        },
        fireImmediately: true,
      );
      for (var i = 0; i < 100 && emits.length < 3; i++) {
        await Future.delayed(Duration.zero);
      }
      sub.close();
      return emits.last;
    }

    // ── 2.1 固定顺序混排（todo + habit）+ active subs 升序追加 ─────────
    test('2.1 硬编码 todo/habit 交错（completed todo 过滤）+ active subs 升序追加',
        () async {
      final container = ProviderContainer(overrides: [
        todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
        habitRepositoryProvider.overrideWithValue(FakeHabitRepository()),
        subscriptionRepositoryProvider
            .overrideWithValue(FakeSubscriptionRepository()),
      ]);
      addTearDown(container.dispose);

      final agenda = await collectAgenda(container);

      // 阶段 2：mock todo id=3「整理上周复盘」completed=true 被过滤，
      // 因此前 7 项硬编码槽位只渲染 6 项 todo/habit + 1 项 active sub。
      // 顺序：todo1 → todo2 → habit1 → habit2 → todo4 → habit3 → sub...
      // （todo3 跳过，后面的习惯 / 代办依次前移）
      expect(agenda.length, greaterThanOrEqualTo(6));
      expect(agenda[0], isA<TodoAgendaItem>());
      expect((agenda[0] as TodoAgendaItem).item.id, 1);

      expect(agenda[1], isA<TodoAgendaItem>());
      expect((agenda[1] as TodoAgendaItem).item.id, 2);

      expect(agenda[2], isA<HabitAgendaItem>());
      expect((agenda[2] as HabitAgendaItem).habit.id, 1);

      // todo 3 已完成 → 跳过；槽位被 habit 2 占用
      expect(agenda[3], isA<HabitAgendaItem>());
      expect((agenda[3] as HabitAgendaItem).habit.id, 2);

      expect(agenda[4], isA<TodoAgendaItem>());
      expect((agenda[4] as TodoAgendaItem).item.id, 4);

      expect(agenda[5], isA<HabitAgendaItem>());
      expect((agenda[5] as HabitAgendaItem).habit.id, 3);

      // active subs 升序追加：Fake 默认 active 心丝虫（interval=30,
      // createdAt now-10 → next=now+20）必入；其它多数 interval 太大 > 365。
      final appended = agenda.skip(6).whereType<SubAgendaItem>().toList();
      expect(
        appended.any((s) => s.sub.title.contains('心丝虫')),
        isTrue,
        reason: '心丝虫预防（interval=30）必在 365 天内',
      );

      // 升序：第一个 appended 的 daysUntil 不大于最后一个的 daysUntil
      if (appended.length >= 2) {
        final firstDays =
            lunarService.daysUntil(appended.first.sub, today: DateTime.now());
        final lastDays =
            lunarService.daysUntil(appended.last.sub, today: DateTime.now());
        expect(firstDays, lessThanOrEqualTo(lastDays),
            reason: 'active subs 应按 daysUntil 升序');
      }

      // inactive 订阅不出现：默认 sub 6 七夕（active=false）不应出现在 agenda
      expect(
        agenda.whereType<SubAgendaItem>().any((s) => s.sub.id == 6),
        isFalse,
        reason: 'inactive sub 不应出现',
      );

      // 阶段 2 关键断言：completed todo 不应出现在 agenda
      expect(
        agenda.whereType<TodoAgendaItem>().any((t) => t.item.completed),
        isFalse,
        reason: '已完成 todo 应从 agenda 过滤',
      );
    });

    // ── 2.2 daysUntil ≤ 365 过滤 ──────────────────────────────────────
    test('2.2 daysUntil ≤ 365 过滤：active 但超 365 天的 sub 不出现', () async {
      // 策略：新增一个 active 但 next 锚点超 365 天的 sub，应被 _buildAgenda 过滤。
      // 用 intervalDays=400 + createdAt=now：next = now + 400 > 365（365 天 cap 过滤掉）。
      // solar/lunar 月日锚点的"次年同月日"最多 365 天，无法稳定构造 >365，
      // 所以这里用 intervalDays 滚动模式。
      final subRepo = FakeSubscriptionRepository();
      await subRepo.addSubscription(
        Subscription(
          id: 999,
          title: '远期节日测试',
          type: SubType.homeMaintenance,
          calendar: Calendar.solar,
          mode: TriggerMode.intervalDays,
          intervalDays: 400,
          leadDays: 0,
          active: true,
          createdAt: DateTime.now(),
        ),
      );

      // 测试前置条件：确认 sub 999 的 daysUntil > 365
      final subsList = await subRepo.watchAll().first;
      final added = subsList.firstWhere((s) => s.id == 999);
      final daysUntil = lunarService.daysUntil(added, today: DateTime.now());
      expect(
        daysUntil,
        greaterThan(365),
        reason: 'intervalDays=400 + createdAt=now 必在 365 天后',
      );

      final container = ProviderContainer(overrides: [
        todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
        habitRepositoryProvider.overrideWithValue(FakeHabitRepository()),
        subscriptionRepositoryProvider.overrideWithValue(subRepo),
      ]);
      addTearDown(container.dispose);

      final agenda = await collectAgenda(container);

      // sub 999（active=true 但 daysUntil > 365）不应出现在 agenda
      expect(
        agenda.whereType<SubAgendaItem>().any((s) => s.sub.id == 999),
        isFalse,
        reason: 'daysUntil > 365 的 active sub 应被过滤',
      );
    });

    // ── 2.3 回归：订一个就显示一个（不复现原 bug） ────────────────────
    test('2.3 回归：订多个 active festival，agenda 全部依次显示（不会只剩一个）',
        () async {
      // 模拟用户：用 setActiveByType 把所有 cnFestival + westernFestival 全订上。
      final subRepo = FakeSubscriptionRepository();
      await subRepo.setActiveByType(SubType.cnFestival, true);
      await subRepo.setActiveByType(SubType.westernFestival, true);

      final subsList = await subRepo.watchAll().first;
      final activeCn = subsList
          .where((s) => s.type == SubType.cnFestival && s.active)
          .length;
      final activeWestern = subsList
          .where((s) => s.type == SubType.westernFestival && s.active)
          .length;
      expect(activeCn, 9, reason: 'cnFestival 共 9 项预设');
      expect(activeWestern, 6, reason: 'westernFestival 共 6 项预设');

      final container = ProviderContainer(overrides: [
        todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
        habitRepositoryProvider.overrideWithValue(FakeHabitRepository()),
        subscriptionRepositoryProvider.overrideWithValue(subRepo),
      ]);
      addTearDown(container.dispose);

      final agenda = await collectAgenda(container);

      final festivalItems = agenda
          .whereType<SubAgendaItem>()
          .where((s) =>
              s.sub.type == SubType.cnFestival ||
              s.sub.type == SubType.westernFestival)
          .toList();

      // 修复前：硬编码只列 sub 6（七夕），即使所有 festival 都 active 也只显示 1 条。
      // 修复后：daysUntil ≤ 365 的所有 active festival 都会出现，且数量应该 > 1。
      expect(
        festivalItems.length,
        greaterThan(1),
        reason: '订了所有 festival，agenda 里应该不止一个',
      );
    });
  });
}
