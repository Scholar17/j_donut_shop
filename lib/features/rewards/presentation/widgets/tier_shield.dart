import 'package:flutter/material.dart';

import '../../../../core/theme/art_palette.dart';

/// Shield badge with the tier initial, drawn with [CustomPainter].
class TierShield extends StatelessWidget {
  const TierShield({
    required this.color,
    required this.letter,
    required this.size,
    this.highlighted = false,
    super.key,
  });

  final Color color;
  final String letter;
  final double size;

  /// Current tier: full colour plus a soft glow.
  final bool highlighted;

  static const _letterRatio = 0.42;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.1),
      painter: _ShieldPainter(color: color, highlighted: highlighted),
      child: SizedBox(
        width: size,
        height: size * 1.1,
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: size * _letterRatio,
              fontWeight: FontWeight.w900,
              color: Color.lerp(color, ArtPalette.shadow, 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter({required this.color, required this.highlighted});

  final Color color;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.7, h * 0.08, w * 0.85, h * 0.1, w, h * 0.12)
      ..lineTo(w, h * 0.5)
      ..cubicTo(w, h * 0.78, w * 0.72, h * 0.92, w * 0.5, h)
      ..cubicTo(w * 0.28, h * 0.92, 0, h * 0.78, 0, h * 0.5)
      ..lineTo(0, h * 0.12)
      ..cubicTo(w * 0.15, h * 0.1, w * 0.3, h * 0.08, w * 0.5, 0)
      ..close();
    if (highlighted) {
      canvas.drawShadow(path, color, w * 0.12, false);
    }
    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, ArtPalette.milk, 0.45)!, color],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) =>
      old.color != color || old.highlighted != highlighted;
}
