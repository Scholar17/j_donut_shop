import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows [child] in greyscale, with full colour sweeping in clockwise from
/// 12 o'clock up to [fraction] (the donut "colours in by quarters").
class SweepReveal extends StatelessWidget {
  const SweepReveal({required this.child, required this.fraction, super.key});

  final Widget child;
  final double fraction;

  /// Luminance-preserving greyscale.
  static const _greyscale = ColorFilter.matrix([
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.55,
          child: ColorFiltered(colorFilter: _greyscale, child: child),
        ),
        ClipPath(clipper: _SweepClipper(fraction), child: child),
      ],
    );
  }
}

class _SweepClipper extends CustomClipper<Path> {
  _SweepClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    final f = fraction.clamp(0.0, 1.0);
    if (f >= 1) return Path()..addRect(rect);
    final center = rect.center;
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: size.longestSide),
        -math.pi / 2,
        math.pi * 2 * f,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_SweepClipper old) => old.fraction != fraction;
}
