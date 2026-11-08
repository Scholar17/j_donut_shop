import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/l10n/formatters.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/donut_art.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../member/domain/entities/challenge.dart';
import 'coffee_progress_art.dart';
import 'earn_button.dart';
import 'sweep_reveal.dart';

/// One challenge. Enters after `index × stagger`, then its artwork fills to
/// the challenge progress (donut by quarters, coffee arc to 9/12).
class ChallengeCard extends StatefulWidget {
  const ChallengeCard({
    required this.challenge,
    required this.index,
    super.key,
  });

  final Challenge challenge;
  final int index;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow + AppDurations.challengeFill,
  );

  static const _artSize = 112.0;
  static const _enterEnd = 0.35;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.value = 1;
      return;
    }
    Future<void>.delayed(AppDurations.staggerStep * 2 * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enter = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, _enterEnd, curve: AppCurves.entrance),
    );
    final fill = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_enterEnd, 1, curve: AppCurves.sweep),
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: enter.value,
        child: Transform.translate(
          offset: Offset(
            0,
            AppMotionValues.entranceOffset * 2 * (1 - enter.value),
          ),
          child: child,
        ),
      ),
      child: _card(context, fill),
    );
  }

  Widget _card(BuildContext context, Animation<double> fill) {
    final challenge = widget.challenge;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: fill,
            builder: (context, _) => _art(challenge.fraction * fill.value),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: context.text.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${challenge.progress}/${challenge.target}',
                  style: context.text.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EarnButton(active: challenge.isComplete),
                    Text(
                      l10n.pointsShort(formatThousands(challenge.rewardPoints)),
                      style: context.text.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _art(double fraction) => switch (widget.challenge.art) {
    // Photo in greyscale, colour sweeping in by quarters; painted fallback.
    ChallengeArt.donut => SizedBox.square(
      dimension: _artSize,
      child: SweepReveal(
        fraction: fraction,
        child: Image.asset(
          AppAssets.challengeDonut,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => DonutArt(
            size: _artSize,
            frostedFraction: fraction,
            seed: widget.index + 21,
          ),
        ),
      ),
    ),
    ChallengeArt.coffee => CoffeeProgressArt(
      size: _artSize,
      fraction: fraction,
    ),
  };
}
