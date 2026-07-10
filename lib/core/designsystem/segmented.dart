import 'package:flutter/material.dart';

import 'colors.dart';

/// Segmented control — iOS Reminders 风格
/// 灰底容器 + 白底激活按钮 + 投影
class SegmentedControl<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final List<String> labels;

  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labels,
  }) : assert(options.length == labels.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: _SegButton(
                label: labels[i],
                isSelected: options[i] == selected,
                onTap: () => onChanged(options[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0x1A000000),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.fg : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
