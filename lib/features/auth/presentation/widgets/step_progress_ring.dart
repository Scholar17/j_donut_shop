import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Registration progress (top right): sweeps from the previous step to
/// [step] on entry. On the final step it reaches 100%, then morphs into a
/// filled circle with a check that draws itself.
class StepProgressRing extends StatefulWidget {
  const StepProgressRing({required this.step, this.totalSteps = 4, super.key});

  final int step;
  final int totalSteps;

  @override
  State<StepProgressRing> createState() => _StepProgressRingState();
}

class _StepProgressRingState extends State<StepProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweep;
  late final Animation<double> _morph;

  bool get _isFinal => widget.step >= widget.totalSteps;

  @override
  void initState() {
    super.initState();
    final sweepMs = AppDurations.progressRing.inMilliseconds;
    final morphMs = _isFinal ? AppDurations.ringToCheckMorph.inMilliseconds : 0;
    final total = sweepMs + morphMs;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    final split = sweepMs / total;
    _sweep = CurvedAnimation(
      parent: _controller,
      curve: Interval(0, split, curve: AppCurves.emphasized),
    );
    _morph = CurvedAnimation(
      parent: _controller,
      curve: Interval(split, 1, curve: AppCurves.overshoot),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.reduceMotion ? _controller.value = 1 : _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final from = (widget.step - 1) / widget.totalSteps;
    final to = widget.step / widget.totalSteps;
    final colors = context.colors;
    return Semantics(
      label: '${widget.step} / ${widget.totalSteps}',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: const Size.square(AppSizes.progressRing),
          painter: _RingPainter(
            progress: from + (to - from) * _sweep.value,
            morph: _isFinal ? _morph.value : 0,
            trackColor: colors.tierPlatinum,
            progressColor: colors.accent,
            checkColor: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.morph,
    required this.trackColor,
    required this.progressColor,
    required this.checkColor,
  });

  final double progress;

  /// 0 = ring, 1 = filled circle with full check.
  final double morph;
  final Color trackColor;
  final Color progressColor;
  final Color checkColor;

  static const _strokeRatio = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.width * _strokeRatio;
    final radius = (size.width - stroke) / 2;
    _paintRing(canvas, center, radius, stroke);
    if (morph > 0) _paintCheck(canvas, size, center);
  }

  void _paintRing(Canvas canvas, Offset center, double radius, double stroke) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * (1 + morph * 2); // outer edge stays at size/2
    final rect = Rect.fromCircle(
      center: center,
      radius: radius * (1 - morph * 0.5),
    );
    canvas.drawArc(rect, 0, math.pi * 2, false, ring..color = trackColor);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      ring..color = progressColor,
    );
  }

  void _paintCheck(Canvas canvas, Size size, Offset center) {
    final w = size.width;
    final path = Path()
      ..moveTo(w * 0.3, w * 0.52)
      ..lineTo(w * 0.45, w * 0.66)
      ..lineTo(w * 0.72, w * 0.38);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * morph.clamp(0, 1));
    canvas.drawPath(
      drawn,
      Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.09
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.morph != morph ||
      old.progressColor != progressColor;
}
