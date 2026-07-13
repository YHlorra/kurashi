import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_checkin.dart';
import '../../../data/repositories/providers.dart';

class HabitTile extends ConsumerWidget {
  final Habit habit;
  final DateTime today;
  final DateTime weekStart;
  final VoidCallback onEdit;

  const HabitTile({
    super.key,
    required this.habit,
    required this.today,
    required this.weekStart,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinsStream = ref
        .watch(habitRepositoryProvider)
        .watchCheckinsFor(habit.id, weekStart);

    return StreamBuilder<List<HabitCheckin>>(
      stream: checkinsStream,
      builder: (context, snapshot) {
        final checkins = snapshot.data ?? const [];
        final todayDate = DateTime(today.year, today.month, today.day);
        final checkedToday = checkins.any((c) => _isSameDay(c.date, todayDate));
        final n = checkins.length;
        final m = habit.frequencyPerWeek;
        final ringColor = _ringColor(n, m);

        return Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(
              bottom: BorderSide(color: AppColors.borderSoft, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ring
              _HabitRing(n: n, m: m, color: ringColor),
              const SizedBox(width: 12),
              // body：点击打开编辑（打卡按钮保持独立切换）
              Expanded(
                child: InkWell(
                  onTap: onEdit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.16,
                        color: AppColors.fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (habit.tag != null) ...[
                          Container(
                            constraints: const BoxConstraints(maxHeight: 18),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              habit.tag!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '本周 $n / $m 次 · 提醒 ${_reminderText(habit.reminderTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              // checkin 按钮
              _CheckinButton(
                checked: checkedToday,
                onTap: () =>
                    _toggleCheckin(ref, habit.id, todayDate, checkedToday),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 切换今日打卡状态
  void _toggleCheckin(
    WidgetRef ref,
    int habitId,
    DateTime todayDate,
    bool checkedToday,
  ) {
    final repo = ref.read(habitRepositoryProvider);
    if (checkedToday) {
      repo.uncheckin(habitId, todayDate);
    } else {
      repo.checkin(habitId, todayDate);
    }
  }

  /// 提醒时间文本
  String _reminderText(TimeOfDay? t) {
    if (t == null) return '无';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// 环形进度颜色规则（对照设计图）：
/// - 完成（N >= M）→ 黑 #111111
/// - 落后（N == 0）→ 琥珀 #B7791F
/// - 进行中（0 < N < M）→ 绿 #168A46
Color _ringColor(int n, int m) {
  if (m == 0) return AppColors.muted;
  if (n >= m) return AppColors.fg;
  if (n == 0) return AppColors.warn;
  return AppColors.success;
}

/// 环形进度组件 —— 22x22，与 TodoItemTile 的 _CheckCircle 同尺寸。
/// 背景环 + 前景环，不显示中央数字（频次已在副标题展示）。
class _HabitRing extends StatelessWidget {
  final int n;
  final int m;
  final Color color;

  const _HabitRing({required this.n, required this.m, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = m == 0 ? 0.0 : (n / m).clamp(0.0, 1.0);
    return CustomPaint(
      size: const Size(22, 22),
      painter: _RingPainter(progress: progress, color: color),
    );
  }
}

/// 环形进度绘制器
/// 22x22 画布，2px 描边；背景环 #EEEEEE，前景环从顶部顺时针扫到进度。
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 10.0; // 22px 画布，2px stroke，外径 22，内径 18

    // 背景环
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceWarm
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 前景环：从顶部（-90deg）顺时针
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// 打卡按钮 —— 48x48 圆形，1px border；未打卡空心+黑勾，已打卡 success 底白勾
class _CheckinButton extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const _CheckinButton({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: checked ? AppColors.success : AppColors.border,
            width: 1,
          ),
          color: checked ? AppColors.success : AppColors.bg,
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(22, 22),
            painter: _CheckinCheckPainter(
              color: checked ? AppColors.bg : AppColors.fg,
            ),
          ),
        ),
      ),
    );
  }
}

/// 打卡按钮勾 —— SVG path 'm5 12 5 5 9-11' stroke width 2.5
/// 未打卡：黑勾（fg）；已打卡：白勾（bg on success 底）
class _CheckinCheckPainter extends CustomPainter {
  final Color color;
  const _CheckinCheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    // 在 22x22 viewBox 内：M5 12 L10 17 L19 6
    path.moveTo(5, 12);
    path.lineTo(10, 17);
    path.lineTo(19, 6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckinCheckPainter oldDelegate) =>
      oldDelegate.color != color;
}
