import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/form_shell.dart';
import '../../../core/designsystem/segmented.dart';
import '../../../data/models/subscription.dart';
import '../../../feature/subscription/widgets/sheet_scaffold.dart';

class CustomPage extends ConsumerStatefulWidget {
  const CustomPage({super.key});

  @override
  ConsumerState<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends ConsumerState<CustomPage> {
  final _nameController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _intervalController = TextEditingController();
  TriggerMode _mode = TriggerMode.anchorMonthly;
  int _leadDays = 0;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填一个事件名');
      return;
    }
    if (_mode == TriggerMode.anchorMonthly) {
      final monthStr = _monthController.text.trim();
      final dayStr = _dayController.text.trim();
      final month = int.tryParse(monthStr) ?? 0;
      final day = int.tryParse(dayStr) ?? 0;
      if (month < 1 || month > 12) {
        setState(() => _error = '月份请填 1-12');
        return;
      }
      if (day < 1 || day > 31) {
        setState(() => _error = '日期请填 1-31');
        return;
      }
      unawaited(
        submitSub(
          ref,
          Subscription(
            id: 0,
            title: name,
            type: SubType.custom,
            calendar: Calendar.solar,
            mode: TriggerMode.anchorMonthly,
            anchorMonth: month,
            anchorDay: day,
            leadDays: _leadDays,
            active: true,
            createdAt: DateTime.now(),
          ),
        ),
      );
    } else {
      final intervalStr = _intervalController.text.trim();
      final interval = int.tryParse(intervalStr) ?? 0;
      if (interval < 1) {
        setState(() => _error = '请填间隔天数');
        return;
      }
      unawaited(
        submitSub(
          ref,
          Subscription(
            id: 0,
            title: name,
            type: SubType.custom,
            calendar: Calendar.solar,
            mode: TriggerMode.intervalDays,
            intervalDays: interval,
            leadDays: _leadDays,
            active: true,
            createdAt: DateTime.now(),
          ),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: FormAppBar(
        title: '自定义订阅',
        onAction: _submit,
        actionEnabled: canSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题 section
            const _SectionLabel(label: '标题'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '如：换牙刷头 / 体检 / 续签',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // 重复模式 section
            const _SectionLabel(label: '重复模式'),
            const SizedBox(height: 8),
            SegmentedControl<TriggerMode>(
              options: const [
                TriggerMode.anchorMonthly,
                TriggerMode.intervalDays,
              ],
              selected: _mode,
              onChanged: (v) {
                setState(() {
                  _mode = v;
                  _monthController.clear();
                  _dayController.clear();
                  _intervalController.clear();
                });
              },
              labels: const ['按月（锚点）', '按天（频率）'],
            ),
            const SizedBox(height: 20),
            // 条件字段
            if (_mode == TriggerMode.anchorMonthly) ...[
              const _SectionLabel(label: '日期'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '月 1-12',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '日 1-31',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const _SectionLabel(label: '间隔（天）'),
              const SizedBox(height: 8),
              TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '如 30 / 90 / 365',
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                  (7, '7 天'),
                  (14, '14 天'),
                  (30, '30 天'),
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
