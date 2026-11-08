import 'package:flutter/material.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../member/domain/entities/tier.dart';
import '../../../member/presentation/tier_labels.dart';
import 'tier_shield.dart';

/// Silver → Gold → Platinum. Rungs appear in order on [entrance]; the line
/// from the current tier to the next fills to the member's progress.
class TierLadder extends StatelessWidget {
  const TierLadder({
    required this.tiers,
    required this.progress,
    required this.entrance,
    super.key,
  });

  final List<Tier> tiers;
  final TierProgress progress;
  final Animation<double> entrance;

  static const _shieldSize = 40.0;
  static const _gap = 56.0;
  static const _lineWidth = 3.0;
  static const _rungStep = 0.14;
  static const _rungSpan = 0.3;

  @override
  Widget build(BuildContext context) {
    final rungs = <Widget>[];
    for (var i = 0; i < tiers.length; i++) {
      rungs.add(_animatedRung(context, i));
      if (i < tiers.length - 1) rungs.add(_connector(context, i));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rungs,
    );
  }

  Widget _animatedRung(BuildContext context, int index) {
    final start = index * _rungStep;
    final appear = CurvedAnimation(
      parent: entrance,
      curve: Interval(start, start + _rungSpan, curve: AppCurves.overshoot),
    );
    return AnimatedBuilder(
      animation: appear,
      builder: (context, child) => Opacity(
        opacity: appear.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(
            -AppMotionValues.entranceOffset * (1 - appear.value),
            0,
          ),
          child: child,
        ),
      ),
      child: _Rung(
        tier: tiers[index],
        progress: progress,
        shieldSize: _shieldSize,
      ),
    );
  }

  /// Vertical line between two shields; the segment leaving the current tier
  /// fills to the progress fraction, passed segments are full.
  Widget _connector(BuildContext context, int index) {
    final tier = tiers[index];
    final target = switch (tier.minPoints.compareTo(
      progress.current.minPoints,
    )) {
      < 0 => 1.0,
      0 => progress.fractionToNext,
      _ => 0.0,
    };
    final fill = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.45, 0.85, curve: AppCurves.sweep),
    );
    return Padding(
      padding: const EdgeInsets.only(left: _shieldSize / 2 - _lineWidth / 2),
      child: SizedBox(
        width: _lineWidth,
        height: _gap,
        child: AnimatedBuilder(
          animation: fill,
          builder: (context, _) => CustomPaint(
            painter: _LinePainter(
              fraction: target * fill.value,
              track: context.colors.border,
              filled: context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Rung extends StatelessWidget {
  const _Rung({
    required this.tier,
    required this.progress,
    required this.shieldSize,
  });

  final Tier tier;
  final TierProgress progress;
  final double shieldSize;

  Color _color(BuildContext context) => switch (tier.level) {
    TierLevel.bronze || TierLevel.silver => context.colors.tierSilver,
    TierLevel.gold => context.colors.tierGold,
    TierLevel.platinum => context.colors.tierPlatinum,
  };

  String _subtitle(AppLocalizations l10n) {
    if (tier == progress.current) return l10n.youAreHereNow;
    if (tier == progress.next) {
      return l10n.ptsRemainingToBecome(
        formatThousands(progress.pointsToNext),
        tier.level.label(l10n),
      );
    }
    return tier.minPoints < progress.current.minPoints
        ? l10n.tierReached
        : l10n.youllBeHereSoon;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCurrent = tier == progress.current;
    final name = tier.level.label(l10n);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TierShield(
          color: _color(context),
          letter: name.characters.first,
          size: shieldSize,
          highlighted: isCurrent,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.text.titleMedium),
              Text(
                _subtitle(l10n),
                style: context.text.bodySmall?.copyWith(
                  color: isCurrent
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.fraction,
    required this.track,
    required this.filled,
  });

  final double fraction;
  final Color track;
  final Color filled;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final paint = Paint()
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint..color = track);
    if (fraction > 0) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * fraction),
        paint..color = filled,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.fraction != fraction || old.track != track;
}
