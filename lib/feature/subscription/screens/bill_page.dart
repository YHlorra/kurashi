import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/day_grid.dart';
import '../../../data/models/subscription.dart';
import '../../../feature/subscription/widgets/sheet_scaffold.dart';

class BillPage extends ConsumerStatefulWidget {
  const BillPage({super.key});

  @override
  ConsumerState<BillPage> createState() => _BillPageState();
}

class _BillPageState extends ConsumerState<BillPage> {
  final _nameController = TextEditingController();
  int? _dayOfMonth;
  int _leadDays = 0;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填一个平台');
      return;
    }
    if (_dayOfMonth == null) {
      setState(() => _error = '请选每月几号');
      return;
    }
    final sub = Subscription(
      id: 0,
      title: name,
      type: SubType.bill,
      calendar: Calendar.solar,
      mode: TriggerMode.anchorMonthly,
      anchorDay: _dayOfMonth!,
      leadDays: _leadDays,
      active: true,
      createdAt: DateTime.now(),
    );
    unawaited(submitSub(ref, sub));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty && _dayOfMonth != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _AppBar(
        title: '新建还款',
        onSubmit: _submit,
        canSubmit: canSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 平台 section
            const _SectionLabel(label: '平台'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '如：花呗 / 借呗 / 白条',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // 每月几号 section
            const _SectionLabel(label: '每月几号'),
            const SizedBox(height: 8),
            DayOfMonthGrid(
              selected: _dayOfMonth,
              onChanged: (v) => setState(() => _dayOfMonth = v),
            ),
            if (_dayOfMonth != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _dayOfMonth = null),
                  child: const Text('清除', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // 提前提醒 section
            const _SectionLabel(label: '提前提醒'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in const [(0, '当天'), (1, '1 天'), (3, '3 天'), (5, '5 天'), (7, '7 天')])
                  PresetChip(
                    label: entry.$2,
                    isSelected: _leadDays == entry.$1,
                    onTap: () => setState(() => _leadDays = entry.$1),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: _error!),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(onSubmit: _submit, canSubmit: canSubmit),
    );
  }
}

// ── 通用组件 ────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSubmit;
  final bool canSubmit;

  const _AppBar({
    required this.title,
    required this.onSubmit,
    required this.canSubmit,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft, width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.fg,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.fg),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: canSubmit ? onSubmit : null,
              child: Text(
                '添加',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: canSubmit ? AppColors.fg : AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.48),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool canSubmit;

  const _BottomBar({required this.onSubmit, required this.canSubmit});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fg,
              foregroundColor: AppColors.bg,
              disabledBackgroundColor: AppColors.muted,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('添加', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFC53030).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.danger),
      ),
    );
  }
}
