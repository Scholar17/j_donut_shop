import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/art_palette.dart';
import '../../../../core/widgets/donut_art.dart';

/// One coloured circle with a donut, positioned as fractions of the area.
class _CircleSpec {
  const _CircleSpec(
    this.x,
    this.y,
    this.diameter,
    this.color,
    this.donut,
    this.driftFrom,
  );

  /// Centre and diameter as fractions of the available width.
  final double x;
  final double y;
  final double diameter;
  final Color color;
  final DonutStyle donut;

  /// Direction the circle drifts in from (multiplied by [_driftDistance]).
  final Offset driftFrom;
}

/// Onboarding hero: donut circles drift in from off-centre, staggered.
class DriftingDonutCircles extends StatefulWidget {
  const DriftingDonutCircles({super.key});

  @override
  State<DriftingDonutCircles> createState() => _DriftingDonutCirclesState();
}

class _DriftingDonutCirclesState extends State<DriftingDonutCircles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.onboardingDrift,
  );

  static const _driftDistance = 60.0;
  static const _staggerFraction = 0.12;
  static const _donutRatio = 0.74;

  static const _circles = [
    _CircleSpec(
      0.5,
      0.42,
      0.58,
      ArtPalette.circlePeach,
      DonutStyle.strawberry,
      Offset(0, -1),
    ),
    _CircleSpec(
      0.02,
      0.08,
      0.36,
      ArtPalette.circleSky,
      DonutStyle.vanilla,
      Offset(-1, -1),
    ),
    _CircleSpec(
      1.0,
      0.12,
      0.34,
      ArtPalette.circleLilac,
      DonutStyle.chocolate,
      Offset(1, -1),
    ),
    _CircleSpec(
      -0.02,
      0.78,
      0.38,
      ArtPalette.circleLilac,
      DonutStyle.grape,
      Offset(-1, 0),
    ),
    _CircleSpec(
      1.02,
      0.74,
      0.4,
      ArtPalette.circleSky,
      DonutStyle.strawberry,
      Offset(1, 0),
    ),
    _CircleSpec(
      0.5,
      1.02,
      0.44,
      ArtPalette.circleButter,
      DonutStyle.vanilla,
      Offset(0, 1),
    ),
  ];

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
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) => ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < _circles.length; i++)
                _buildCircle(
                  _circles[i],
                  i,
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(
    _CircleSpec spec,
    int index,
    double width,
    double height,
  ) {
    final diameter = spec.diameter * width;
    final start = (index * _staggerFraction).clamp(0.0, 0.6);
    final progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppCurves.entrance),
    );
    return Positioned(
      left: spec.x * width - diameter / 2,
      top: spec.y * height - diameter / 2,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) => Transform.translate(
          offset: spec.driftFrom * _driftDistance * (1 - progress.value),
          child: Opacity(opacity: progress.value, child: child),
        ),
        child: _DonutCircle(
          diameter: diameter,
          spec: spec,
          donutRatio: _donutRatio,
          seed: index,
        ),
      ),
    );
  }
}

class _DonutCircle extends StatelessWidget {
  const _DonutCircle({
    required this.diameter,
    required this.spec,
    required this.donutRatio,
    required this.seed,
  });

  final double diameter;
  final _CircleSpec spec;
  final double donutRatio;
  final int seed;

  @override
  Widget build(BuildContext context) => Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(color: spec.color, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: DonutArt(size: diameter * donutRatio, style: spec.donut, seed: seed),
  );
}
