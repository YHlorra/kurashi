import 'package:flutter/material.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/lunar/lunar_service.dart';
import '../../../data/models/subscription.dart';

class SubAnchorTile extends StatelessWidget {
  final Subscription sub;
  final DateTime today;

  const SubAnchorTile({super.key, required this.sub, required this.today});

  @override
  Widget build(BuildContext context) {
    // 数据源：lunar_service 统一处理 solar/lunar 锚点、intervalDays 滚动、特殊节日
    // （清明/母亲节/父亲节/感恩节 anchorMonth/anchorDay 为 null，但 lunar_service 能计算）
    final next = lunarService.nextTriggerDate(sub, today: today);
    final diff = lunarService.daysUntil(sub, today: today);
    // warn 阈值：≤14 天（设计图 9 天 warn / 51 天普通）
    final isWarn = diff >= 0 && diff <= 14;
    final calColor = isWarn ? AppColors.warn : AppColors.fg;
    final monthColor = isWarn ? AppColors.warn : AppColors.muted;

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
          // cal 徽章：用下次触发日的公历月日（农历锚点需转公历后展示）
          _CalBadge(
            month: next.month,
            day: next.day,
            color: calColor,
            monthColor: monthColor,
          ),
          const SizedBox(width: 12),
          // body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sub.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.16,
                    color: AppColors.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      '锚点',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        // 含中文「锚点」，移除 mono fontFamily，走 Inter + NotoSansSC fallback
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
                        diff < 0 ? '已过' : '还有 $diff 天',
                        style: TextStyle(
                          fontSize: 12,
                          color: isWarn ? AppColors.warn : AppColors.muted,
                          fontWeight: isWarn
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 日历徽章 —— 40x40 圆角10 1px border，列布局：月份 + 日期
class _CalBadge extends StatelessWidget {
  final int month;
  final int day;
  final Color color;
  final Color monthColor;

  const _CalBadge({
    required this.month,
    required this.day,
    required this.color,
    required this.monthColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
        color: AppColors.bg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // .m：月份 9px w600 muted letterSpacing 0.06em uppercase marginTop 2
          Text(
            '$month月',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: monthColor,
              letterSpacing: 0.54, // 0.06em × 9
            ),
          ),
          const SizedBox(height: 1),
          // .d：日期 15px w700 letterSpacing -0.02em marginTop 1
          Text(
            '$day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3, // -0.02em × 15
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
