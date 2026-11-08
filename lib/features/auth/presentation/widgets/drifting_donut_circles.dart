import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/motion/app_motion.dart';

/// One photo layer, placed on the 944 × 1680 design canvas it was cut from.
class _Layer {
  const _Layer(this.asset, this.rect, this.driftFrom);

  final String asset;

  /// Position and size in design-canvas pixels.
  final Rect rect;

  /// Unit direction the circle drifts in from.
  final Offset driftFrom;
}

/// Onboarding hero: six donut circles (Canva art) that drift in one by one.
///
/// The canvas is scaled to the screen width (anchored top), so every phone
/// shows the full composition; the content sits below the faded circles.
class DriftingDonutCircles extends StatefulWidget {
  const DriftingDonutCircles({super.key});

  /// Design canvas the layer rects are measured on.
  static const canvasSize = Size(944, 1680);

  @override
  State<DriftingDonutCircles> createState() => _DriftingDonutCirclesState();
}

class _DriftingDonutCirclesState extends State<DriftingDonutCircles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.onboardingDrift,
  );

  /// Travel distance in canvas pixels.
  static const _driftDistance = 120.0;
  static const _staggerFraction = 0.1;
  static const _settleScaleFrom = 0.9;

  /// Fade band (canvas y) that dissolves the lowest circles into the page.
  static const _fadeFromY = 700.0;
  static const _fadeToY = 870.0;

  static const _layers = [
    _Layer(
      AppAssets.onboardingCenter,
      Rect.fromLTWH(239, 154, 482, 479),
      Offset(0, -0.6),
    ),
    _Layer(
      AppAssets.onboardingTopLeft,
      Rect.fromLTWH(0, 0, 179, 366),
      Offset(-1, -0.6),
    ),
    _Layer(
      AppAssets.onboardingTopRight,
      Rect.fromLTWH(788, 0, 156, 326),
      Offset(1, -0.6),
    ),
    _Layer(
      AppAssets.onboardingLeft,
      Rect.fromLTWH(0, 428, 179, 348),
      Offset(-1, 0),
    ),
    _Layer(
      AppAssets.onboardingRight,
      Rect.fromLTWH(806, 395, 138, 383),
      Offset(1, 0),
    ),
    _Layer(
      AppAssets.onboardingBottom,
      Rect.fromLTWH(267, 693, 432, 167),
      Offset(0, 1),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final layer in _layers) {
      precacheImage(AssetImage(layer.asset), context);
    }
    context.reduceMotion ? _controller.value = 1 : _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const canvas = DriftingDonutCircles.canvasSize;
    return ExcludeSemantics(
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          child: SizedBox.fromSize(
            size: canvas,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: _bottomFade,
              child: Stack(
                children: [
                  for (var i = 0; i < _layers.length; i++)
                    _buildLayer(_layers[i], i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Shader _bottomFade(Rect bounds) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [_fadeFromY / bounds.height, _fadeToY / bounds.height],
    colors: const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
  ).createShader(bounds);

  Widget _buildLayer(_Layer layer, int index) {
    final start = index * _staggerFraction;
    final progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppCurves.entrance),
    );
    return Positioned.fromRect(
      rect: layer.rect,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) {
          final t = progress.value;
          return Transform.translate(
            offset: layer.driftFrom * _driftDistance * (1 - t),
            child: Transform.scale(
              scale: _settleScaleFrom + (1 - _settleScaleFrom) * t,
              child: Opacity(opacity: t, child: child),
            ),
          );
        },
        child: Image.asset(
          layer.asset,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
