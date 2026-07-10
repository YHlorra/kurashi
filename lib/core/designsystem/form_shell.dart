import 'package:flutter/material.dart';

import 'colors.dart';

class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onAction;
  final bool actionEnabled;
  final String actionLabel;

  const FormAppBar({
    super.key,
    required this.title,
    this.onAction,
    this.actionEnabled = true,
    this.actionLabel = '添加',
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
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.fg,
              ),
            ),
          ),
          if (onAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: actionEnabled ? onAction : null,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: actionEnabled ? AppColors.fg : AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 药丸形预设选中 chip。
///
/// 选中态：fg 底 + bg 字。未选中态：bg 底 + border。
/// 适用于分类选择、频率选择等 chip group 场景。
class PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PresetChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fg : AppColors.bg,
          border: Border.all(
            color: isSelected ? AppColors.fg : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.bg : AppColors.fg,
          ),
        ),
      ),
    );
  }
}

class FormBottomBar extends StatelessWidget {
  final VoidCallback onAction;
  final bool actionEnabled;
  final String label;

  const FormBottomBar({
    super.key,
    required this.onAction,
    this.actionEnabled = true,
    this.label = '添加',
  });

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
            onPressed: actionEnabled ? onAction : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fg,
              foregroundColor: AppColors.bg,
              disabledBackgroundColor: AppColors.muted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
