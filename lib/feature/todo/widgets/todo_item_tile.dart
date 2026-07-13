import 'package:flutter/material.dart';

import '../../../core/designsystem/colors.dart';
import '../../../data/models/todo_item.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final DateTime today;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const TodoItemTile({
    super.key,
    required this.item,
    required this.today,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final completed = item.completed;
    final dueInfo = _dueInfo(item, item.dueDate, completed, today);

    // 交互范式（对齐 Apple Reminders / Google Tasks / Microsoft To Do）：
    // 圆圈 = 切换完成；整行文字 = 打开编辑。两者各自独立可点击。
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
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
          // check 圆：点击切换完成
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CheckCircle(checked: completed),
              ),
            ),
          ),
          // body：点击打开编辑
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.16,
                      color: completed ? AppColors.muted : AppColors.fg,
                      decoration: completed ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (item.tag != null) ...[
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
                            item.tag!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '代办',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          letterSpacing: 0.48,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '·',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dueInfo.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: dueInfo.color,
                            fontWeight: dueInfo.weight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// check 圆 —— 22x22，2px border fg；完成态实心黑底+白勾
class _CheckCircle extends StatelessWidget {
  final bool checked;
  const _CheckCircle({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.fg, width: 2),
        color: checked ? AppColors.fg : null,
      ),
      child: checked
          ? CustomPaint(size: const Size(12, 12), painter: _CheckPainter())
          : null,
    );
  }
}

/// 白勾绘制器 —— SVG path 'm2 6 3 3 5-6' stroke #fff width 2
class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    path.moveTo(2, 6);
    path.relativeLineTo(3, 3);
    path.relativeLineTo(5, -6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// due 文本信息
class _DueInfo {
  final String text;
  final Color color;
  final FontWeight weight;
  const _DueInfo(this.text, this.color, this.weight);
}

/// 根据 dueDate + completed + today 计算 due 文本与样式
/// 规则对照设计图：
/// - 已完成 → "已完成"（muted）
/// - 已逾期 → "已逾期 N 天"（danger w500）
/// - 今天 → "截止 今天 HH:MM"（muted，普通态）
/// - 明天 → "截止 明天"（warn w500）
/// - 2-7 天内 → "截止 M/D"（warn w500）
/// - >7 天 → "截止 M/D"（muted，普通态）
_DueInfo _dueInfo(
  TodoItem item,
  DateTime? dueDate,
  bool completed,
  DateTime today,
) {
  if (completed) {
    return const _DueInfo('已完成', AppColors.muted, FontWeight.w400);
  }
  if (dueDate == null) {
    return const _DueInfo('无截止', AppColors.muted, FontWeight.w400);
  }

  final todayDate = DateTime(today.year, today.month, today.day);
  final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final diffDays = dueDateOnly.difference(todayDate).inDays;

  final timeStr = _fmtTime(item.dueTimeMinutes);

  if (diffDays < 0) {
    final base = '已逾期 ${-diffDays} 天';
    return _DueInfo(
      timeStr != null ? '$base $timeStr' : base,
      AppColors.danger,
      FontWeight.w500,
    );
  }
  if (diffDays == 0) {
    if (timeStr != null) {
      return _DueInfo('截止 今天 $timeStr', AppColors.warn, FontWeight.w500);
    }
    return const _DueInfo('截止 今天', AppColors.muted, FontWeight.w400);
  }
  if (diffDays == 1) {
    final base = '截止 明天';
    return _DueInfo(
      timeStr != null ? '$base $timeStr' : base,
      AppColors.warn,
      FontWeight.w500,
    );
  }
  if (diffDays <= 7) {
    final base = '截止 ${dueDate.month}/${dueDate.day}';
    return _DueInfo(
      timeStr != null ? '$base $timeStr' : base,
      AppColors.warn,
      FontWeight.w500,
    );
  }
  final base = '截止 ${dueDate.month}/${dueDate.day}';
  return _DueInfo(
    timeStr != null ? '$base $timeStr' : base,
    AppColors.muted,
    FontWeight.w400,
  );
}

/// 将 dueTimeMinutes (0-1439) 格式化为 HH:mm；null 表示无时刻
String? _fmtTime(int? dueTimeMinutes) {
  if (dueTimeMinutes == null) return null;
  final h = (dueTimeMinutes ~/ 60).toString().padLeft(2, '0');
  final m = (dueTimeMinutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}
