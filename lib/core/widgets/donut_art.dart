import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/art_palette.dart';

/// Colours for one painted donut. Brand art, so these are art tokens, not UI.
@immutable
class DonutStyle {
  const DonutStyle({
    required this.frosting,
    this.dough = ArtPalette.dough,
    this.unfrosted = ArtPalette.unfrosted,
    this.sprinkles = ArtPalette.sprinkles,
  });

  final Color frosting;
  final Color dough;

  /// Shown where [DonutArt.frostedFraction] has not reached yet.
  final Color unfrosted;
  final List<Color> sprinkles;

  static const strawberry = DonutStyle(frosting: ArtPalette.strawberry);
  static const grape = DonutStyle(frosting: ArtPalette.grape);
  static const chocolate = DonutStyle(frosting: ArtPalette.chocolate);
  static const vanilla = DonutStyle(frosting: ArtPalette.vanilla);
}

/// A donut drawn with [CustomPainter]: dough, wavy frosting and seeded
/// sprinkles. [frostedFraction] (0–1) colours the frosting in clockwise from
/// 12 o'clock, used by Rewards challenge progress (1/4, 4/4).
class DonutArt extends StatelessWidget {
  const DonutArt({
    required this.size,
    this.style = DonutStyle.strawberry,
    this.frostedFraction = 1,
    this.seed = 7,
    super.key,
  });

  final double size;
  final DonutStyle style;
  final double frostedFraction;

  /// Same seed → same sprinkle layout on every frame (no flicker).
  final int seed;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(size),
      painter: DonutPainter(
        style: style,
        frostedFraction: frostedFraction,
        seed: seed,
      ),
    ),
  );
}

class DonutPainter extends CustomPainter {
  DonutPainter({
    required this.style,
    required this.frostedFraction,
    required this.seed,
  });

  final DonutStyle style;
  final double frostedFraction;
  final int seed;

  static const _holeRatio = 0.17;
  static const _frostingInner = 0.24;
  static const _frostingOuter = 0.44;
  static const _waves = 9;
  static const _waveDepth = 0.025;
  static const _sprinkleCount = 34;

  @override
  void paint(Canvas canvas, Size size) {
    // Radii below are fractions of the full width, so the dough ring
    // (0.48 × width radius) fills ~96% of the box.
    final r = size.width;
    final c = size.center(Offset.zero);
    _paintDough(canvas, c, r);
    final frosting = _frostingPath(c, r);
    canvas.drawPath(frosting, Paint()..color = style.unfrosted);
    canvas.save();
    canvas.clipPath(_sweepClip(c, r));
    canvas.drawPath(frosting, Paint()..color = style.frosting);
    _paintSprinkles(canvas, c, r);
    canvas.restore();
    _paintHighlight(canvas, c, r);
  }

  void _paintDough(Canvas canvas, Offset c, double r) {
    final dough = Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: c, radius: r * 0.48))
      ..addOval(Rect.fromCircle(center: c, radius: r * _holeRatio));
    canvas.drawShadow(dough, ArtPalette.shadow, r * 0.06, false);
    canvas.drawPath(dough, Paint()..color = style.dough);
  }

  /// Ring with a wavy outer edge, like dripping glaze.
  Path _frostingPath(Offset c, double r) {
    final outer = Path();
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * math.pi * 2;
      final radius = r * (_frostingOuter + _waveDepth * math.sin(t * _waves));
      final point = c + Offset(math.cos(t), math.sin(t)) * radius;
      i == 0
          ? outer.moveTo(point.dx, point.dy)
          : outer.lineTo(point.dx, point.dy);
    }
    return Path.combine(
      PathOperation.difference,
      outer..close(),
      Path()..addOval(Rect.fromCircle(center: c, radius: r * _frostingInner)),
    );
  }

  Path _sweepClip(Offset c, double r) {
    final fraction = frostedFraction.clamp(0.0, 1.0);
    if (fraction >= 1) {
      return Path()..addRect(Rect.fromCircle(center: c, radius: r));
    }
    return Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
      )
      ..close();
  }

  void _paintSprinkles(Canvas canvas, Offset c, double r) {
    final random = math.Random(seed);
    final paint = Paint()
      ..strokeWidth = r * 0.035
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _sprinkleCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = r * (_frostingInner + 0.04 + random.nextDouble() * 0.14);
      final at = c + Offset(math.cos(angle), math.sin(angle)) * distance;
      final tilt = random.nextDouble() * math.pi;
      final half = Offset(math.cos(tilt), math.sin(tilt)) * r * 0.035;
      paint.color = style.sprinkles[i % style.sprinkles.length];
      canvas.drawLine(at - half, at + half, paint);
    }
  }

  void _paintHighlight(Canvas canvas, Offset c, double r) {
    final rect = Rect.fromCircle(center: c, radius: r * 0.36);
    canvas.drawArc(
      rect,
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      Paint()
        ..color = ArtPalette.highlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.04
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.frostedFraction != frostedFraction ||
      old.style != style ||
      old.seed != seed;
}
