import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/presentation/widgets/profile_card.dart';

/// Tinted band at the top of Settings: profile row and the e-wallet pill.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.headerTint,
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(),
              SizedBox(height: AppSpacing.lg),
              _EWalletPill(),
            ],
          ),
        ),
      ),
    );
  }
}

/// "E-wallet Customer >": not built yet, so it shows a coming-soon snackbar.
class _EWalletPill extends StatelessWidget {
  const _EWalletPill();

  static const _chevronSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).eWalletCustomer;
    final colors = context.colors;
    return PressableScale(
      key: const Key('settings.eWallet'),
      onTap: () => showComingSoon(context, label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: colors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: context.text.labelLarge),
            const SizedBox(width: AppSpacing.xxs),
            const Icon(Icons.chevron_right_rounded, size: _chevronSize),
          ],
        ),
      ),
    );
  }
}
