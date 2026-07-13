import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/day_grid.dart';
import '../../../core/designsystem/form_shell.dart';
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
    final canSubmit =
        _nameController.text.trim().isNotEmpty && _dayOfMonth != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: FormAppBar(
        title: '新建账单',
        onAction: _submit,
        actionEnabled: canSubmit,
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
                  child: const Text(
                    '清除',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
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
                for (final entry in const [
                  (0, '当天'),
                  (1, '1 天'),
                  (3, '3 天'),
                  (5, '5 天'),
                  (7, '7 天'),
                ])
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
      bottomNavigationBar: FormBottomBar(
        onAction: _submit,
        actionEnabled: canSubmit,
      ),
    );
  }
}

// ── 通用组件 ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.muted,
        letterSpacing: 0.48,
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
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.danger),
      ),
    );
  }
}
