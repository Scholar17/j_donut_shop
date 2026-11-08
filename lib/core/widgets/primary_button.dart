import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'pressable_scale.dart';

/// Full-width pill CTA (Continue, Let's get started).
///
/// Scales on press; while [isLoading] it morphs into a circle with a spinner
/// and ignores taps, so it can never fire twice.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;

  /// `null` renders the disabled state.
  final VoidCallback? onPressed;
  final bool isLoading;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: PressableScale(
            onTap: _enabled ? onPressed : null,
            child: AnimatedContainer(
              duration: context.motion(AppDurations.medium),
              curve: AppCurves.emphasized,
              height: AppSizes.buttonHeight,
              width: isLoading ? AppSizes.buttonHeight : constraints.maxWidth,
              decoration: BoxDecoration(
                color: onPressed == null ? colors.disabled : colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              alignment: Alignment.center,
              child: _ButtonContent(label: label, isLoading: isLoading),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.isLoading});

  final String label;
  final bool isLoading;

  static const _spinnerSize = 22.0;
  static const _spinnerStroke = 2.5;

  @override
  Widget build(BuildContext context) {
    final onPrimary = context.colors.onPrimary;
    return AnimatedSwitcher(
      duration: context.motion(AppDurations.fast),
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: _spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: _spinnerStroke,
                color: onPrimary,
              ),
            )
          : Text(
              label.toUpperCase(),
              key: const ValueKey('label'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: context.text.labelLarge?.copyWith(color: onPrimary),
            ),
    );
  }
}
