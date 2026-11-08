import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'pressable_scale.dart';

/// Inline error under a field: grows/shrinks smoothly and fades between
/// messages. Optional [actionLabel] renders a tappable link after the text.
class FieldErrorText extends StatelessWidget {
  const FieldErrorText({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// `null` hides the line.
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(AppDurations.fast);
    return AnimatedSize(
      duration: duration,
      curve: AppCurves.standard,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: duration,
        child: message == null
            ? const SizedBox(width: double.infinity, key: ValueKey('none'))
            : _Message(
                key: ValueKey(message),
                message: message!,
                actionLabel: actionLabel,
                onAction: onAction,
              ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Semantics(
        liveRegion: true,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xxs,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppSpacing.md,
              color: colors.danger,
            ),
            Text(
              message,
              style: context.text.bodySmall?.copyWith(color: colors.danger),
            ),
            if (actionLabel != null)
              PressableScale(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
