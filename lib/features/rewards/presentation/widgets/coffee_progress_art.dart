import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/art_palette.dart';

/// "Drink 12 cups americano": an arc over the iced-coffee photo fills to
/// [fraction] (9/12 in the seed). A painted glass is the fallback.
class CoffeeProgressArt extends StatelessWidget {
  const CoffeeProgressArt({
    required this.size,
    required this.fraction,
    super.key,
  });

  final double size;
  final double fraction;

  static const _cupWidth = 0.46;
  static const _cupTop = 0.2;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      children: [
        Positioned(
          left: size * (1 - _cupWidth) / 2,
          top: size * _cupTop,
          width: size * _cupWidth,
          bottom: 0,
          child: Image.asset(
            AppAssets.challengeCoffee,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => CustomPaint(
              painter: _CoffeePainter(
                fraction: 0,
                track: context.colors.surfaceMuted,
                arc: context.colors.highlight,
                withGlass: true,
              ),
            ),
          ),
        ),
        CustomPaint(
          size: Size.square(size),
          painter: _CoffeePainter(
            fraction: fraction,
            track: context.colors.surfaceMuted,
            arc: context.colors.highlight,
          ),
        ),
      ],
    ),
  );
}

class _CoffeePainter extends CustomPainter {
  _CoffeePainter({
    required this.fraction,
    required this.track,
    required this.arc,
    this.withGlass = false,
  });

  final double fraction;
  final Color track;
  final Color arc;

  /// Paint the fallback glass instead of the arc (photo failed to load).
  final bool withGlass;

  static const _arcStroke = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    if (withGlass) {
      _paintGlass(canvas, Offset.zero & size);
      return;
    }
    _paintArc(canvas, size);
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
