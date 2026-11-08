import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Inline empty or error state for one Home section.
class SectionMessage extends StatelessWidget {
  const SectionMessage.empty({super.key, this.height = _defaultHeight})
    : onRetry = null,
      isError = false;

  const SectionMessage.error({
    required this.onRetry,
    super.key,
    this.height = _defaultHeight,
  }) : isError = true;

  final VoidCallback? onRetry;
  final bool isError;
  final double height;

  static const _defaultHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.inbox_outlined,
            color: colors.textHint,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isError ? l10n.sectionError : l10n.sectionEmpty,
            style: context.text.bodyMedium,
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
