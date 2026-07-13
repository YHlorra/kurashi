import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/designsystem/app_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../data/models/fridge_item.dart';
import '../../../data/repositories/providers.dart';
import '../providers/change_log_provider.dart';
import 'fridge_history_screen.dart';
import 'shopping_list_screen.dart';
import '../widgets/history_badge.dart';

/// 食材状态枚举
enum _ItemStatus { ok, warn, danger }

/// 根据过期日期计算状态
_ItemStatus _computeStatus(DateTime expiryDate) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
  final daysLeft = expiry.difference(todayDate).inDays;
  if (daysLeft <= 0) return _ItemStatus.danger;
  if (daysLeft <= 3) return _ItemStatus.warn;
  return _ItemStatus.ok;
}

/// 计算剩余天数
int _daysLeft(DateTime expiryDate) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
  return expiry.difference(todayDate).inDays;
}

/// 状态对应颜色
Color _statusColor(_ItemStatus status) {
  switch (status) {
    case _ItemStatus.ok:
      return AppColors.success;
    case _ItemStatus.warn:
      return AppColors.warn;
    case _ItemStatus.danger:
      return AppColors.danger;
  }
}

/// 冰箱 tab 主界面
class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen> {
  /// 当前 toast 信息
  _ToastInfo? _toastInfo;

  /// "即将到期"分组标题的 key，用于 WarnBar "查看" 滚动定位
  final GlobalKey _expiringGroupKey = GlobalKey();

  /// 显示入库 sheet
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddItemSheet(),
    );
  }

  /// 显示编辑 sheet（复用 _AddItemSheet 字段，预填现有 item 值）
  void _showEditSheet(FridgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddItemSheet(initialItem: item),
    );
  }

  Future<void> _startRemoval(FridgeItem item) async {
    await notificationScheduler.cancelFridge(item.id);
    await ref.read(fridgeRepositoryProvider).removeItem(item.id);
    if (!mounted) return;
  }

  /// 撤销出库
  void _undoRemoval(FridgeItem item) {
    setState(() {
      _toastInfo = null;
    });
    ref.read(fridgeRepositoryProvider).restoreItem(item);
    // 通知调度：fire-and-forget，失败仅 log 不阻塞 UI
    // restoreItem 接收的 item 已有 id，直接重新调度过期提醒
    unawaited(
      notificationScheduler
          .scheduleFridgeExpiry(item)
          .catchError(
            (Object e) => debugPrint('[notify-error] fridge schedule: $e'),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(fridgeRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        title: const Text(
          '冰箱',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, size: 22),
            tooltip: '购物清单',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ShoppingListScreen(),
                ),
              );
            },
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: AppIcons.history(size: 22),
                tooltip: '食材记录',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FridgeHistoryScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 4,
                top: 4,
                child: HistoryBadge(
                  count: ref.watch(fridgeUnreadCountProvider),
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: StreamBuilder<List<FridgeItem>>(
        stream: items,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allItems = snapshot.data!;

          // 计算各状态数量
          int okCount = 0, warnCount = 0, dangerCount = 0;
          final warnItems = <FridgeItem>[];
          final dangerItems = <FridgeItem>[];
          final okItems = <FridgeItem>[];

          for (final item in allItems) {
            final status = _computeStatus(item.expiryDate);
            switch (status) {
              case _ItemStatus.ok:
                okCount++;
                okItems.add(item);
                break;
              case _ItemStatus.warn:
                warnCount++;
                warnItems.add(item);
                break;
              case _ItemStatus.danger:
                dangerCount++;
                dangerItems.add(item);
                break;
            }
          }

          // 即将到期 = warn + danger
          final expiringItems = [...warnItems, ...dangerItems]
            ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

          // 库内 = ok
          okItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

          final hasExpiring = expiringItems.isNotEmpty;

          return Stack(
            children: [
              // 主内容
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warn bar
                    if (hasExpiring)
                      _WarnBar(
                        count: warnCount + dangerCount,
                        onTap: () {
                          // 滚动到"即将到期"分组标题
                          final ctx = _expiringGroupKey.currentContext;
                          if (ctx != null) {
                            Scrollable.ensureVisible(
                              ctx,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              alignment: 0.0,
                            );
                          }
                        },
                      ),
                    // Summary 三卡
                    _SummaryRow(
                      okCount: okCount,
                      warnCount: warnCount,
                      dangerCount: dangerCount,
                    ),
                    // 即将到期组 - 外层 16px 水平 padding
                    if (expiringItems.isNotEmpty) ...[
                      KeyedSubtree(
                        key: _expiringGroupKey,
                        child: const _GroupHeader(title: '即将到期'),
                      ),
                      _buildFridgeList(expiringItems),
                    ],
                    // 库内组 - 外层 16px 水平 padding
                    if (okItems.isNotEmpty) ...[
                      const _GroupHeader(title: '库内'),
                      _buildFridgeList(okItems),
                    ],
                    // 空状态
                    if (allItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                '冰箱是空的',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.muted,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '点 ＋ 入库食材',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Toast
              if (_toastInfo != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,
                  child: _Toast(
                    item: _toastInfo!.item,
                    onUndo: () => _undoRemoval(_toastInfo!.item),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _FAB(onPressed: _showAddSheet),
    );
  }

  /// 构建食材行
  Widget _buildRow(FridgeItem item) {
    final status = _computeStatus(item.expiryDate);
    final days = _daysLeft(item.expiryDate);

    // 子信息文本
    String subText;
    if (days > 0) {
      subText = '剩 $days 天';
    } else {
      subText = '已过期 ${-days} 天';
    }

    return _FridgeRow(
      item: item,
      status: status,
      subText: subText,
      onLongPress: () => _startRemoval(item),
      onMore: () => _showEditSheet(item),
    );
  }

  /// 按 name 分组渲染列表 —— 单批退化、多批折叠/展开
  ///
  /// ponytail: 仅按 name 聚合（owner 拍板，2026-07-09）；zone 不参与分组。
  Widget _buildFridgeList(List<FridgeItem> items) {
    final groups = groupBy<FridgeItem, String>(items, (i) => i.name);
    // 按最早过期日升序：先吃完的排前面
    final sortedGroups = groups.entries.toList()
      ..sort((a, b) {
        final aEarliest = a.value
            .map((i) => i.expiryDate)
            .reduce((x, y) => x.isBefore(y) ? x : y);
        final bEarliest = b.value
            .map((i) => i.expiryDate)
            .reduce((x, y) => x.isBefore(y) ? x : y);
        return aEarliest.compareTo(bEarliest);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in sortedGroups)
          _FridgeGroup(
            name: entry.key,
            batches: entry.value,
            buildRow: _buildRow,
          ),
      ],
    );
  }
}

/// Toast 信息
class _ToastInfo {
  final FridgeItem item;
  _ToastInfo({required this.item});
}

/// 食材聚合行 —— 单批完全复用 _FridgeRow；多批：聚合行 + 折叠/展开批次行
///
/// - 单批：`_FridgeRow` 原样渲染（零视觉差异）
/// - 多批：弱 swatch + name + ×N pill + ›/‹ 箭头；右侧不加任何额外信息
/// - 默认折叠；展开 200ms easeInOut
class _FridgeGroup extends StatefulWidget {
  final String name;
  final List<FridgeItem> batches;
  final Widget Function(FridgeItem) buildRow;

  const _FridgeGroup({
    required this.name,
    required this.batches,
    required this.buildRow,
  });

  @override
  State<_FridgeGroup> createState() => _FridgeGroupState();
}

class _FridgeGroupState extends State<_FridgeGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // 单批：完全复用 _FridgeRow —— 视觉零差异（无 ×N、无箭头）
    if (widget.batches.length == 1) {
      return widget.buildRow(widget.batches.first);
    }

    // 多批：聚合行 + 可展开批次
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 聚合行 —— 弱 swatch + name + ×N + 箭头
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Row(
                  children: [
                    // 弱 swatch —— border 灰，无填充
                    Container(
                      width: 4,
                      constraints: const BoxConstraints(minHeight: 36),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // name + ×N pill
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.16,
                                color: AppColors.fg,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ×N pill —— 11px muted，紧贴 name 右侧
                          Container(
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '×${widget.batches.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ›/‹ —— 16px muted，无背景
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        _expanded ? '‹' : '›',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.muted,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 展开批次 —— 200ms easeInOut 动画 + ClipRect 防溢出
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final batch in widget.batches) ...[
                            const SizedBox(height: 6),
                            // 缩进的 _FridgeRow —— 复用现有 Dismissible / more
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: widget.buildRow(batch),
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Warn bar —— 琥珀色，8px 圆点 + 加粗计数 + "查看"下划线
class _WarnBar extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _WarnBar({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.expiringBg,
        border: Border.all(color: AppColors.expiringBorder, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.warn,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // 文字
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.fg,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: '$count 项',
                    style: const TextStyle(
                      color: AppColors.warn,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' 在 3 天内过期，先用掉。'),
                ],
              ),
            ),
          ),
          // "查看"下划线 - 改用 border-bottom 匹配 HTML
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.only(bottom: 1),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.fg, width: 1),
                ),
              ),
              child: const Text(
                '查看',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary 三卡 —— 正常/≤3天/已过期
class _SummaryRow extends StatelessWidget {
  final int okCount;
  final int warnCount;
  final int dangerCount;

  const _SummaryRow({
    required this.okCount,
    required this.warnCount,
    required this.dangerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              count: okCount,
              label: '正常',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              count: warnCount,
              label: '≤3 天',
              color: AppColors.warn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              count: dangerCount,
              label: '已过期',
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个统计卡
class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              // label 含中文（正常/≤3 天/已过期），移除 mono fontFamily，走 Inter + NotoSansSC fallback
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

/// 分组标题
class _GroupHeader extends StatelessWidget {
  final String title;

  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.muted,
          // title 含中文（即将到期/库内），移除 mono fontFamily，走 Inter + NotoSansSC fallback
          letterSpacing: 0.06,
        ),
      ),
    );
  }
}

class _FridgeRow extends StatelessWidget {
  final FridgeItem item;
  final _ItemStatus status;
  final String subText;
  final VoidCallback onLongPress;
  final VoidCallback onMore;

  const _FridgeRow({
    required this.item,
    required this.status,
    required this.subText,
    required this.onLongPress,
    required this.onMore,
  });

  static const _categoryStyles = <String, ({Color fg, Color bg})>{
    '蔬菜': (fg: AppColors.success, bg: AppColors.catVegetable),
    '水果': (fg: AppColors.warn, bg: AppColors.catFruit),
    '肉类': (fg: AppColors.danger, bg: AppColors.catMeat),
  };

  ({Color fg, Color bg}) _categoryStyle(String tag) =>
      _categoryStyles[tag] ?? (fg: AppColors.muted, bg: AppColors.surface);

  @override
  Widget build(BuildContext context) {
    final swatchColor = _statusColor(status);
    final dueColor = status == _ItemStatus.ok
        ? AppColors.muted
        : _statusColor(status);

    // 格式化入库日期
    final addedStr = '${item.addedDate.month}/${item.addedDate.day}';

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('移除「${item.name}」？'),
            content: Text(
              '${item.quantity} · ${item.expiryDate.year}/${item.expiryDate.month}/${item.expiryDate.day}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('确认移除', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) => onLongPress(),
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: AppColors.bg),
            const SizedBox(width: 4),
            Text(
              '移除',
              style: TextStyle(
                color: AppColors.bg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          children: [
            if (item.tag != null && item.tag!.isNotEmpty) ...[
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _categoryStyle(item.tag!).bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.tag!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _categoryStyle(item.tag!).fg,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Swatch 色条
            Container(
              width: 4,
              constraints: const BoxConstraints(minHeight: 36),
              decoration: BoxDecoration(
                color: swatchColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称 + 数量
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.16,
                          color: AppColors.fg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.quantity,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          // quantity 含中文单位（1 把/半袋/8 枚/3 个），移除 mono fontFamily
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // 入库日期 + 剩余天数
                  Row(
                    children: [
                      Text(
                        '入 $addedStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '·',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subText,
                        style: TextStyle(
                          fontSize: 12,
                          color: dueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // 补货进度线 —— 仅追踪中显示
                  if (item.restockEnabled) ...[
                    const SizedBox(height: 4),
                    _RestockProgressLine(
                      percent: item.remainingPercent,
                      threshold: item.restockThresholdPercent,
                      showPercent:
                          item.remainingPercent > item.restockThresholdPercent,
                    ),
                  ],
                ],
              ),
            ),
            // More 按钮 —— 打开编辑 sheet
            // 补货通知圆点叠加在 more 左上角外侧
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: AppIcons.more(color: AppColors.muted, size: 20),
                    onPressed: onMore,
                  ),
                  if (item.restockEnabled &&
                      item.remainingPercent <= item.restockThresholdPercent)
                    Positioned(
                      top: 8,
                      right: 14,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 补货进度线 —— 追踪中食材下方 3px 细线
///
/// - percent > 阈值：muted 色 + 右侧 percent 文字
/// - percent ≤ 阈值：danger 色 + 无文字
class _RestockProgressLine extends StatelessWidget {
  final int percent;
  final int threshold;
  final bool showPercent;

  const _RestockProgressLine({
    required this.percent,
    required this.threshold,
    required this.showPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = percent <= threshold;
    final color = isLow ? AppColors.danger : AppColors.muted;
    final clamped = percent.clamp(0, 100);
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * (clamped / 100);
              return Stack(
                children: [
                  // 轨道（borderSoft 弱色背景）
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 填充
                  Container(
                    height: 3,
                    width: fillWidth,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (showPercent) ...[
          const SizedBox(width: 8),
          Text(
            '$percent%',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

/// FAB —— 56x56 圆角 16px，黑底白字 + 号
class _FAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _FAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.fg,
      elevation: 4,
      shape: const CircleBorder(),
      child: AppIcons.add(color: AppColors.bg, size: 24),
    );
  }
}

/// Toast —— 黑底白字，圆角 12px，"已出库 · {name}" + "撤销"
class _Toast extends StatelessWidget {
  final FridgeItem item;
  final VoidCallback onUndo;

  const _Toast({required this.item, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '已出库 · ${item.name}',
              style: const TextStyle(fontSize: 14, color: AppColors.bg),
            ),
          ),
          GestureDetector(
            onTap: onUndo,
            child: Container(
              padding: const EdgeInsets.only(bottom: 1),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.bg, width: 1),
                ),
              ),
              child: const Text(
                '撤销',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 入库/编辑 BottomSheet —— [initialItem] 非空时为编辑模式
///
/// 设计：iOS Reminders 风 field-row + 内联展开
/// ───────────────────────────────────────────────────────────────
/// 顶栏  取消 | 标题 | 入库/保存
/// 行 1  名称   ›  点击输入     → 展开底部 TextField + 键盘
/// 行 2  数量   ›  点击选择     → 展开底部 chip 群（自定义… 触发 TextField）
/// 行 3  过期日 ›  默认 7 天    → 展开底部横向日期条（··· 触发系统 DatePicker）
/// 底栏  [ 入库 / 保存 ] 黑底白字圆角 pill
/// ───────────────────────────────────────────────────────────────
class _AddItemSheet extends ConsumerStatefulWidget {
  final FridgeItem? initialItem;

  const _AddItemSheet({this.initialItem});

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

/// 当前展开的 field-row；null = 全部收起（iOS Reminders 单行展开）
enum _Row { name, qty, date, tag, restock }

/// 数量行展开时：preset chip 区 vs 自定义 TextField
enum _QtyMode { preset, custom }

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  // 数量预设（1 份 / 1 L / 500 g）
  static const _qtyPresets = <String>['1 份', '1 L', '500 g'];

  // 标签预设
  static const _tagPresets = <String>['蔬菜', '水果', '肉类'];

  // 过期日快速选项（天数）；最后一个 UI chip 「···」 触发系统 DatePicker
  static const _datePresets = <int>[0, 3, 7, 14, 30];

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _customTagController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _qtyFocusNode = FocusNode();

  DateTime? _selectedDate;
  _Row? _expanded;
  _QtyMode _qtyMode = _QtyMode.preset;
  String? _selectedTag;
  String? _customTag;
  bool _isEditingCustomTag = false;

  // ── 补货追踪（仅编辑模式有意义，添加模式保持默认） ──
  bool _restockEnabled = false;
  int _restockThresholdPercent = 20;
  String _restockQty = '';
  int _remainingPercent = 100;

  @override
  void initState() {
    super.initState();
    final init = widget.initialItem;
    if (init != null) {
      _nameController.text = init.name;
      _qtyController.text = init.quantity;
      _selectedDate = init.expiryDate;
      // 编辑模式：若当前 qty 不在预设里，进 custom 模式以便回填显示
      if (!_qtyPresets.contains(init.quantity)) {
        _qtyMode = _QtyMode.custom;
      }
      // 补货追踪字段从原 item 回填（编辑模式专属）
      _restockEnabled = init.restockEnabled;
      _restockThresholdPercent = init.restockThresholdPercent;
      _restockQty = init.restockQty;
      _remainingPercent = init.remainingPercent;
      // 补货已开启时，自动展开补货追踪行 —— 上次保存后重进可直接继续微调。
      // 单展开模式下，用户 tap 其他行会自动收起（_toggleRow 行为，不变）。
      if (init.restockEnabled) {
        _expanded = _Row.restock;
      }
    }
    // 控制器变更 → 刷新 row value 显示 + nav/footer 按钮 enabled 状态
    _nameController.addListener(_onAnyControllerChanged);
    _qtyController.addListener(_onAnyControllerChanged);
    _customTagController.addListener(_onAnyControllerChanged);
    if (init?.tag != null) {
      _selectedTag = init!.tag;
    }
  }

  void _onAnyControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onAnyControllerChanged);
    _qtyController.removeListener(_onAnyControllerChanged);
    _customTagController.removeListener(_onAnyControllerChanged);
    _nameController.dispose();
    _qtyController.dispose();
    _customTagController.dispose();
    _nameFocusNode.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  // ─── 派生值 ────

  bool get _isCustomQtyValue {
    final t = _qtyController.text.trim();
    return t.isNotEmpty && !_qtyPresets.contains(t);
  }

  /// 距今天几天（null = 未选）；用于日期条 chip 选中态判定
  String? get _daysFromToday {
    final d = _selectedDate;
    if (d == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    return target.difference(today).inDays.toString();
  }

  DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _weekday(DateTime d) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[d.weekday - 1];
  }

  /// 行 3（过期日）的 value 显示文本
  String _dateDisplay() {
    final d = _selectedDate;
    if (d == null) return '默认 7 天';
    return '${d.year}/${d.month}/${d.day}';
  }

  // ─── 交互 ────

  void _toggleRow(_Row row) {
    setState(() {
      if (_expanded == row) {
        // 收起
        _expanded = null;
        if (row == _Row.name) _nameFocusNode.unfocus();
        if (row == _Row.qty) {
          _qtyFocusNode.unfocus();
          // 自定义模式下用户没填，回退到默认「1 份」
          if (_qtyMode == _QtyMode.custom &&
              _qtyController.text.trim().isEmpty) {
            _qtyController.text = '1 份';
            _qtyMode = _QtyMode.preset;
          }
        }
      } else {
        // 展开（自动收起其他行，因为 _expanded 只能存一个）
        _expanded = row;
        if (row == _Row.name) {
          // 直接聚焦：TextField 在 AnimatedSize 内已渲染（尺寸正在动画），
          // 焦点早于动画结束也无碍 —— 焦点是逻辑概念，不依赖可视。
          _nameFocusNode.requestFocus();
        } else if (row == _Row.qty && _isCustomQtyValue) {
          _qtyMode = _QtyMode.custom;
        }
      }
    });
  }

  void _pickQtyPreset(String preset) {
    setState(() {
      _qtyMode = _QtyMode.preset;
      _qtyController.text = preset;
    });
  }

  void _pickDateDays(int days) {
    setState(() {
      _selectedDate = _todayMidnight().add(Duration(days: days));
    });
  }

  Future<void> _pickDateCustom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.fg,
              onPrimary: AppColors.bg,
              surface: AppColors.bg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  // ─── 标签交互 ────

  void _selectTagPreset(String tag) {
    setState(() {
      _selectedTag = tag;
      _isEditingCustomTag = false;
    });
  }

  void _startCustomTagEditing() {
    setState(() {
      _isEditingCustomTag = true;
      _customTag = '';
      _customTagController.clear();
      _selectedTag = null;
    });
  }

  void _submitCustomTag() async {
    final trimmed = _customTagController.text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _selectedTag = trimmed;
      _isEditingCustomTag = false;
    });
    // 持久化到 FridgeRepository（冰箱标签是冰箱数据的一部分）
    final repo = ref.read(fridgeRepositoryProvider);
    final current = await repo.getSettings();
    final currentTags = current.fridgeTags;
    if (!currentTags.contains(trimmed)) {
      await repo.updateSettings(
        current.withFridgeTags([...currentTags, trimmed]),
      );
    }
  }

  void _cancelCustomTagEditing() {
    setState(() {
      _isEditingCustomTag = false;
      _customTag = null;
    });
  }

  // ─── 提交（行为不变） ────

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final qty = _qtyController.text.trim();
    final expiryDate =
        _selectedDate ?? DateTime.now().add(const Duration(days: 7));

    final init = widget.initialItem;
    // ── 编辑模式：updateItem + 通知重排（不生成新补货 todo）
    if (init != null) {
      final updated = init.copyWith(
        name: name,
        quantity: qty.isEmpty ? '1 份' : qty,
        expiryDate: expiryDate,
        tag: _selectedTag,
        restockEnabled: _restockEnabled,
        restockThresholdPercent: _restockThresholdPercent,
        restockQty: _restockQty.isNotEmpty ? _restockQty : qty,
        remainingPercent: _remainingPercent,
      );
      ref.read(fridgeRepositoryProvider).updateItem(updated).then((_) {
        // 通知重排：先取消旧通知，再按新过期日调度
        unawaited(
          notificationScheduler
              .cancelFridge(init.id)
              .then((_) => notificationScheduler.scheduleFridgeExpiry(updated))
              .catchError(
                (Object e) =>
                    debugPrint('[notify-error] fridge reschedule: $e'),
              ),
        );
      });
      // ponytail: 编辑食材过期日不同步更新补货 todo 的 dueDate。
      // 升级路径：FridgeItem 加 linkedTodoId 字段，编辑时联动更新。
      Navigator.pop(context);
      return;
    }

    // ── 新增模式：addItem + 联动补货 todo + 调度通知
    final item = FridgeItem(
      id: 0, // Isar autoIncrement 会自动分配 ID
      name: name,
      quantity: qty.isEmpty ? '1 份' : qty,
      addedDate: DateTime.now(),
      expiryDate: expiryDate,
      tag: _selectedTag,
    );

    ref.read(fridgeRepositoryProvider).addItem(item).then((newId) {
      // 同时调度食材过期通知
      unawaited(
        notificationScheduler
            .scheduleFridgeExpiry(item.copyWith(id: newId))
            .catchError(
              (Object e) => debugPrint('[notify-error] fridge schedule: $e'),
            ),
      );
    });
    Navigator.pop(context);
  }

  // ─── 渲染 ────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;
    final canSubmit = _nameController.text.trim().isNotEmpty;

    return Padding(
      // 仅顶部 viewInsets.bottom 把整个 sheet 顶上去；左右 0 让 row 横到边缘
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          _NavBar(
            isEdit: isEdit,
            canSubmit: canSubmit,
            onCancel: () => Navigator.pop(context),
            onSubmit: _submit,
          ),
          // body —— 3 行 field-row；展开后高度增长由外层 SingleChildScrollView 吸收
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FieldRow(
                    label: '名称',
                    value: _nameController.text,
                    placeholder: '点击输入',
                    expanded: _expanded == _Row.name,
                    onTap: () => _toggleRow(_Row.name),
                    expandedChild: _NameEditor(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      onSubmitted: () => _toggleRow(_Row.name),
                    ),
                  ),
                  _FieldRow(
                    label: '数量',
                    value: _qtyController.text,
                    placeholder: '点击选择',
                    expanded: _expanded == _Row.qty,
                    onTap: () => _toggleRow(_Row.qty),
                    expandedChild: _QtyEditor(
                      selected: _qtyController.text,
                      mode: _qtyMode,
                      presets: _qtyPresets,
                      controller: _qtyController,
                      focusNode: _qtyFocusNode,
                      onPresetTap: _pickQtyPreset,
                      onCustomTap: () => setState(() {
                        _qtyMode = _QtyMode.custom;
                        // 若当前值是预设，清空让用户从头输入
                        if (_qtyPresets.contains(_qtyController.text.trim())) {
                          _qtyController.clear();
                        }
                        _qtyFocusNode.requestFocus();
                      }),
                    ),
                  ),
                  _FieldRow(
                    label: '过期日',
                    value: _dateDisplay(),
                    placeholder: '默认 7 天',
                    expanded: _expanded == _Row.date,
                    onTap: () => _toggleRow(_Row.date),
                    expandedChild: _DateEditor(
                      selectedDays: _daysFromToday,
                      presets: _datePresets,
                      today: _todayMidnight(),
                      weekday: _weekday,
                      onPresetTap: _pickDateDays,
                      onCustomTap: _pickDateCustom,
                    ),
                  ),
                  _FieldRow(
                    label: '标签',
                    value: _selectedTag ?? '点击选择',
                    placeholder: '点击选择',
                    expanded: _expanded == _Row.tag,
                    onTap: () => _toggleRow(_Row.tag),
                    expandedChild: _TagEditor(
                      selectedTag: _selectedTag,
                      presets: _tagPresets,
                      persistedTags:
                          ref
                              .watch(fridgeAppSettingsProvider)
                              .valueOrNull
                              ?.fridgeTags ??
                          [],
                      isEditingCustom: _isEditingCustomTag,
                      customTag: _customTag ?? '',
                      controller: _customTagController,
                      onPresetTap: _selectTagPreset,
                      onCustomSubmit: _submitCustomTag,
                      onCustomCancel: _cancelCustomTagEditing,
                      onStartCustomEdit: _startCustomTagEditing,
                    ),
                  ),
                  // 补货追踪 —— 仅编辑模式
                  if (isEdit)
                    _FieldRow(
                      label: '补货追踪',
                      value: _restockEnabled ? '已开启' : '',
                      placeholder: '点击设置',
                      expanded: _expanded == _Row.restock,
                      onTap: () => _toggleRow(_Row.restock),
                      expandedChild: _RestockEditor(
                        restockEnabled: _restockEnabled,
                        thresholdPercent: _restockThresholdPercent,
                        restockQty: _restockQty,
                        remainingPercent: _remainingPercent,
                        quantity: _qtyController.text,
                        onRestockEnabledChanged: (v) =>
                            setState(() => _restockEnabled = v),
                        onThresholdChanged: (v) =>
                            setState(() => _restockThresholdPercent = v),
                        onRestockQtyChanged: (v) =>
                            setState(() => _restockQty = v),
                        onRemainingChanged: (v) =>
                            setState(() => _remainingPercent = v),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _FooterButton(isEdit: isEdit, onTap: canSubmit ? _submit : null),
        ],
      ),
    );
  }
}

// 子 widget（私有）—— 全部 stateless，状态由 _AddItemSheetState 持有

/// 顶部 drag handle —— 复用视觉语言
class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// 顶栏 —— 取消 | 标题 | 入库/保存
class _NavBar extends StatelessWidget {
  final bool isEdit;
  final bool canSubmit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _NavBar({
    required this.isEdit,
    required this.canSubmit,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final actionLabel = isEdit ? '保存' : '入库';
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            isEdit ? '编辑食材' : '入库',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.fg,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCancel,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: canSubmit ? onSubmit : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: canSubmit ? AppColors.fg : AppColors.border,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底栏黑底白字圆角 pill —— 与 nav 提交按钮同步 disabled
class _FooterButton extends StatelessWidget {
  final bool isEdit;
  final VoidCallback? onTap;
  const _FooterButton({required this.isEdit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fg,
              foregroundColor: AppColors.bg,
              disabledBackgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.muted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              isEdit ? '保存' : '入库',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

/// 整条 field-row：label + value + chevron 始终可见；下方 AnimatedSize 收放展开区
class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final bool expanded;
  final VoidCallback onTap;
  final Widget? expandedChild;

  const _FieldRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.expanded,
    required this.onTap,
    required this.expandedChild,
  });

  bool get _hasValue => value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderSoft, width: 1),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _hasValue ? value : placeholder,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _hasValue ? FontWeight.w500 : FontWeight.w400,
                      color: _hasValue ? AppColors.fg : AppColors.muted,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                AppIcons.right(size: 16, color: AppColors.muted),
              ],
            ),
          ),
        ),
        // 展开区 —— 200ms easeOut，与 iOS Reminders 节奏一致
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: (expanded && expandedChild != null)
              ? expandedChild!
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// 名称行展开：底部下划线 TextField
class _NameEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  const _NameEditor({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmitted(),
        decoration: const InputDecoration(
          hintText: '例如：巴氏鲜牛奶',
          hintStyle: TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 15, color: AppColors.fg),
      ),
    );
  }
}

/// 数量行展开：chip 群 + 自定义 TextField
class _QtyEditor extends StatelessWidget {
  final String selected;
  final _QtyMode mode;
  final List<String> presets;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onPresetTap;
  final VoidCallback onCustomTap;

  const _QtyEditor({
    required this.selected,
    required this.mode,
    required this.presets,
    required this.controller,
    required this.focusNode,
    required this.onPresetTap,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in presets)
                _FridgeChip(
                  label: p,
                  isSelected: selected == p,
                  onTap: () => onPresetTap(p),
                ),
              _FridgeChip(
                label: '自定义',
                isSelected: mode == _QtyMode.custom,
                isCustom: true,
                onTap: onCustomTap,
              ),
            ],
          ),
          if (mode == _QtyMode.custom) ...[
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderSoft, width: 1),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  hintText: '例如：2 盒、330 ml',
                  hintStyle: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.fg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 标签行展开：chip 群 + 自定义输入
class _TagEditor extends StatelessWidget {
  final String? selectedTag;
  final List<String> presets;
  final List<String> persistedTags;
  final bool isEditingCustom;
  final String customTag;
  final TextEditingController? controller;
  final ValueChanged<String> onPresetTap;
  final VoidCallback onCustomSubmit;
  final VoidCallback onCustomCancel;
  final VoidCallback onStartCustomEdit;

  const _TagEditor({
    required this.selectedTag,
    required this.presets,
    required this.persistedTags,
    required this.isEditingCustom,
    required this.customTag,
    required this.controller,
    required this.onPresetTap,
    required this.onCustomSubmit,
    required this.onCustomCancel,
    required this.onStartCustomEdit,
  });

  @override
  Widget build(BuildContext context) {
    final allTags = [
      ...presets,
      ...persistedTags.where((t) => !presets.contains(t)),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in allTags)
                _FridgeChip(
                  label: tag,
                  isSelected: selectedTag == tag,
                  onTap: () => onPresetTap(tag),
                ),
              if (!isEditingCustom)
                _FridgeChip(
                  label: '+ 自定义',
                  isSelected: false,
                  isCustom: true,
                  onTap: onStartCustomEdit,
                )
              else
                _customTagChip(
                  controller: controller,
                  onSubmit: onCustomSubmit,
                  onCancel: onCustomCancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _customTagChip({
  required TextEditingController? controller,
  required VoidCallback onSubmit,
  required VoidCallback onCancel,
}) {
  return Container(
    height: 32,
    padding: const EdgeInsets.only(left: 12, right: 4),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.fg, width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(fontSize: 14, color: AppColors.fg),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
        GestureDetector(
          onTap: onSubmit,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.fg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 14, color: AppColors.bg),
          ),
        ),
        GestureDetector(
          onTap: onCancel,
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              '✕',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ),
      ],
    ),
  );
}

/// 补货追踪行展开 —— 开关 + 阈值 + 补货量 + 当前余量调整
///
/// ponytail: 数量值编辑走单一 TextField（非 chip group），与设计稿 chip 行为有出入；
/// 设计稿 chip 行为仅用 quantity preset（1 份/1 L/500 g），补货量更自由，
/// TextField 更合适。这里用 TextField + hint 用 quantity 作为兜底。
class _RestockEditor extends StatefulWidget {
  final bool restockEnabled;
  final int thresholdPercent;
  final String restockQty;
  final int remainingPercent;
  final String quantity;
  final ValueChanged<bool> onRestockEnabledChanged;
  final ValueChanged<int> onThresholdChanged;
  final ValueChanged<String> onRestockQtyChanged;
  final ValueChanged<int> onRemainingChanged;

  const _RestockEditor({
    required this.restockEnabled,
    required this.thresholdPercent,
    required this.restockQty,
    required this.remainingPercent,
    required this.quantity,
    required this.onRestockEnabledChanged,
    required this.onThresholdChanged,
    required this.onRestockQtyChanged,
    required this.onRemainingChanged,
  });

  @override
  State<_RestockEditor> createState() => _RestockEditorState();
}

class _RestockEditorState extends State<_RestockEditor> {
  // ponytail: 控制器只创建一次；parent 不主动同步 restockQty → 控制器，避免用户输入时光标被踢回末尾。
  // 唯一例外：parent 显式调用 setState 改了 restockQty（如 chip reset），didUpdateWidget 同步。
  late final TextEditingController _restockQtyController;

  @override
  void initState() {
    super.initState();
    _restockQtyController = TextEditingController(
      text: widget.restockQty.isEmpty ? widget.quantity : widget.restockQty,
    );
  }

  @override
  void didUpdateWidget(covariant _RestockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 父级 prop 与控制器不一致时同步（chip 触发 reset 等场景）
    final expected = widget.restockQty.isEmpty
        ? widget.quantity
        : widget.restockQty;
    if (_restockQtyController.text != expected) {
      _restockQtyController.text = expected;
    }
  }

  @override
  void dispose() {
    _restockQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restockEnabled = widget.restockEnabled;
    final thresholdPercent = widget.thresholdPercent;
    final remainingPercent = widget.remainingPercent;
    final quantity = widget.quantity;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch row —— 提醒补货开关
          Row(
            children: [
              const Text(
                '提醒补货',
                style: TextStyle(fontSize: 13, color: AppColors.fg),
              ),
              const Spacer(),
              Switch(
                value: restockEnabled,
                onChanged: widget.onRestockEnabledChanged,
                activeThumbColor: AppColors.fg,
              ),
            ],
          ),
          if (restockEnabled) ...[
            const SizedBox(height: 12),
            // 阈值 —— slider + chips
            const Text(
              '阈值',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: thresholdPercent.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    onChanged: (v) => widget.onThresholdChanged(v.round()),
                    activeColor: AppColors.fg,
                    inactiveColor: AppColors.border,
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$thresholdPercent%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.fg),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: [
                for (final t in const [10, 20, 30])
                  _FridgeChip(
                    label: '$t%',
                    isSelected: thresholdPercent == t,
                    onTap: () => widget.onThresholdChanged(t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 补货量
            const Text(
              '补货量',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _restockQtyController,
                onChanged: widget.onRestockQtyChanged,
                style: const TextStyle(fontSize: 13, color: AppColors.fg),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: quantity.isEmpty ? '1 份' : quantity,
                  hintStyle: const TextStyle(color: AppColors.muted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 当前余量 —— 大滑块 + 4 档快捷 chip
            const Text(
              '当前余量',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: remainingPercent.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (v) => widget.onRemainingChanged(v.round()),
                    activeColor: AppColors.fg,
                    inactiveColor: AppColors.border,
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$remainingPercent%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.fg),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _FridgeChip(
                  label: '−10%',
                  isSelected: false,
                  onTap: () => widget.onRemainingChanged(
                    (remainingPercent - 10).clamp(0, 100),
                  ),
                ),
                _FridgeChip(
                  label: '−25%',
                  isSelected: false,
                  onTap: () => widget.onRemainingChanged(
                    (remainingPercent - 25).clamp(0, 100),
                  ),
                ),
                _FridgeChip(
                  label: '−50%',
                  isSelected: false,
                  onTap: () => widget.onRemainingChanged(
                    (remainingPercent - 50).clamp(0, 100),
                  ),
                ),
                _FridgeChip(
                  label: '用完',
                  isSelected: false,
                  danger: true,
                  onTap: () => widget.onRemainingChanged(0),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 过期日行展开：横向日期条 + 自定义 DatePicker 入口
class _DateEditor extends StatelessWidget {
  final String? selectedDays;
  final List<int> presets;
  final DateTime today;
  final String Function(DateTime) weekday;
  final ValueChanged<int> onPresetTap;
  final VoidCallback onCustomTap;

  const _DateEditor({
    required this.selectedDays,
    required this.presets,
    required this.today,
    required this.weekday,
    required this.onPresetTap,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          children: [
            for (int i = 0; i < presets.length; i++) ...[
              _FridgeDateChip(
                label: presets[i] == 0 ? '今天' : '${presets[i]} 天后',
                sublabel: weekday(today.add(Duration(days: presets[i]))),
                isSelected: selectedDays == presets[i].toString(),
                onTap: () => onPresetTap(presets[i]),
              ),
              // chip 间 8px 间隔，最后一个 preset 后再加一个，再放「···」
              if (i < presets.length - 1) const SizedBox(width: 8),
            ],
            const SizedBox(width: 8),
            _FridgeDateChip(
              label: '···',
              sublabel: '',
              isSelected: false,
              onTap: onCustomTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// pill chip —— 30px 高
///
/// ponytail: `isCustom` (muted border) 与 `danger` (danger border + danger text) 是两个
/// 独立的视觉修饰，互不冲突但都覆盖默认 border 色。
class _FridgeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCustom;
  final bool danger;

  const _FridgeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCustom = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    if (isSelected) {
      borderColor = AppColors.fg;
    } else if (danger) {
      borderColor = AppColors.danger;
    } else if (isCustom) {
      borderColor = AppColors.muted;
    } else {
      borderColor = AppColors.border;
    }
    final Color textColor;
    if (isSelected) {
      textColor = AppColors.bg;
    } else if (danger) {
      textColor = AppColors.danger;
    } else {
      textColor = AppColors.fg;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fg : AppColors.bg,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// 日期 chip —— 2 行（label + weekday），圆角矩形 10，区别于数量 pill
class _FridgeDateChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _FridgeDateChip({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fg : AppColors.bg,
          border: Border.all(
            color: isSelected ? AppColors.fg : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.bg : AppColors.fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.bg : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
