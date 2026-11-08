import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/art_palette.dart';

/// "Drink 12 cups americano": an arc over a painted iced coffee fills to
/// [fraction] (9/12 in the seed).
class CoffeeProgressArt extends StatelessWidget {
  const CoffeeProgressArt({
    required this.size,
    required this.fraction,
    super.key,
  });

  final double size;
  final double fraction;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _CoffeePainter(
      fraction: fraction,
      track: context.colors.surfaceMuted,
      arc: context.colors.highlight,
    ),
  );
}

class _CoffeePainter extends CustomPainter {
  _CoffeePainter({
    required this.fraction,
    required this.track,
    required this.arc,
  });

  final double fraction;
  final Color track;
  final Color arc;

  static const _arcStroke = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    _paintArc(canvas, size);
    _paintGlass(canvas, Rect.fromLTWH(w * 0.32, w * 0.3, w * 0.36, w * 0.62));
  }

  /// Upper semicircle from 9 o'clock to 3 o'clock.
  void _paintArc(Canvas canvas, Size size) {
    final w = size.width;
    final rect = Rect.fromCircle(
      center: Offset(w / 2, w * 0.48),
      radius: w * 0.4,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * _arcStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * fraction.clamp(0.0, 1.0),
        false,
        paint..color = arc,
      );
    }
  }

  void _paintGlass(Canvas canvas, Rect glass) {
    final inset = glass.width * 0.08;
    final cup = Path()
      ..moveTo(glass.left, glass.top)
      ..lineTo(glass.right, glass.top)
      ..lineTo(glass.right - inset, glass.bottom)
      ..lineTo(glass.left + inset, glass.bottom)
      ..close();
    canvas.save();
    canvas.clipPath(cup);
    canvas.drawRect(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ArtPalette.milk, ArtPalette.coffee],
          stops: [0.35, 1],
        ).createShader(glass),
    );
    _paintIce(canvas, glass);
    canvas.restore();
    canvas.drawPath(
      cup,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glass.width * 0.04
        ..color = ArtPalette.glassEdge,
    );
  }

  void _paintIce(Canvas canvas, Rect glass) {
    final cube = glass.width * 0.28;
    final paint = Paint()..color = ArtPalette.ice;
    for (final (dx, dy) in const [(0.15, 0.08), (0.5, 0.15), (0.3, 0.3)]) {
      final r = Rect.fromLTWH(
        glass.left + glass.width * dx,
        glass.top + glass.height * dy,
        cube,
        cube,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(cube * 0.2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CoffeePainter old) =>
      old.fraction != fraction || old.arc != arc;
}
