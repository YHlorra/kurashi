import 'dart:async';

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

/// 设计图固定顺序：(类型, id) 列表。
///
/// 仅 todo + habit 交错（7 项）。订阅锚点不写死：所有 active 订阅按
/// daysUntil 升序、最多 60 天，追加到 agenda 末尾；硬编码 sub 会让其它已订
/// 节日/账单/生日被漏掉（典型症状：只显示七夕）。
/// 严格对应 mobile-android-todo.html 列表 9 项中 todo/habit 部分。
const _agendaOrder = <(String, int)>[
  ('todo', 1), // 回邮件给导师（截止 今天 18:00）
  ('todo', 2), // 买牛奶 + 鸡蛋（截止 明天，warn）
  ('habit', 1), // 阅读 30 分钟（2/3，绿环）
  ('todo', 3), // 整理上周复盘（已完成 → 阶段 2 已从 agenda 过滤，仍保留为设计文档）
  ('habit', 2), // 喝 8 杯水（7/7，黑环）
  ('todo', 4), // 续保家庭意外险（截止 7/2，warn）
  ('habit', 3), // 跑步 5km（5/7，琥珀环）
];

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
    controller.add(_buildAgenda(todos, habits, subs, today: DateTime.now()));
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
/// 阶段 2：过滤在函数顶部，提前剔除 completed todo —— `_agendaOrder` 中
/// (todo, 3) "整理上周复盘" 已完成，会被自然忽略；catch-all 也不会重添加。
List<AgendaItem> _buildAgenda(
  List<TodoItem> todos,
  List<Habit> habits,
  List<Subscription> subs, {
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  final result = <AgendaItem>[];
  final usedTodoIds = <int>{};
  final usedHabitIds = <int>{};

  // 阶段 2：提前过滤掉已完成 todo —— 不再出现在今日视图。
  final activeTodos = todos.where((t) => !t.completed).toList();

  // 1. 按设计图固定顺序填入（仅 todo + habit）
  for (final (type, id) in _agendaOrder) {
    switch (type) {
      case 'todo':
        final t = _findTodo(activeTodos, id);
        if (t != null) {
          result.add(TodoAgendaItem(t));
          usedTodoIds.add(id);
        }
      case 'habit':
        final h = _findHabit(habits, id);
        if (h != null) {
          result.add(HabitAgendaItem(h));
          usedHabitIds.add(id);
        }
      case 'sub':
        // 订阅不再硬编码 —— 下方统一按 active + daysUntil 追加。
        break;
    }
  }

  // 2. 追加未在固定顺序中的代办与习惯（新增项追加到末尾）
  for (final t in activeTodos) {
    if (!usedTodoIds.contains(t.id)) result.add(TodoAgendaItem(t));
  }
  for (final h in habits) {
    if (!usedHabitIds.contains(h.id)) result.add(HabitAgendaItem(h));
  }

  // 3. 订阅锚点：active + daysUntil ∈ [0, 365]，按距今天数升序。
  final anchorSubs = <Subscription>[];
  for (final s in subs) {
    if (!s.active) continue;
    final d = lunarService.daysUntil(s, today: now);
    if (d < 0 || d > 365) continue;
    anchorSubs.add(s);
  }
  anchorSubs.sort((a, b) =>
      lunarService.daysUntil(a, today: now)
          .compareTo(lunarService.daysUntil(b, today: now)));
  for (final s in anchorSubs) {
    result.add(SubAgendaItem(s));
  }

  return result;
}

TodoItem? _findTodo(List<TodoItem> items, int id) {
  for (final t in items) {
    if (t.id == id) return t;
  }
  return null;
}

Habit? _findHabit(List<Habit> items, int id) {
  for (final h in items) {
    if (h.id == id) return h;
  }
  return null;
}
