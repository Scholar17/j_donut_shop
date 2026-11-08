import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Orange "Rewards (3)" pill flush with the right edge; pops in on entry.
class RewardsBadge extends StatelessWidget {
  const RewardsBadge({required this.count, required this.entrance, super.key});

  final int count;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pop = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.05, 0.45, curve: AppCurves.pop),
    );
    return ScaleTransition(
      scale: pop,
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.pageGutter,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.highlight,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(AppRadius.pill),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).rewards,
              style: context.text.titleMedium?.copyWith(
                color: colors.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            CircleAvatar(
              radius: AppSpacing.sm,
              backgroundColor: colors.surface,
              child: Text('$count', style: context.text.labelMedium),
            ),
          ],
        ),
      ),
    );
  }
}
