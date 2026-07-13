import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/lunar/lunar_service.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/subscription.dart';
import '../../../data/models/todo_item.dart';
import '../../../data/repositories/providers.dart';

/// 今日事项聚合项 —— sealed class，三种类型
sealed class AgendaItem {
  const AgendaItem();
}

/// 代办事项
class TodoAgendaItem extends AgendaItem {
  final TodoItem item;
  const TodoAgendaItem(this.item);
}

/// 习惯
class HabitAgendaItem extends AgendaItem {
  final Habit habit;
  const HabitAgendaItem(this.habit);
}

/// 订阅锚点
class SubAgendaItem extends AgendaItem {
  final Subscription sub;
  const SubAgendaItem(this.sub);
}

/// 今日事项聚合 Provider
/// 组合 Todo + Habit + Subscription 三个 repo stream，
/// 输出按设计图固定顺序混排的 `List<AgendaItem>`（不是按 type 分组）
///
/// 阶段 2：已完成 todo 不出现在 agenda（立即消失），通过「已完成」chip 单独查看。
final todaysAgendaProvider = StreamProvider<List<AgendaItem>>((ref) {
  final todoRepo = ref.watch(todoRepositoryProvider);
  final habitRepo = ref.watch(habitRepositoryProvider);
  final subRepo = ref.watch(subscriptionRepositoryProvider);

  final controller = StreamController<List<AgendaItem>>.broadcast();

  List<TodoItem> todos = const [];
  List<Habit> habits = const [];
  List<Subscription> subs = const [];
  bool todoReady = false;
  bool habitReady = false;
  bool subReady = false;

  void emit() {
    // Wait until all three streams have emitted at least once.
    if (!todoReady || !habitReady || !subReady) return;
    controller.add(buildAgenda(todos, habits, subs, today: DateTime.now()));
  }

  final s1 = todoRepo.watchAll().listen((v) {
    todos = v;
    todoReady = true;
    emit();
  });
  final s2 = habitRepo.watchAll().listen((v) {
    habits = v;
    habitReady = true;
    emit();
  });
  final s3 = subRepo.watchAll().listen((v) {
    subs = v;
    subReady = true;
    emit();
  });

  ref.onDispose(() {
    s1.cancel();
    s2.cancel();
    s3.cancel();
    controller.close();
  });

  return controller.stream;
});

/// 已完成的 todo 列表（按 completedAt 倒序）—— 阶段 2「已完成」chip 数据源。
final completedTodosProvider = StreamProvider<List<TodoItem>>((ref) {
  final todoRepo = ref.watch(todoRepositoryProvider);

  final controller = StreamController<List<TodoItem>>.broadcast();
  List<TodoItem> todos = const [];

  void emit() {
    final done = todos.where((t) => t.completed).toList();
    done.sort((a, b) {
      // 已完成时间倒序（最新在前）；null 排最后。
      final ax = a.completedAt;
      final bx = b.completedAt;
      if (ax == null && bx == null) return 0;
      if (ax == null) return 1;
      if (bx == null) return -1;
      return bx.compareTo(ax);
    });
    controller.add(List.unmodifiable(done));
  }

  final s = todoRepo.watchAll().listen((v) {
    todos = v;
    emit();
  });

  ref.onDispose(() {
    s.cancel();
    controller.close();
  });

  return controller.stream;
});

/// 按设计图固定顺序构建 agenda 列表
///
/// [today] 用于计算订阅锚点的剩余天数过滤；默认 DateTime.now()。
///
/// 顺序：
/// 1. 设计图固定 7 项（todo + habit 交错）；
/// 2. 追加未在固定顺序中的代办 / 习惯（用户新建项）；
/// 3. 追加所有 active 订阅锚点，按 daysUntil 升序、过滤 ≥0 且 ≤365 天。
///
/// 旧的硬编码 sub 槽位（仅 sub 6 七夕 / sub 10 爸爸生日）会让其它已订
/// 节日/账单/生日"消失"—— 现按 active + daysUntil 注入，订阅一项就显示一项。
/// 上限 365 天是为了让"今年 + 明年元宵"这种隔年节日也能一并呈现。
///
/// 内联宽限期（grace period）：completed todo 不立即消失，而是以划线灰态
/// 内联保留在「今日」主列表底部，直到跨过 completedAt 的次日（midnight 后）
/// 才从主列表移除、仅存于「已完成」视图（可恢复、绝不删除）。
/// 判定同日复用 Flutter SDK 的 [DateUtils.isSameDay]（对 null 直接返回 false，
/// 正好等价于「completedAt == null → 不保留」规则）。
List<AgendaItem> buildAgenda(
  List<TodoItem> todos,
  List<Habit> habits,
  List<Subscription> subs, {
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  final result = <AgendaItem>[];

  // active todo（未完成）—— 主列表的主体。
  final activeTodos = todos.where((t) => !t.completed).toList();
  // 内联宽限期：仅"今天完成"的 todo 仍内联保留（置底）；
  // completedAt == null 的遗留数据视为"非当日完成" → 不保留。
  final completedTodayTodos = todos
      .where((t) => t.completed && DateUtils.isSameDay(t.completedAt, now))
      .toList();

  // 1. 追加所有 active 代办与习惯（按创建顺序）
  for (final t in activeTodos) {
    result.add(TodoAgendaItem(t));
  }
  for (final h in habits) {
    result.add(HabitAgendaItem(h));
  }

  // 3. 订阅锚点：active + daysUntil ∈ [0, 365]，按距今天数升序。
  final anchorSubs = <Subscription>[];
  for (final s in subs) {
    if (!s.active) continue;
    final d = lunarService.daysUntil(s, today: now);
    if (d < 0 || d > 365) continue;
    anchorSubs.add(s);
  }
  anchorSubs.sort(
    (a, b) => lunarService
        .daysUntil(a, today: now)
        .compareTo(lunarService.daysUntil(b, today: now)),
  );
  for (final s in anchorSubs) {
    result.add(SubAgendaItem(s));
  }

  // 内联宽限期：今日完成项置底（active / habits / subs 之后）。
  for (final t in completedTodayTodos) {
    result.add(TodoAgendaItem(t));
  }

  return result;
}
