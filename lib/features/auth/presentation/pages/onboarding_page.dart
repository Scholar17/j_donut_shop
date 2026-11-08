import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/auth_mode.dart';
import '../widgets/drifting_donut_circles.dart';
import '../widgets/legal_footer.dart';

/// Screen 1: "Round food for every mood".
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundTint,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DriftingDonutCircles(),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: _OnboardingContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <Widget>[
      Text(
        l10n.onboardingTitle,
        style: context.text.displaySmall,
        textAlign: TextAlign.center,
      ),
      PrimaryButton(
        key: const Key('onboarding.getStarted'),
        label: l10n.letsGetStarted,
        onPressed: () => context.push(AppRoutes.phone(AuthMode.register)),
      ),
      _LogInPrompt(),
      const _SocialRow(),
      const LegalFooter(),
    ];
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: StaggeredEntrance(
                index: i,
                baseDelay: AppDurations.onboardingContentDelay,
                child: items[i],
              ),
            ),
        ],
      ),
    );
  }
}

class _LogInPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('${l10n.alreadyHaveAccount} ', style: context.text.bodyMedium),
        PressableScale(
          key: const Key('onboarding.logIn'),
          onTap: () => context.push(AppRoutes.phone(AuthMode.login)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              l10n.logIn,
              style: context.text.titleSmall?.copyWith(
                color: context.colors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          label: l10n.google,
          child: Text(
            'G',
            style: context.text.titleLarge?.copyWith(color: colors.danger),
          ),
        ),
        _SocialButton(
          label: l10n.apple,
          child: Icon(Icons.apple, color: colors.textPrimary),
        ),
        _SocialButton(
          label: l10n.facebook,
          child: Icon(Icons.facebook, color: colors.primary),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: PressableScale(
      onTap: () => showComingSoon(context, label),
      child: SizedBox.square(
        dimension: AppSizes.iconButton + AppSpacing.md,
        child: Center(child: child),
      ),
    ),
  );
}
