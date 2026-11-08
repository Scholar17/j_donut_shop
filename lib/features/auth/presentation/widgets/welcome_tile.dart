import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/donut_art.dart';

/// One rounded colour tile with a donut; slides in from [fromLeft] side
/// after `index × staggerStep`.
class WelcomeTile extends StatefulWidget {
  const WelcomeTile({
    required this.index,
    required this.color,
    required this.donut,
    required this.fromLeft,
    super.key,
  });

  final int index;
  final Color color;
  final DonutStyle donut;
  final bool fromLeft;

  @override
  State<WelcomeTile> createState() => _WelcomeTileState();
}

class _WelcomeTileState extends State<WelcomeTile> {
  bool _visible = false;

  static const _travel = 0.6;
  static const _donutRatio = 0.82;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppDurations.staggerStep * widget.index * 2, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(AppDurations.emphasized);
    final shown = _visible || context.reduceMotion;
    return AnimatedSlide(
      offset: shown
          ? Offset.zero
          : Offset(widget.fromLeft ? -_travel : _travel, 0),
      duration: duration,
      curve: AppCurves.emphasized,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: duration,
        curve: AppCurves.standard,
        child: _tile(),
      ),
    );
  }

  Widget _tile() => DecoratedBox(
    decoration: BoxDecoration(
      color: widget.color,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Center(
        child: DonutArt(
          size: constraints.biggest.shortestSide * _donutRatio,
          style: widget.donut,
          seed: widget.index + 11,
        ),
      ),
    ),
  );
}
