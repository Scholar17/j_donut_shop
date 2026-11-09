import 'package:flutter/material.dart';

/// Line icon of a donut seen side-on: an outer ring, a glaze line across the
/// middle and the hole in the centre. Sized like a Material [Icon].
class DonutOutlineIcon extends StatelessWidget {
  const DonutOutlineIcon({required this.color, this.size = 24, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _DonutPainter(color)),
  );
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.color);

  final Color color;

  /// Proportions of the 24-px icon grid.
  static const _stroke = 2 / 24;
  static const _outerRadius = 9 / 24;
  static const _holeRadius = 2.6 / 24;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * _stroke
      ..strokeCap = StrokeCap.round;
    final outer = s * _outerRadius;
    final hole = s * _holeRadius;
    canvas
      ..drawCircle(center, outer, paint)
      ..drawCircle(center, hole, paint)
      ..drawLine(center.translate(-outer, 0), center.translate(-hole, 0), paint)
      ..drawLine(center.translate(hole, 0), center.translate(outer, 0), paint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.color != color;
}
