import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/art_palette.dart';

/// Metallic shield badge: a darker rim around a lighter face, [stars] small
/// stars across the top and the tier initial below them. Drawn with
/// [CustomPainter].
class TierShield extends StatelessWidget {
  const TierShield({
    required this.color,
    required this.letter,
    required this.size,
    this.stars = 0,
    this.highlighted = false,
    super.key,
  });

  final Color color;
  final String letter;
  final double size;

  /// Tier rank shown as stars above the letter (Silver 1 … Platinum 3).
  final int stars;

  /// Current tier: a soft glow under the shield.
  final bool highlighted;

  static const heightRatio = 1.12;
  static const _letterRatio = 0.4;

  /// Letter sits lower when stars take the top of the face.
  static const _letterDropWithStars = 0.32;
  static const _inkDarken = 0.45;

  /// Ink for the letter and stars: the tier colour, darkened.
  static Color inkFor(Color color) =>
      Color.lerp(color, ArtPalette.shadow, _inkDarken)!;

  @override
  Widget build(BuildContext context) {
    final height = size * heightRatio;
    return CustomPaint(
      size: Size(size, height),
      painter: _ShieldPainter(
        color: color,
        stars: stars,
        highlighted: highlighted,
      ),
      child: SizedBox(
        width: size,
        height: height,
        child: Align(
          // Below the stars.
          alignment: Alignment(0, stars > 0 ? _letterDropWithStars : 0),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: size * _letterRatio,
              fontWeight: FontWeight.w900,
              height: 1,
              color: inkFor(color),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter({
    required this.color,
    required this.stars,
    required this.highlighted,
  });

  final Color color;
  final int stars;
  final bool highlighted;

  /// Face inset from the rim, as a fraction of the width.
  static const _rim = 0.09;

  // Bevel shading: rim top/bottom darken, face top lightens.
  static const _rimTopDarken = 0.05;
  static const _rimBottomDarken = 0.25;
  static const _faceTopLighten = 0.55;
  static const _glowRatio = 0.1;

  // Stars: radius, centre spacing (in radii), row height, inner-point
  // depth and the crown lift of the middle star (in radii).
  static const _starRadiusRatio = 0.085;
  static const _starSpacing = 2.3;
  static const _starRowRatio = 0.3;
  static const _starInnerRatio = 0.45;
  static const _starPoints = 5;
  static const _crownLift = 0.5;

  static Path _shield(Rect r) {
    final w = r.width, h = r.height, x = r.left, y = r.top;
    return Path()
      ..moveTo(x + w * 0.5, y)
      ..cubicTo(
        x + w * 0.7,
        y + h * 0.08,
        x + w * 0.85,
        y + h * 0.1,
        x + w,
        y + h * 0.12,
      )
      ..lineTo(x + w, y + h * 0.5)
      ..cubicTo(
        x + w,
        y + h * 0.78,
        x + w * 0.72,
        y + h * 0.92,
        x + w * 0.5,
        y + h,
      )
      ..cubicTo(x + w * 0.28, y + h * 0.92, x, y + h * 0.78, x, y + h * 0.5)
      ..lineTo(x, y + h * 0.12)
      ..cubicTo(
        x + w * 0.15,
        y + h * 0.1,
        x + w * 0.3,
        y + h * 0.08,
        x + w * 0.5,
        y,
      )
      ..close();
  }

  static Path _star(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < _starPoints * 2; i++) {
      final radius = i.isEven ? r : r * _starInnerRatio;
      final a = -math.pi / 2 + i * math.pi / _starPoints;
      final p = c + Offset(math.cos(a) * radius, math.sin(a) * radius);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Offset.zero & size;
    final rimPath = _shield(outer);
    if (highlighted) {
      canvas.drawShadow(rimPath, color, size.width * _glowRatio, false);
    }
    // Rim: the tier colour, a little darker, lighter at the top.
    canvas.drawPath(
      rimPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, ArtPalette.shadow, _rimTopDarken)!,
            Color.lerp(color, ArtPalette.shadow, _rimBottomDarken)!,
          ],
        ).createShader(outer),
    );
    // Face: lighter, so the rim reads as a bevel.
    final inset = size.width * _rim;
    final face = outer.deflate(inset);
    canvas.drawPath(
      _shield(face),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, ArtPalette.milk, _faceTopLighten)!, color],
        ).createShader(face),
    );
    // Stars in a row across the top of the face.
    if (stars > 0) {
      final ink = Paint()..color = TierShield.inkFor(color);
      final r = size.width * _starRadiusRatio;
      final spacing = r * _starSpacing;
      final cy = size.height * _starRowRatio;
      final first = size.width / 2 - spacing * (stars - 1) / 2;
      for (var i = 0; i < stars; i++) {
        // Middle star of three sits slightly higher, like a crown.
        final lift = stars == 3 && i == 1 ? r * _crownLift : 0.0;
        canvas.drawPath(_star(Offset(first + spacing * i, cy - lift), r), ink);
      }
    }
  }

  @override
  bool shouldRepaint(_ShieldPainter old) =>
      old.color != color ||
      old.stars != stars ||
      old.highlighted != highlighted;
}
