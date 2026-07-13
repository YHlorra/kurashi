import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/form_shell.dart';
import '../../../core/designsystem/segmented.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/todo_item.dart';
import '../../../data/repositories/providers.dart';

class AddTodoPage extends ConsumerStatefulWidget {
  const AddTodoPage({super.key});

  @override
  ConsumerState<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends ConsumerState<AddTodoPage> {
  final _descController = TextEditingController();
  List<String> _availableTags = [];
  String? _selectedTag;
  bool _isAddingTag = false;
  final _newTagController = TextEditingController();
  int _type = 0; // 0=todo, 1=habit
  DateTime? _dueDate;
  int _frequency = 3;
  TimeOfDay? _reminderTime;
  bool _enableReminder = false;
  String? _error;
  bool _calendarExpanded = false;
  bool _enableDueTime = false;
  TimeOfDay? _dueTime;

  static const _freqOptions = [1, 2, 3, 5, 7];

  @override
  void initState() {
    super.initState();
    _loadTags();
    _descController.addListener(_onDescChanged);
  }

  @override
  void dispose() {
    _descController.removeListener(_onDescChanged);
    _descController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  void _onDescChanged() => setState(() {});

  Future<void> _loadTags() async {
    final settings = await ref
        .read(appSettingsRepositoryProvider)
        .getSettings();
    if (mounted) {
      setState(() {
        _availableTags = settings.userTags;
      });
    }
  }

  bool get _canSubmit => _descController.text.trim().isNotEmpty;

  void _selectTag(String name) => setState(() => _selectedTag = name);

  void _deleteTag(String name) {
    final removed = name;
    setState(() {
      _availableTags.remove(name);
      if (_selectedTag == name) _selectedTag = null;
    });
    ref.read(appSettingsRepositoryProvider).updateUserTags(_availableTags);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('标签已删除'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            setState(() {
              _availableTags.add(removed);
            });
            ref
                .read(appSettingsRepositoryProvider)
                .updateUserTags(_availableTags);
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startAddTag() => setState(() => _isAddingTag = true);

  void _addCustomTag() {
    final name = _newTagController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '标签名不能为空');
      return;
    }
    if (_availableTags.contains(name)) {
      setState(() => _error = '标签已存在');
      return;
    }
    if (_availableTags.length >= 20) {
      setState(() => _error = '最多 20 个标签');
      return;
    }
    setState(() {
      _availableTags.add(name);
      _selectedTag = name;
      _isAddingTag = false;
      _error = null;
    });
    _newTagController.clear();
    ref.read(appSettingsRepositoryProvider).updateUserTags(_availableTags);
  }

  void _cancelAddTag() {
    setState(() => _isAddingTag = false);
    _newTagController.clear();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dueTime = picked);
    }
  }

  Future<void> _submit() async {
    final title = _descController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = '请填写描述');
      return;
    }
    if (_enableDueTime && _dueTime != null && _dueDate == null) {
      setState(() => _error = '选择时间前请先选择日期');
      return;
    }
    try {
      if (_type == 0) {
        final item = TodoItem(
          title: title,
          tag: _selectedTag,
          dueDate: _dueDate,
          dueTimeMinutes: _enableDueTime && _dueTime != null
              ? _dueTime!.hour * 60 + _dueTime!.minute
              : null,
          createdAt: DateTime.now(),
        );
        final id = await ref.read(todoRepositoryProvider).addTodo(item);
        if (_dueDate != null) {
          unawaited(
            notificationScheduler
                .scheduleTodoReminder(item.copyWith(id: id))
                .catchError(
                  (Object e) => debugPrint('[notify-error] todo schedule: $e'),
                ),
          );
        }
      } else {
        final habit = Habit(
          title: title,
          tag: _selectedTag,
          frequencyPerWeek: _frequency,
          reminderTime: _enableReminder ? _reminderTime : null,
          createdAt: DateTime.now(),
        );
        final id = await ref.read(habitRepositoryProvider).addHabit(habit);
        if (_enableReminder && _reminderTime != null) {
          unawaited(
            notificationScheduler
                .scheduleHabitReminder(habit.copyWith(id: id))
                .catchError(
                  (Object e) => debugPrint('[notify-error] habit schedule: $e'),
                ),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = '保存失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTodo = _type == 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: FormAppBar(
        title: '添加待办',
        onAction: _submit,
        actionEnabled: _canSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 描述 section
            const _SectionLabel(label: '描述'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '如：买牛奶 / 写报告',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // 标签 section
            const _SectionLabel(label: '标签'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in _availableTags)
                  _TagChip(
                    label: tag,
                    isSelected: _selectedTag == tag,
                    onTap: () => _selectTag(tag),
                    onDelete: () => _deleteTag(tag),
                  ),
                _AddTagChip(onTap: _startAddTag),
              ],
            ),
            if (_isAddingTag) ...[
              const SizedBox(height: 8),
              _InlineAddTagField(
                controller: _newTagController,
                onSubmit: _addCustomTag,
                onCancel: _cancelAddTag,
              ),
            ],
            const SizedBox(height: 20),
            // 类型 segmented
            const _SectionLabel(label: '类型'),
            const SizedBox(height: 8),
            SegmentedControl<String>(
              options: const ['todo', 'habit'],
              selected: _type == 0 ? 'todo' : 'habit',
              onChanged: (v) => setState(() => _type = v == 'todo' ? 0 : 1),
              labels: const ['代办', '习惯'],
            ),
            const SizedBox(height: 20),
            // 条件字段
            if (isTodo) ...[
              const _SectionLabel(label: '截止日期'),
              const SizedBox(height: 8),
              if (!_calendarExpanded && _dueDate != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_dueDate!.year} 年 ${_dueDate!.month} 月 ${_dueDate!.day} 日',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
              else if (!_calendarExpanded && _dueDate == null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '无（可选）',
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
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  initialCalendarMode: DatePickerMode.day,
                  onDateChanged: (d) {
                    setState(() {
                      _dueDate = d;
                      _calendarExpanded = false;
                    });
                  },
                ),
              const SizedBox(height: 20),
              // 具体到时间
              Row(
                children: [
                  Checkbox(
                    value: _enableDueTime,
                    onChanged: (v) {
                      setState(() {
                        _enableDueTime = v ?? false;
                        if (!_enableDueTime) _dueTime = null;
                      });
                    },
                  ),
                  const Text('具体到时间', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  if (_enableDueTime && _dueTime != null)
                    Text(
                      '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14, color: AppColors.fg),
                    ),
                  if (_enableDueTime)
                    TextButton(
                      onPressed: _pickDueTime,
                      child: const Text(
                        '选择时间',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ),
                ],
              ),
            ] else ...[
              const _SectionLabel(label: '频率（每周）'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _freqOptions
                    .map(
                      (f) => PresetChip(
                        label: '$f 次',
                        isSelected: _frequency == f,
                        onTap: () => setState(() => _frequency = f),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              // 提醒时间
              Row(
                children: [
                  Checkbox(
                    value: _enableReminder,
                    onChanged: (v) =>
                        setState(() => _enableReminder = v ?? false),
                  ),
                  const Text('提醒', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  if (_enableReminder && _reminderTime != null)
                    Text(
                      '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14, color: AppColors.fg),
                    ),
                  if (_enableReminder)
                    TextButton(
                      onPressed: _pickTime,
                      child: const Text(
                        '选择时间',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ),
                ],
              ),
            ],
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
        actionEnabled: _canSubmit,
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

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fg : AppColors.bg,
          border: Border.all(
            color: isSelected ? AppColors.fg : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.bg : AppColors.fg,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.bg : AppColors.fg,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTagChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTagChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.muted),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+', style: TextStyle(fontSize: 13, color: AppColors.muted)),
            const SizedBox(width: 4),
            Text('自定义', style: TextStyle(fontSize: 13, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _InlineAddTagField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _InlineAddTagField({
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fg),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '输入标签名',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: onSubmit,
            child: const Text(
              '✓',
              style: TextStyle(
                color: AppColors.fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: const Text('取消', style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}
