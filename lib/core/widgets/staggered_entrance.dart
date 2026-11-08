import 'package:flutter/material.dart';

import '../motion/app_motion.dart';

/// Fades and slides [child] up after `index × staggerStep`.
///
/// Uses one implicit animation per item (no controller bookkeeping) and
/// renders immediately when Reduce Motion is on.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.offset = AppMotionValues.entranceOffset,
    super.key,
  });

  final int index;
  final Widget child;
  final Duration baseDelay;

  /// Vertical travel in logical pixels.
  final double offset;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = widget.baseDelay + AppDurations.staggerStep * widget.index;
    Future<void>.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _visible ? 1 : 0),
      duration: AppDurations.slow,
      curve: AppCurves.entrance,
      child: widget.child,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - progress)),
          child: child,
        ),
      ),
    );
  }
}
