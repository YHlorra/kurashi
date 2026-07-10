import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/form_shell.dart';
import '../../../core/lunar/festival_presets.dart';
import '../../../core/lunar/lunar_service.dart';
import '../../../data/models/subscription.dart';
import '../../../data/repositories/providers.dart';

/// 节日订阅详情页 —— 瑞士资讯极简平铺列表。
///
/// 结构：AppBar + 节日行列表 + 底部按钮。无封面、无描述。
class FestivalDetailScreen extends ConsumerStatefulWidget {
  final SubType type;

  const FestivalDetailScreen({super.key, required this.type});

  @override
  ConsumerState<FestivalDetailScreen> createState() =>
      _FestivalDetailScreenState();
}

class _FestivalDetailScreenState extends ConsumerState<FestivalDetailScreen> {
  bool _busy = false;

  bool get _isCn => widget.type == SubType.cnFestival;

  List<FestivalPreset> get _presets => presetsByType(widget.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: StreamBuilder<List<Subscription>>(
        stream: ref.watch(subscriptionRepositoryProvider).watchAll(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final subs = snap.data!;
          final activeCount = subs
              .where((s) => s.type == widget.type && s.active)
              .length;
          final isSubscribed = activeCount == _presets.length;

          // Group presets by next trigger date
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final grouped = <DateTime, List<FestivalPreset>>{};
          for (final preset in _presets) {
            final sub = Subscription(
              title: preset.title,
              type: preset.type,
              calendar: preset.calendar,
              mode: preset.mode,
              anchorMonth: preset.anchorMonth,
              anchorDay: preset.anchorDay,
              leadDays: preset.leadDays,
              createdAt: today,
            );
            final triggerDate = lunarService.nextTriggerDate(sub, today: today);
            final dateKey = DateTime(triggerDate.year, triggerDate.month, triggerDate.day);
            grouped.putIfAbsent(dateKey, () => []).add(preset);
          }
          final sortedDates = grouped.keys.toList()..sort();

          // Build flat list of section headers + rows
          final children = <Widget>[];
          for (final date in sortedDates) {
            children.add(_SectionHeader(date: date));
            for (final preset in grouped[date]!) {
              final subscription = _matchSubscription(subs, preset);
              children.add(_FestivalRow(
                preset: preset,
                subscription: subscription,
              ));
            }
          }

          return Column(
            children: [
              // AppBar
              FormAppBar(
                title: _isCn ? '中国节日' : '西方节日',
              ),
              // Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        '${_presets.length} 项节日',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          letterSpacing: 0.48,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.borderSoft),
                    // Festival rows grouped by date
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: children.length,
                        itemBuilder: (context, index) => children[index],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Bottom bar
              _BottomBar(
                isSubscribed: isSubscribed,
                busy: _busy,
                total: _presets.length,
                activeCount: activeCount,
                onTap: () => _toggleSubscription(isSubscribed),
              ),
            ],
          );
        },
      ),
    );
  }

  Subscription? _matchSubscription(List<Subscription> subs, FestivalPreset preset) {
    for (final s in subs) {
      if (s.type == widget.type && s.title == preset.title) return s;
    }
    return null;
  }

  Future<void> _toggleSubscription(bool currentActive) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .setActiveByType(widget.type, !currentActive);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ── Section Header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final DateTime date;

  const _SectionHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(date),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.bg,
      child: Text(
        '${date.month}月${date.day}日',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

// ── 节日行 ────────────────────────────────────────────────────────────

class _FestivalRow extends StatelessWidget {
  final FestivalPreset preset;
  final Subscription? subscription;

  const _FestivalRow({
    required this.preset,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(preset);
    final sub = subscription;
    final remindText = sub == null || !sub.active
        ? '无提醒'
        : sub.leadDays <= 0
            ? '当天提醒'
            : '提前 ${sub.leadDays} 天';

    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: AppColors.bg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 节日名
            Expanded(
              child: Text(
                preset.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fg,
                ),
              ),
            ),
            // 日期 + 提醒
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.fg,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  remindText,
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
    );
  }

  String _formatDate(FestivalPreset p) {
    if (p.specialType != null) {
      switch (p.specialType!) {
        case SpecialFestivalType.qingming:
          return '约4月4-6日';
        case SpecialFestivalType.mothersDay:
          return '5月第2个周日';
        case SpecialFestivalType.fathersDay:
          return '6月第3个周日';
        case SpecialFestivalType.thanksgiving:
          return '11月第4个周四';
      }
    }
    final m = p.anchorMonth;
    final d = p.anchorDay;
    if (m == null || d == null) return '每年';
    final prefix = p.calendar == Calendar.lunar ? '每年（农历）' : '每年';
    return '$prefix，${_toChineseNum(m)}月${_toChineseNum(d)}日';
  }

  String _toChineseNum(int n) {
    const chars = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (n <= 10) return chars[n];
    if (n < 20) return '十${n == 10 ? '' : chars[n - 10]}';
    if (n < 100) {
      final tens = n ~/ 10;
      final ones = n % 10;
      if (ones == 0) return '${chars[tens]}十';
      return '${chars[tens]}十${chars[ones]}';
    }
    return n.toString();
  }
}

// ── 底部按钮 ────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isSubscribed;
  final bool busy;
  final int total;
  final int activeCount;
  final VoidCallback onTap;

  const _BottomBar({
    required this.isSubscribed,
    required this.busy,
    required this.total,
    required this.activeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: busy ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSubscribed ? AppColors.success : AppColors.fg,
                  foregroundColor: AppColors.bg,
                  disabledBackgroundColor:
                      (isSubscribed ? AppColors.success : AppColors.fg)
                          .withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
                        ),
                      )
                    : Text(
                        isSubscribed
                            ? '已订 $activeCount/$total'
                            : '订阅整类（$total 项）',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
            if (isSubscribed) ...[
              const SizedBox(height: 8),
              const Text(
                '轻按取消订阅',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
