import 'package:flutter/material.dart';
import '../../../core/designsystem/colors.dart';

/// Monochrome badge showing a count, kurashi-style
/// Hidden when count == 0, visible when count > 0
class HistoryBadge extends StatelessWidget {
  final int count;
  const HistoryBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final text = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.bg, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.bg,
          height: 1.0,
        ),
      ),
    );
  }
}
