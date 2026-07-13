import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/fridge_change_log.dart';
import '../../../data/repositories/providers.dart';
import '../providers/change_log_provider.dart';

/// 冰箱记录设置 BottomSheet —— 保留策略 + 手动清理。
///
/// 从历史屏 AppBar 调参图标打开。Strategy radio 互斥；选中即写入 AppSettings
/// （持久化在 Isar）。手动清理按钮仅在策略 != 永久时启用，「清空全部」始终可用。
class FridgeSettingsSheet extends ConsumerStatefulWidget {
  const FridgeSettingsSheet({super.key});

  @override
  ConsumerState<FridgeSettingsSheet> createState() =>
      _FridgeSettingsSheetState();
}

class _FridgeSettingsSheetState extends ConsumerState<FridgeSettingsSheet> {
  int _pending = 0; // 待写入策略（drafting，未保存到 Isar）

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(fridgeAppSettingsProvider);
    final logsAsync = ref.watch(fridgeChangeLogProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 8,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: settingsAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              SizedBox(height: 200, child: Center(child: Text('读取设置失败：$e'))),
          data: (settings) {
            // 第一次进入时把 _pending 同步到当前值
            if (_pending == 0 && settings.fridgeLogRetentionDays != 0) {
              _pending = settings.fridgeLogRetentionDays;
            }

            final logs = logsAsync.valueOrNull ?? const [];
            final earliest = logs.isEmpty
                ? null
                : logs.reduce(
                    (a, b) => a.timestamp.isBefore(b.timestamp) ? a : b,
                  );

            return _buildContent(settings, logs.length, earliest);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    AppSettings settings,
    int logCount,
    FridgeChangeLog? earliest,
  ) {
    final canManual = _pending != 0;
    final retentionLabel = switch (_pending) {
      0 => '永久保留',
      30 => '每月自动清理（30 天前的记录自动删除）',
      90 => '每季度自动清理（90 天前的记录自动删除）',
      _ => '$_pending 天',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '记录保留策略',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.fg,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Radio(
          label: '永久保留',
          sublabel: '所有历史永久可查，不会自动清理',
          value: 0,
          groupValue: _pending,
          onChanged: _selectRetention,
        ),
        _Radio(
          label: '每月自动清理',
          sublabel: '距今超过 30 天的记录自动删除',
          value: 30,
          groupValue: _pending,
          onChanged: _selectRetention,
        ),
        _Radio(
          label: '每季度自动清理',
          sublabel: '距今超过 90 天的记录自动删除',
          value: 90,
          groupValue: _pending,
          onChanged: _selectRetention,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _pending == settings.fridgeLogRetentionDays
                  ? null
                  : _savePolicy,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.fg,
                side: const BorderSide(color: AppColors.border, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                _pending == settings.fridgeLogRetentionDays
                    ? '当前：$retentionLabel'
                    : '保存为：$retentionLabel',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '手动清理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.fg,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            earliest == null
                ? '当前没有记录。'
                : '当前 $logCount 条记录，最早 ${_dateOnly(earliest.timestamp)}',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: !canManual ? null : _sweepByPolicy,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.fg,
                    side: BorderSide(
                      color: canManual
                          ? AppColors.border
                          : AppColors.borderSoft,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('按当前策略清理'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: logCount == 0 ? null : _clearAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('清空全部'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── 行为 ──────────────────────────────────────────────────────────

  void _selectRetention(int? v) {
    if (v == null) return;
    setState(() => _pending = v);
  }

  Future<void> _savePolicy() async {
    final current = await ref.read(fridgeRepositoryProvider).getSettings();
    await ref
        .read(fridgeRepositoryProvider)
        .updateSettings(current.copyWith(fridgeLogRetentionDays: _pending));
    if (!mounted) return;
    _toast('已保存：${_describe(_pending)}');
  }

  Future<void> _sweepByPolicy() async {
    final repo = ref.read(fridgeRepositoryProvider);
    final n = await repo.clearChangeLogOlderThan(
      DateTime.now().subtract(Duration(days: _pending)),
    );
    // 顺手把 lastCleanupAt 推到 now，免得冷启动时再跑一次
    final current = await repo.getSettings();
    await repo.updateSettings(
      current.copyWith(fridgeLogLastCleanupAt: DateTime.now()),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    _toast('已清理 $n 条记录');
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空全部食材记录？'),
        content: const Text('此操作会删除所有历史变更记录，不可撤销。食材本体不受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(fridgeRepositoryProvider);
    final n = await repo.clearChangeLogOlderThan(
      DateTime.fromMillisecondsSinceEpoch(1),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    _toast('已清空 $n 条记录');
  }

  static String _describe(int days) => switch (days) {
    0 => '永久保留',
    30 => '每月自动清理',
    90 => '每季度自动清理',
    _ => '$days 天',
  };

  static String _dateOnly(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

class _Radio extends StatelessWidget {
  final String label;
  final String sublabel;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _Radio({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Radio<int>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
              activeColor: AppColors.fg,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
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
