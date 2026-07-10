import 'package:flutter/material.dart';

import 'colors.dart';

/// Sheet 字段行 —— label 左对齐 + value 右对齐，value 可点
class SheetField extends StatelessWidget {
  final String label;
  final Widget value;
  final VoidCallback? onTap;
  final bool valueMuted;

  const SheetField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.valueMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue = onTap != null
        ? GestureDetector(onTap: onTap, child: value)
        : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
            letterSpacing: 0.48,
          ),
        ),
        const SizedBox(height: 8),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: valueMuted ? AppColors.muted : AppColors.fg,
          ),
          child: effectiveValue,
        ),
      ],
    );
  }
}
