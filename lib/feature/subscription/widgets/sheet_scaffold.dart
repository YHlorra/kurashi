import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/form_shell.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../data/models/subscription.dart';
import '../../../data/repositories/providers.dart';

/// Bottom-sheet chrome shared by all subscription form sheets.
///
/// Eliminates the duplicated handle + nav bar + divider + scroll wrapper
/// that each sheet was repeating (~60 lines per sheet × 9 sheets).
///
/// Each sheet's body is just the form fields; chrome lives here.
class SheetScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String cancelLabel;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool actionDisabled;

  const SheetScaffold({
    super.key,
    required this.title,
    required this.body,
    this.cancelLabel = '取消',
    this.actionLabel = '添加',
    this.onAction,
    this.actionDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final showAction = actionLabel.isNotEmpty;
    final canAction = !actionDisabled && onAction != null;
    final actionColor = canAction ? AppColors.fg : AppColors.muted;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Nav bar — title absolutely centered via Stack so it's stable
            // regardless of cancel/action widths.
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          cancelLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showAction)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: canAction ? onAction : null,
                          child: Text(
                            actionLabel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: actionColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSoft),
            // Body — Flexible so the scroll view gets bounded height
            Flexible(child: SingleChildScrollView(child: body)),
          ],
        ),
      ),
    );
  }
}

/// 3-column grid of icon+label cells. Denser and visually richer than
/// the old pill-chip row for ≥6 items. Tap fires [onChanged] with the label.
///
/// When [selected] matches an item's label, that cell renders dark-fill
/// (matching `subscription-redesign.html` `.picker-cell.on`):
/// bg=fg, border=fg, icon/text=bg. Useful for both "pinned selection"
/// (PetSheet species, HealthSheet project) and "current value echo"
/// (HomeSheet mirrors the name-field text).
///
/// [items] is `List<(label, icon)>` — positional record so it composes
/// naturally with a `List<(String, List<(String, Widget)>)>` section map.
class PresetIconGrid extends StatelessWidget {
  final List<(String, Widget)> items;
  final ValueChanged<String> onChanged;
  final String? selected;
  final int columns;
  final double spacing;

  const PresetIconGrid({
    super.key,
    required this.items,
    required this.onChanged,
    this.selected,
    this.columns = 3,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      // 1.0 → square cells; icon (~26) + 6 gap + 2-line 11px label fits.
      childAspectRatio: 1.0,
      padding: EdgeInsets.zero,
      children: [
        for (final item in items)
          _PresetIconCell(
            item: item,
            isOn: item.$1 == selected,
            onTap: () => onChanged(item.$1),
          ),
      ],
    );
  }
}

class _PresetIconCell extends StatelessWidget {
  final (String, Widget) item;
  final bool isOn;
  final VoidCallback onTap;

  const _PresetIconCell({
    required this.item,
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isOn ? AppColors.fg : AppColors.bg,
          border: Border.all(
            color: isOn ? AppColors.fg : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(
                size: 26,
                color: isOn ? AppColors.bg : AppColors.fg,
              ),
              child: item.$2,
            ),
            const SizedBox(height: 6),
            Text(
              item.$1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isOn ? AppColors.bg : AppColors.fg,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error message box — red-soft-bg + danger-fg, 8px radius.
/// Kept here so all sheets render errors identically.
class SheetErrorBox extends StatelessWidget {
  final String message;
  const SheetErrorBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.danger),
      ),
    );
  }
}

/// Themed date picker — applies the monochrome colorScheme (fg primary,
/// bg surface) so the picker doesn't break the aesthetic.
Future<DateTime?> pickSheetDate(
  BuildContext context, {
  required DateTime initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate ?? DateTime(1900),
    lastDate: lastDate ?? DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.fg,
            onPrimary: AppColors.bg,
            surface: AppColors.bg,
          ),
        ),
        child: child!,
      );
    },
  );
}

/// Format a DateTime as `YYYY/M/D` for compact display in sheet rows.
String formatSheetDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

/// Single, immutable segmented + date + remind-before form block.
/// Used as the bottom of every new-sheet body so visual rhythm stays consistent.
class RemindBeforeSegmented extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List<int> options;
  final List<String> labels;

  const RemindBeforeSegmented({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const [0, 1, 3, 7, 14, 30],
    this.labels = const ['当天', '1 天', '3 天', '7 天', '14 天', '30 天'],
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < options.length; i++)
          PresetChip(
            label: labels[i],
            isSelected: options[i] == value,
            onTap: () => onChanged(options[i]),
          ),
      ],
    );
  }
}

/// Write a subscription to the repository and schedule its reminder.
/// Shared by all subscription form sheets so the side-effect lives in one place.
Future<void> submitSub(WidgetRef ref, Subscription sub) async {
  final id = await ref
      .read(subscriptionRepositoryProvider)
      .addSubscription(sub);
  unawaited(
    notificationScheduler
        .scheduleSubscriptionReminder(sub.copyWith(id: id))
        .catchError(
          (Object e) => debugPrint('[notify-error] sub schedule: $e'),
        ),
  );
}

/// Reusable date field for bottom-sheet forms.
///
/// Shows a tappable row with the formatted date (or placeholder) and an
/// optional clear button. Visual style matches the existing sheet fields.
class SheetDateField extends StatelessWidget {
  final DateTime? date;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const SheetDateField({
    super.key,
    required this.date,
    required this.placeholder,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(date == null ? placeholder : formatSheetDate(date!)),
          ),
          if (date != null && onClear != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '清除',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
