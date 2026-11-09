import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// One Settings menu row: icon, label, optional current value, chevron.
/// Without [onTap] the feature is not built yet: the row shows a "Soon"
/// chip and a coming-soon snackbar instead.
class SettingsMenuRow extends StatelessWidget {
  const SettingsMenuRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;

  /// Current selection shown before the chevron (e.g. "ENGLISH").
  final String? value;
  final VoidCallback? onTap;

  bool get inProgress => onTap == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
      ),
      leading: Icon(icon, color: colors.textSecondary),
      title: Text(
        label,
        style: context.text.titleSmall?.copyWith(
          color: inProgress ? colors.textSecondary : colors.textPrimary,
        ),
      ),
      trailing: _Trailing(value: value, inProgress: inProgress),
      onTap: onTap ?? () => showComingSoon(context, label),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.value, required this.inProgress});

  final String? value;
  final bool inProgress;

  @override
  Widget build(BuildContext context) {
    final secondary = context.colors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (inProgress) const _SoonChip(),
        if (value != null)
          Text(
            value!,
            style: context.text.bodyMedium?.copyWith(color: secondary),
          ),
        const SizedBox(width: AppSpacing.xxs),
        Icon(Icons.chevron_right_rounded, color: secondary),
      ],
    );
  }
}

class _SoonChip extends StatelessWidget {
  const _SoonChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs / 2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        AppLocalizations.of(context).soon,
        style: context.text.labelSmall?.copyWith(color: colors.accent),
      ),
    );
  }
}
