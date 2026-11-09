import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom sheet with one radio per option; resolves to the tapped option, or
/// `null` when dismissed.
///
/// Opened on the root navigator so it slides up over the whole screen,
/// bottom navigation bar included, instead of behind it.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required T current,
  required Map<T, String> options,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (sheetContext) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: RadioGroup<T>(
        groupValue: current,
        onChanged: (value) => Navigator.pop(sheetContext, value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                0,
                AppSpacing.pageGutter,
                AppSpacing.xs,
              ),
              child: Text(title, style: sheetContext.text.titleMedium),
            ),
            for (final entry in options.entries)
              RadioListTile<T>(
                key: ValueKey('option.${entry.key}'),
                value: entry.key,
                activeColor: sheetContext.colors.accent,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter - AppSpacing.xs,
                ),
                title: Text(entry.value, style: sheetContext.text.titleSmall),
              ),
          ],
        ),
      ),
    ),
  ),
);
