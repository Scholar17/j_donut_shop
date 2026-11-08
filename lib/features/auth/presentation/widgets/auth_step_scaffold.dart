import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'legal_footer.dart';
import 'step_progress_ring.dart';

/// Shared layout of every registration step (screens 2–6): back button,
/// progress ring, title, step content, Continue and the legal footer.
class AuthStepScaffold extends StatelessWidget {
  const AuthStepScaffold({
    this.step,
    required this.title,
    required this.body,
    this.subtitle,
    this.hint,
    this.action,
    super.key,
  });

  /// 1-based step for the progress ring; `null` hides the ring.
  final int? step;
  final String title;
  final Widget body;

  final String? subtitle;

  /// Highlighted helper line under the subtitle (e.g. the demo OTP code).
  final String? hint;

  /// Usually a [PrimaryButton]; `null` for steps that submit themselves (OTP).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.colors.backgroundTint, context.colors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                _Header(step: step),
                const SizedBox(height: AppSpacing.lg),
                Text(title, style: context.text.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: context.text.bodyMedium),
                ],
                if (hint != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    hint!,
                    key: const Key('auth.hint'),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Expanded(child: SingleChildScrollView(child: body)),
                const SizedBox(height: AppSpacing.md),
                ?action,
                const LegalFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.step});
  final int? step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Semantics(
          button: true,
          label: AppLocalizations.of(context).back,
          child: PressableScale(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: AppSizes.iconButton,
              height: AppSizes.iconButton,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ),
        if (step != null) StepProgressRing(step: step!),
      ],
    );
  }
}
