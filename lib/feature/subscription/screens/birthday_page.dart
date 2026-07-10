import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/form_shell.dart';
import '../../../core/lunar/lunar_service.dart';
import '../../../data/models/subscription.dart';
import '../../../feature/subscription/widgets/sheet_scaffold.dart';

class BirthdayPage extends ConsumerStatefulWidget {
  const BirthdayPage({super.key});

  @override
  ConsumerState<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends ConsumerState<BirthdayPage> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLunar = false;
  int _leadDays = 0;
  String? _error;
  bool _calendarExpanded = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => '${d.year} 年 ${d.month} 月 ${d.day} 日';

  String _lunarDateText() {
    if (_selectedDate == null) return '';
    final (m, d) = lunarService.solarToLunarMonthDay(_selectedDate!);
    return '转换后：农历 $m 月 $d 日';
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填一个名字');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = '请选日期');
      return;
    }
    int anchorMonth, anchorDay;
    if (_isLunar) {
      final (m, d) = lunarService.solarToLunarMonthDay(_selectedDate!);
      anchorMonth = m;
      anchorDay = d;
    } else {
      anchorMonth = _selectedDate!.month;
      anchorDay = _selectedDate!.day;
    }
    final sub = Subscription(
      id: 0,
      title: '$name生日',
      type: SubType.birthday,
      calendar: _isLunar ? Calendar.lunar : Calendar.solar,
      mode: TriggerMode.anchorMonthly,
      anchorMonth: anchorMonth,
      anchorDay: anchorDay,
      leadDays: _leadDays,
      active: true,
      createdAt: DateTime.now(),
    );
    unawaited(submitSub(ref, sub));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty && _selectedDate != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: FormAppBar(
        title: '新建生日',
        onAction: _submit,
        actionEnabled: canSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名字 section
            const _SectionLabel(label: '名字'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '如：妈妈 / 老张 / 小明',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // 生日 section
            const _SectionLabel(label: '生日'),
            const SizedBox(height: 8),
            if (!_calendarExpanded && _selectedDate != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate!),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _calendarExpanded = true),
                    child: const Text(
                      '更改',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ),
                ],
              )
            else if (!_calendarExpanded && _selectedDate == null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '选择日期',
                      style: TextStyle(fontSize: 16, color: AppColors.muted),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _calendarExpanded = true),
                    child: const Text(
                      '选择',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            if (_calendarExpanded)
              CalendarDatePicker(
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                initialCalendarMode: DatePickerMode.day,
                onDateChanged: (d) {
                  setState(() {
                    _selectedDate = d;
                    _calendarExpanded = false;
                  });
                },
              ),
            const SizedBox(height: 20),
            // 农历 section
            Row(
              children: [
                const Text(
                  '按农历',
                  style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.48),
                ),
                const Spacer(),
                Switch(
                  value: _isLunar,
                  onChanged: (v) => setState(() => _isLunar = v),
                ),
              ],
            ),
            if (_isLunar && _selectedDate != null) ...[
              const SizedBox(height: 8),
              Text(
                _lunarDateText(),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
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
                for (final entry in const [(0, '当天'), (1, '1 天'), (3, '3 天'), (7, '7 天'), (14, '14 天'), (30, '30 天')])
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
      bottomNavigationBar: FormBottomBar(onAction: _submit, actionEnabled: canSubmit),
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
      style: const TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.48),
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
