import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';

/// Looks like [AppTextField] but opens a sheet of localized month names.
class MonthPickerField extends StatelessWidget {
  const MonthPickerField({
    required this.month,
    required this.hint,
    required this.onChanged,
    this.hasError = false,
    super.key,
  });

  final int? month;
  final String hint;
  final ValueChanged<int> onChanged;
  final bool hasError;

  static const _monthsInYear = 12;

  String _name(BuildContext context, int month) =>
      DateFormat.MMMM(Localizations.localeOf(context).toLanguageTag())
          .format(DateTime(2000, month));

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        children: [
          for (var m = 1; m <= _monthsInYear; m++)
            ListTile(
              title: Text(_name(context, m)),
              selected: m == month,
              onTap: () => Navigator.pop(sheetContext, m),
            ),
        ],
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: hint,
      value: month == null ? null : _name(context, month!),
      child: PressableScale(
        key: const Key('dob.month'),
        onTap: () => _pick(context),
        child: AnimatedContainer(
          duration: context.motion(AppDurations.fast),
          height: AppSizes.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: hasError ? colors.danger : colors.surface,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  month == null ? hint : _name(context, month!),
                  style: context.text.bodyLarge?.copyWith(
                    color: month == null ? colors.textHint : null,
                  ),
                ),
              ),
              Icon(Icons.expand_more_rounded, color: colors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
