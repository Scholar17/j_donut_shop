import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/generated/app_localizations.dart';
import '../connectivity/connectivity_cubit.dart';
import '../motion/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Small pill that slides down while offline and away when back online.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityCubit>().state;
    final colors = context.colors;
    return AnimatedSlide(
      offset: online ? const Offset(0, -1.5) : Offset.zero,
      duration: context.motion(AppDurations.medium),
      curve: AppCurves.emphasized,
      child: AnimatedOpacity(
        opacity: online ? 0 : 1,
        duration: context.motion(AppDurations.medium),
        child: Semantics(
          liveRegion: true,
          child: Container(
            key: const Key('offlineBanner'),
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: AppSpacing.md,
                  color: colors.background,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppLocalizations.of(context).offlineBanner,
                  style: context.text.labelMedium?.copyWith(
                    color: colors.background,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
