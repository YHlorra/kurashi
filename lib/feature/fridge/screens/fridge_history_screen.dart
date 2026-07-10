import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/designsystem/app_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/segmented.dart';
import '../../../data/models/fridge_change_log.dart';
import '../../../data/repositories/fridge_repository.dart';
import '../../../data/repositories/providers.dart';
import '../providers/change_log_provider.dart';
import 'fridge_settings_sheet.dart';

/// 冰箱食材变更历史屏。
///
/// 顶部：SegmentedControl 切日/周/月。
/// 列表：倒序，每条带 +/~/−/↺ 徽章 + 数量前后对比 + 过期日变化（可选副行）。
/// AppBar：分享图标导出当前报表 JSON / 调参图标打开设置 sheet。
class FridgeHistoryScreen extends ConsumerStatefulWidget {
  const FridgeHistoryScreen({super.key});

  @override
  ConsumerState<FridgeHistoryScreen> createState() =>
      _FridgeHistoryScreenState();
}

class _FridgeHistoryScreenState extends ConsumerState<FridgeHistoryScreen> {
  ReportScope _scope = ReportScope.month;

  /// 订阅 handle —— dispose 时 close，避免 widget 卸载后回调仍在跑。
  ProviderSubscription<AsyncValue<List<FridgeChangeLog>>>? _logsSub;

  @override
  void initState() {
    super.initState();
    // 进入历史屏即视为「已读」—— 监听日志流，每次 emit 写入 max(log.id) 为 lastSeenId。
    // 用 listenManual + fireImmediately: true：
    // - listenManual 在 initState 注册并支持 fireImmediately（WidgetRef.listen 不支持）。
    // - fireImmediately: true 确保订阅瞬间就触发一次，否则若日志 stream 在进入前
    //   已发出 AsyncData（实际就是——种子日志 + 已加载），state 没变化回调不会跑。
    // - 已读语义：用户在看历史屏期间到达的新日志也算已读（不靠 dispose 快照，
    //   避免 build/dispose 之间到达的边界日志被遗漏标记）。
    _logsSub = ref.listenManual<AsyncValue<List<FridgeChangeLog>>>(
      fridgeChangeLogProvider,
      (prev, next) {
        next.whenData((logs) async {
          if (logs.isEmpty) return;
          final maxId = logs.map((l) => l.id).reduce((a, b) => a > b ? a : b);
          final current = ref.read(fridgeAppSettingsProvider).valueOrNull;
          if (current == null) return;
          if ((current.fridgeLogLastSeenId ?? -1) >= maxId) return;
          try {
            await ref
                .read(fridgeRepositoryProvider)
                .updateSettings(
                    current.copyWithFridgeLogLastSeenId(maxId));
          } catch (e) {
            // ponytail: 写失败不让崩溃 UI，但需可观测。后续真机回归时排查。
            debugPrint('[fridge-history] mark-as-seen failed: $e');
          }
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _logsSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(fridgeChangeLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('食材记录'),
        actions: [
          IconButton(
            icon: AppIcons.setting(size: 22),
            tooltip: '记录设置',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: AppIcons.share(size: 22),
            tooltip: '导出当前报表 JSON',
            onPressed: _shareCurrentScope,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedControl<ReportScope>(
              options: const [
                ReportScope.day,
                ReportScope.week,
                ReportScope.month,
              ],
              labels: const ['日', '周', '月'],
              selected: _scope,
              onChanged: (s) => setState(() => _scope = s),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _scopeLabel(_scope),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: _buildList,
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('加载失败：$e'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scope helpers ─────────────────────────────────────────────────

  String _scopeLabel(ReportScope s) {
    final now = DateTime.now();
    switch (s) {
      case ReportScope.day:
        return '${now.year}/${_p2(now.month)}/${_p2(now.day)}';
      case ReportScope.week:
        return '最近 7 天';
      case ReportScope.month:
        return '${now.year} 年 ${now.month} 月';
      case ReportScope.all:
        return '全部';
    }
  }

  static String _p2(int n) => n.toString().padLeft(2, '0');

  List<FridgeChangeLog> _filter(List<FridgeChangeLog> all) {
    final now = DateTime.now();
    switch (_scope) {
      case ReportScope.day:
        final start = DateTime(now.year, now.month, now.day);
        return all
            .where((e) => !e.timestamp.isBefore(start))
            .toList();
      case ReportScope.week:
        final cutoff = now.subtract(const Duration(days: 7));
        return all.where((e) => !e.timestamp.isBefore(cutoff)).toList();
      case ReportScope.month:
        final start = DateTime(now.year, now.month);
        return all
            .where((e) => !e.timestamp.isBefore(start))
            .toList();
      case ReportScope.all:
        return all;
    }
  }

  // ── Build list ───────────────────────────────────────────────────

  Widget _buildList(List<FridgeChangeLog> all) {
    final filtered = _filter(all);
    if (filtered.isEmpty) return _emptyState();

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.borderSoft,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (_, i) {
        final entry = filtered[i];
        return _LogTile(
          entry: entry,
          onDelete: () async {
            await ref
                .read(fridgeRepositoryProvider)
                .deleteChangeLogEntry(entry.id);
          },
        );
      },
    );
  }

  Widget _emptyState() {
    final hint = _scope == ReportScope.day
        ? '今天还没操作过食材。'
        : _scope == ReportScope.week
            ? '近 7 天无变更。'
            : '本月无变更，去入库看看吧。';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '还没有记录',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar actions ────────────────────────────────────────────────

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FridgeSettingsSheet(),
    );
  }

  Future<void> _shareCurrentScope() async {
    final logsAsync = ref.read(fridgeChangeLogProvider);
    final all = logsAsync.valueOrNull;
    if (all == null) {
      _toast('记录尚未就绪，稍后再试');
      return;
    }
    final entries = _filter(all);
    if (entries.isEmpty) {
      _toast('当前报表为空，无可导出内容');
      return;
    }
    try {
      final path = await ref
          .read(fridgeRepositoryProvider)
          .exportChangeLogJson(scope: _scope, entries: entries);
      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/json')],
        text: 'kurashi 冰箱 ${_scope.name}报',
      );
    } on PlatformException catch (e) {
      _toast('导出失败：${e.message ?? e.code}');
    } catch (e) {
      _toast('导出失败：$e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

// ── 单条日志行 ───────────────────────────────────────────────────────

class _LogTile extends StatelessWidget {
  final FridgeChangeLog entry;
  final VoidCallback onDelete;

  const _LogTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final ts = entry.timestamp;
    final dateStr = '${_p2(ts.month)}/${_p2(ts.day)}';
    final timeStr = '${_p2(ts.hour)}:${_p2(ts.minute)}';
    final qtyChanged = entry.beforeQty != entry.afterQty;
    final expiryChanged =
        entry.beforeExpiry.year != entry.afterExpiry.year ||
            entry.beforeExpiry.month != entry.afterExpiry.month ||
            entry.beforeExpiry.day != entry.afterExpiry.day;

    final meta = _actionMeta(entry.action);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          meta.icon,
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.fg,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.itemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  qtyChanged
                      ? '${entry.beforeQty} → ${entry.afterQty}'
                      : '数量未变',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                if (expiryChanged) ...[
                  const SizedBox(height: 2),
                  Text(
                    '过期 ${_dateOnly(entry.beforeExpiry)} → ${_dateOnly(entry.afterExpiry)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: AppIcons.close(size: 18, color: AppColors.muted),
            tooltip: '删除这条记录',
            onPressed: () => _confirmDelete(context),
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条记录？'),
        content: Text(
          '${entry.itemName} · ${entry.action.name}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '删除',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) onDelete();
  }

  static String _p2(int n) => n.toString().padLeft(2, '0');
  static String _dateOnly(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  static _ActionMeta _actionMeta(FridgeAction a) {
    switch (a) {
      case FridgeAction.add:
        return _ActionMeta(
            AppIcons.actionAdd(color: AppColors.success), AppColors.success);
      case FridgeAction.update:
        return _ActionMeta(AppIcons.actionEdit(color: AppColors.fg), AppColors.fg);
      case FridgeAction.delete:
        return _ActionMeta(
            AppIcons.actionDelete(color: AppColors.danger), AppColors.danger);
      case FridgeAction.restore:
        return _ActionMeta(AppIcons.actionRestore(color: AppColors.warn), AppColors.warn);
    }
  }
}

class _ActionMeta {
  final Widget icon;
  final Color color;
  _ActionMeta(this.icon, this.color);
}
