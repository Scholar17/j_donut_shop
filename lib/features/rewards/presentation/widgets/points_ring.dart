import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/art_palette.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Glazed-donut progress ring. [sweep] (0–1, already curved by the caller's
/// timeline) drives both the arc and the counted-up total.
class PointsRing extends StatelessWidget {
  const PointsRing({
    required this.size,
    required this.progress,
    required this.points,
    required this.sweep,
    super.key,
  });

  final double size;

  /// Member's progress to the next tier, 0–1.
  final double progress;
  final int points;

  /// Entrance animation value, 0–1.
  final Animation<double> sweep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: sweep,
      builder: (context, _) {
        final t = sweep.value;
        final shown = (points * t).round();
        return Semantics(
          label: '${l10n.totalPoints} ${formatThousands(points)}',
          child: CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              fraction: progress * t,
              track: context.colors.surfaceMuted,
              hole: context.colors.surface,
              glazeLight: context.colors.glazeLight,
              glazeDeep: context.colors.glazeDeep,
            ),
            child: SizedBox.square(
              dimension: size,
              child: ExcludeSemantics(child: _Center(points: shown)),
            ),
          ),
        );
      },
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accent;
    return Center(
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).totalPoints,
              style: context.text.titleSmall?.copyWith(color: accent),
            ),
            Text(
              formatThousands(points),
              style: context.text.headlineMedium?.copyWith(
                color: accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.hole,
    required this.glazeLight,
    required this.glazeDeep,
  });

  final double fraction;
  final Color track;
  final Color hole;
  final Color glazeLight;
  final Color glazeDeep;

  static const _strokeRatio = 0.36;
  static const _startAngle = math.pi * 0.75;
  static const _sprinkleCount = 22;
  static const _sprinkleLength = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.width * _strokeRatio / 2;
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawCircle(center, radius - stroke / 2, Paint()..color = hole);
    if (fraction <= 0) return;
    final sweep = math.pi * 2 * fraction.clamp(0.0, 1.0);
    canvas.drawArc(rect, _startAngle, sweep, false, _glaze(rect, stroke));
    _paintSprinkles(canvas, center, radius, stroke, sweep);
  }

  Paint _glaze(Rect rect, double stroke) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke
    ..strokeCap = StrokeCap.round
    ..shader = SweepGradient(
      colors: [glazeDeep, glazeLight, glazeDeep],
      transform: const GradientRotation(_startAngle),
    ).createShader(rect);

  /// Deterministic sprinkles, only on the part of the glaze already swept.
  void _paintSprinkles(
    Canvas canvas,
    Offset c,
    double r,
    double stroke,
    double sweep,
  ) {
    final paint = Paint()
      ..color = ArtPalette.glazeSprinkle
      ..strokeWidth = stroke * 0.12
      ..strokeCap = StrokeCap.round;
    final random = math.Random(3);
    for (var i = 0; i < _sprinkleCount; i++) {
      final along = random.nextDouble();
      final offset = (random.nextDouble() - 0.5) * stroke * 0.6;
      final tilt = random.nextDouble() * math.pi;
      if (along * math.pi * 2 > sweep) continue;
      final angle = _startAngle + along * math.pi * 2;
      final at = c + Offset(math.cos(angle), math.sin(angle)) * (r + offset);
      final half = Offset(math.cos(tilt), math.sin(tilt)) * r * _sprinkleLength;
      canvas.drawLine(at - half, at + half, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.track != track ||
      old.hole != hole ||
      old.glazeDeep != glazeDeep;
}
