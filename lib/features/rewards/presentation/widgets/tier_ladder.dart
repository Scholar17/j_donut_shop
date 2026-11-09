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
///
/// Each rung owns the connector under its shield, running from the bottom of
/// one shield to the top of the next. Rungs with a next tier have a minimum
/// height, so connectors are all the same length unless very large text
/// needs more room.
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

  static const _shieldSize = 46.0;

  /// Length of every connector line between two shields.
  static const _connectorLength = 44.0;
  static const _lineWidth = 3.0;
  static const _rungStep = 0.14;
  static const _rungSpan = 0.3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiers.length; i++) _animatedRung(context, i),
      ],
    );
  }

  Widget _animatedRung(BuildContext context, int index) {
    final start = index * _rungStep;
    final appear = CurvedAnimation(
      parent: entrance,
      curve: Interval(start, start + _rungSpan, curve: AppCurves.overshoot),
    );
    final hasNext = index < tiers.length - 1;
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
        connectorLength: _connectorLength,
        connector: hasNext ? _connector(context, index) : null,
      ),
    );
  }

  /// Vertical line under a shield; the segment leaving the current tier
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
    return SizedBox(
      width: _lineWidth,
      child: AnimatedBuilder(
        animation: fill,
        builder: (context, _) => CustomPaint(
          key: Key('tierLadder.connector.${tier.level.name}'),
          painter: _LinePainter(
            fraction: target * fill.value,
            track: context.colors.border,
            filled: context.colors.textSecondary,
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
    required this.connectorLength,
    required this.connector,
  });

  final Tier tier;
  final TierProgress progress;
  final double shieldSize;
  final double connectorLength;

  /// Line down to the next shield; `null` on the last rung.
  final Widget? connector;

  /// Name starts a little below the shield's top edge (its shoulder).
  static const _textTopRatio = 0.12;

  Color _color(BuildContext context) => switch (tier.level) {
    TierLevel.bronze || TierLevel.silver => context.colors.tierSilver,
    TierLevel.gold => context.colors.tierGold,
    TierLevel.platinum => context.colors.tierPlatinum,
  };

  int get _stars => switch (tier.level) {
    TierLevel.bronze => 0,
    TierLevel.silver => 1,
    TierLevel.gold => 2,
    TierLevel.platinum => 3,
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
    final row = Row(
      // Stretch only inside the fixed-height rung; the last rung sizes to
      // its content.
      crossAxisAlignment: connector == null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: shieldSize,
          child: Column(
            children: [
              TierShield(
                color: _color(context),
                letter: name.characters.first,
                size: shieldSize,
                stars: _stars,
                highlighted: isCurrent,
              ),
              if (connector != null) Expanded(child: connector!),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: shieldSize * _textTopRatio),
            child: _RungText(
              name: name,
              subtitle: _subtitle(l10n),
              isCurrent: isCurrent,
            ),
          ),
        ),
      ],
    );
    if (connector == null) return row;
    // At least shield + connector tall, so every line has the same length
    // at normal text sizes; large text (1.3x on a small phone) may make a
    // rung taller, and its connector simply grows instead of overflowing.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: shieldSize * TierShield.heightRatio + connectorLength,
      ),
      child: IntrinsicHeight(child: row),
    );
  }
}

/// Tier name (bold) and the status line under it.
class _RungText extends StatelessWidget {
  const _RungText({
    required this.name,
    required this.subtitle,
    required this.isCurrent,
  });

  final String name;
  final String subtitle;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: context.text.bodySmall?.copyWith(
            color: isCurrent ? colors.textPrimary : colors.textSecondary,
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
