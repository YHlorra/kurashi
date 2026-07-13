import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';

import '../../../core/designsystem/app_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/lunar/lunar_service.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../data/models/todo_item.dart';
import '../../../data/models/habit.dart';
import '../../../data/repositories/providers.dart';
import '../../todo/providers/todays_agenda_provider.dart';
import '../../todo/widgets/habit_tile.dart';
import '../../todo/widgets/sub_anchor_tile.dart';
import '../../todo/widgets/todo_item_tile.dart';
import 'add_todo_page.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  /// 当前激活的 chip：all / todo / habit / sub / completed
  String _activeChip = 'all';

  /// 显示新增页面
  void _showAddPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTodoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 「已完成」chip 是 view switch：直接渲染 _CompletedTodosView，
    // 完全绕过 _filterByChip 和 _buildClustered（per oracle FINDING 7）。
    if (_activeChip == 'completed') {
      return _CompletedTodosView(
        onBack: () => setState(() => _activeChip = 'all'),
      );
    }

    final agendaAsync = ref.watch(todaysAgendaProvider);
    final completedCount =
        ref.watch(completedTodosProvider).valueOrNull?.length ?? 0;
    final now = DateTime.now();
    final weekStart = _weekStart(now);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        toolbarHeight: 52,
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '今日',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
            color: AppColors.fg,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: agendaAsync.when(
        data: (items) {
          // 计算各类型计数
          final counts = _countByType(items);
          // 按 chip 筛选
          final filtered = _filterByChip(items, _activeChip);

          if (filtered.isEmpty) {
            return Column(
              children: [
                _ChipsRow(
                  active: _activeChip,
                  counts: counts,
                  completedCount: completedCount,
                  onChanged: (v) => setState(() => _activeChip = v),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '还没有事项',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.fg,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点 ＋ 添加',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // 按 dueDate 聚类：今天 / 明天 / X月X日
          final clustered = _buildClustered(filtered, now, weekStart);

          return Column(
            children: [
              // chips 行
              _ChipsRow(
                active: _activeChip,
                counts: counts,
                completedCount: completedCount,
                onChanged: (v) => setState(() => _activeChip = v),
              ),
              // 列表
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: clustered.length,
                  itemBuilder: (context, index) => clustered[index],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.danger)),
        ),
      ),
      floatingActionButton: _FAB(onPressed: _showAddPage),
    );
  }

  /// 根据 AgendaItem 类型构建对应 tile
  Widget _buildTile(AgendaItem item, DateTime today, DateTime weekStart) {
    return switch (item) {
      TodoAgendaItem(:final item) => TodoItemTile(
        item: item,
        today: today,
        onToggle: () => toggleTodoWithNotifications(ref, item),
        onEdit: () => _openEditTodo(item),
      ),
      HabitAgendaItem(:final habit) => HabitTile(
        habit: habit,
        today: today,
        weekStart: weekStart,
        onEdit: () => _openEditHabit(habit),
      ),
      SubAgendaItem(:final sub) => SubAnchorTile(sub: sub, today: today),
    };
  }

  /// 打开待办编辑页
  void _openEditTodo(TodoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTodoPage(editTodo: item)),
    );
  }

  /// 打开习惯编辑页
  void _openEditHabit(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTodoPage(editHabit: habit)),
    );
  }

  // ── 日期聚类 ──────────────────────────────────────────

  /// 按 dueDate 聚类构建列表 widget。
  ///
  /// 分组规则：
  /// - Todo with dueDate in future → 独立的日期分组（明天 / X月X日）
  /// - Todo without dueDate + Habit + Sub + today/overdue todos → 归入「今天」分组
  List<Widget> _buildClustered(
    List<AgendaItem> items,
    DateTime now,
    DateTime weekStart,
  ) {
    final futureGroups = <DateTime, List<AgendaItem>>{};
    final todayItems = <AgendaItem>[];
    final completedTodayItems = <AgendaItem>[];
    final today = DateTime(now.year, now.month, now.day);

    for (final ai in items) {
      // 内联宽限期：今日完成的 todo 不参与 dueDate 分组，
      // 直接归入「今天」分组底部（即使其 dueDate 在未来，也不漏进未来分组）。
      if (ai is TodoAgendaItem) {
        final item = ai.item;
        if (item.completed &&
            item.completedAt != null &&
            DateUtils.isSameDay(item.completedAt, today)) {
          completedTodayItems.add(ai);
          continue;
        }
      }

      // todo: dueDate · habit: 无（每日）· sub: 下次触发日
      final dueDate = switch (ai) {
        TodoAgendaItem(:final item) => item.dueDate,
        SubAgendaItem(:final sub) => lunarService.nextTriggerDate(
          sub,
          today: now,
        ),
        HabitAgendaItem() => null,
      };

      if (dueDate != null) {
        final key = DateTime(dueDate.year, dueDate.month, dueDate.day);
        if (key.isAfter(today)) {
          futureGroups.putIfAbsent(key, () => []).add(ai);
          continue;
        }
      }
      // 无 dueDate（habit）或触发日 ≤ today → 归入今天
      todayItems.add(ai);
    }

    final widgets = <Widget>[];

    // 今天分组（普通项在前，今日完成项置底）
    if (todayItems.isNotEmpty || completedTodayItems.isNotEmpty) {
      widgets.add(_DateHeader(date: today, today: now));
      for (final ai in todayItems) {
        widgets.add(_buildTile(ai, now, weekStart));
      }
      for (final ai in completedTodayItems) {
        widgets.add(_buildTile(ai, now, weekStart));
      }
    }

    // 未来日期分组（按日期升序）
    final sortedDates = futureGroups.keys.toList()..sort();
    for (final date in sortedDates) {
      widgets.add(_DateHeader(date: date, today: now));
      for (final ai in futureGroups[date]!) {
        widgets.add(_buildTile(ai, now, weekStart));
      }
    }

    return widgets;
  }
}

/// chips 行 —— 横向滚动，5 个 chip，底部 1px borderSoft
///
/// 阶段 2：第 5 个 chip「已完成」是 view switch，由 _ChipsRow 仅渲染入口；
/// 切换走 _TodoScreenState.build() 的早返回分支（per oracle FINDING 7）。
class _ChipsRow extends StatelessWidget {
  final String active;
  final Map<String, int> counts;
  final int completedCount;
  final ValueChanged<String> onChanged;

  const _ChipsRow({
    required this.active,
    required this.counts,
    required this.completedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('all', '全部'),
      ('todo', '代办'),
      ('habit', '习惯'),
      ('sub', '订阅'),
      ('completed', '已完成'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _Chip(
                label: chips[i].$2,
                count: chips[i].$1 == 'completed'
                    ? completedCount
                    : (counts[chips[i].$1] ?? 0),
                isActive: active == chips[i].$1,
                onTap: () => onChanged(chips[i].$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.fg : AppColors.bg,
          border: Border.all(
            color: isActive ? AppColors.fg : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.bg : AppColors.fg,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.white60 : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 日期分组 header
class _DateHeader extends StatelessWidget {
  final DateTime date;
  final DateTime today;

  const _DateHeader({required this.date, required this.today});

  bool get _isToday {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.isAtSameMomentAs(t);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _dateLabel(date, today),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.56, // -0.02em × 28
              color: AppColors.fg,
            ),
          ),
          const Spacer(),
          if (_isToday) _TodayLunarBadge(today: today),
        ],
      ),
    );
  }
}

/// 今日右侧「周X · 阴历X月X」
class _TodayLunarBadge extends StatelessWidget {
  final DateTime today;
  const _TodayLunarBadge({required this.today});

  @override
  Widget build(BuildContext context) {
    final lunar = Lunar.fromDate(today);
    final weekday = _weekDayName(today.weekday);
    final monthZh = lunar.getMonthInChinese();
    final dayZh = lunar.getDayInChinese();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$weekday · 阴历$monthZh$dayZh',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.dangerBg,
          letterSpacing: 0.26, // 0.02em × 13
        ),
      ),
    );
  }
}

/// FAB —— 56x56 圆形 黑底白字 + 号
class _FAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _FAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.fg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(child: AppIcons.add(color: AppColors.bg, size: 24)),
          ),
        ),
      ),
    );
  }
}

Map<String, int> _countByType(List<AgendaItem> items) {
  int todo = 0, habit = 0, sub = 0;
  for (final item in items) {
    switch (item) {
      case TodoAgendaItem():
        todo++;
      case HabitAgendaItem():
        habit++;
      case SubAgendaItem():
        sub++;
    }
  }
  return {'all': todo + habit + sub, 'todo': todo, 'habit': habit, 'sub': sub};
}

List<AgendaItem> _filterByChip(List<AgendaItem> items, String chip) {
  if (chip == 'all') return items;
  return items.where((item) {
    switch (item) {
      case TodoAgendaItem():
        return chip == 'todo';
      case HabitAgendaItem():
        return chip == 'habit';
      case SubAgendaItem():
        return chip == 'sub';
    }
  }).toList();
}

String _dateLabel(DateTime date, DateTime today) {
  final d = DateTime(date.year, date.month, date.day);
  final t = DateTime(today.year, today.month, today.day);
  if (d.isAtSameMomentAs(t)) return '今天';

  // 本周 = today 所在周的 [Mon, Sun]
  final thisWeekMonday = t.subtract(Duration(days: t.weekday - 1));
  final nextWeekMonday = thisWeekMonday.add(const Duration(days: 7));
  final afterNextWeekMonday = nextWeekMonday.add(const Duration(days: 7));

  if (d.isAfter(thisWeekMonday.subtract(const Duration(days: 1))) &&
      d.isBefore(nextWeekMonday)) {
    // 本周（不含今天）
    return _weekDayName(d.weekday);
  }
  if (d.isAfter(nextWeekMonday.subtract(const Duration(days: 1))) &&
      d.isBefore(afterNextWeekMonday)) {
    // 下周
    return '${d.month}月${d.day}日，下${_weekDayName(d.weekday)}';
  }
  // 跨周以外
  return '${d.month}月${d.day}日';
}

String _weekDayName(int weekday) {
  const names = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return names[weekday];
}

/// 本周一（周一为周首日）
DateTime _weekStart(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

void toggleTodoWithNotifications(WidgetRef ref, TodoItem item) {
  ref.read(todoRepositoryProvider).toggleComplete(item.id);
  final willComplete = !item.completed;
  if (willComplete) {
    unawaited(
      notificationScheduler
          .cancelTodo(item.id)
          .catchError(
            (Object e) => debugPrint('[notify-error] todo cancel: $e'),
          ),
    );
  } else if (item.dueDate != null) {
    unawaited(
      notificationScheduler
          .scheduleTodoReminder(item.copyWith(completed: false))
          .catchError(
            (Object e) => debugPrint('[notify-error] todo schedule: $e'),
          ),
    );
  }
}

class _CompletedTodosView extends ConsumerWidget {
  final VoidCallback onBack;

  const _CompletedTodosView({required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedTodosProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        toolbarHeight: 52,
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '已完成',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
            color: AppColors.fg,
          ),
        ),
        leading: IconButton(
          icon: AppIcons.left(size: 18, color: AppColors.muted),
          tooltip: '返回今日',
          onPressed: onBack,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: completedAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(
              child: Text(
                '还没有完成的待办',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            );
          }
          // 按 completedAt 日期分组（null 归入「未知日期」桶）
          final groups = _groupByCompletedDate(todos);
          // 已排序：日期倒序（未知日期置底）
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: groups.length,
            itemBuilder: (context, gi) {
              final group = groups[gi];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      group.label,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.56,
                        color: AppColors.fg,
                      ),
                    ),
                  ),
                  for (final item in group.items)
                    TodoItemTile(
                      item: item,
                      today: now,
                      onToggle: () => toggleTodoWithNotifications(ref, item),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTodoPage(editTodo: item),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }

  /// 按完成日期分组 + 排序（最新日期在前，未知日期置底）。
  List<_CompletedGroup> _groupByCompletedDate(List<TodoItem> todos) {
    final Map<DateTime, List<TodoItem>> map = {};
    final List<TodoItem> nullBucket = [];

    for (final t in todos) {
      final ca = t.completedAt;
      if (ca == null) {
        nullBucket.add(t);
      } else {
        final key = DateTime(ca.year, ca.month, ca.day);
        map.putIfAbsent(key, () => []).add(t);
      }
    }

    final sortedDates = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final groups = <_CompletedGroup>[];
    for (final d in sortedDates) {
      groups.add(
        _CompletedGroup(
          label: _completedDateLabel(d, DateTime.now()),
          items: map[d]!,
        ),
      );
    }
    if (nullBucket.isNotEmpty) {
      groups.add(_CompletedGroup(label: '未知日期', items: nullBucket));
    }
    return groups;
  }
}

class _CompletedGroup {
  final String label;
  final List<TodoItem> items;
  const _CompletedGroup({required this.label, required this.items});
}

String _completedDateLabel(DateTime date, DateTime today) {
  final d = DateTime(date.year, date.month, date.day);
  final t = DateTime(today.year, today.month, today.day);
  if (d.isAtSameMomentAs(t)) return '今天';

  final thisWeekMonday = t.subtract(Duration(days: t.weekday - 1));
  final nextWeekMonday = thisWeekMonday.add(const Duration(days: 7));

  if (d.isAfter(thisWeekMonday.subtract(const Duration(days: 1))) &&
      d.isBefore(nextWeekMonday)) {
    return _weekDayName(d.weekday);
  }
  return '${d.month}月${d.day}日';
}
