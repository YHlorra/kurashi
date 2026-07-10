import 'package:flutter/material.dart';

import 'colors.dart';

/// 每月几号选择网格 —— 7 列 × 5 行，1-31 顺序填充。
class DayOfMonthGrid extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onChanged;

  const DayOfMonthGrid({super.key, this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 5; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int col = 0; col < 7; col++)
                _DayCell(
                  day: row * 7 + col + 1,
                  isSelected: selected == row * 7 + col + 1,
                  onTap: () => onChanged(row * 7 + col + 1),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day > 31) {
      return const SizedBox(width: 40, height: 40);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: AppColors.border, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.bg : AppColors.fg,
          ),
        ),
      ),
    );
  }
}
