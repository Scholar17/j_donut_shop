import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../motion/app_motion.dart';

/// Horizontal shared-axis transition between registration steps: the new
/// step slides in from the right while fading; the old one drifts left.
CustomTransitionPage<void> sharedAxisPage({
  required LocalKey key,
  required Widget child,
}) => CustomTransitionPage<void>(
  key: key,
  child: child,
  transitionDuration: AppDurations.pageTransition,
  reverseTransitionDuration: AppDurations.pageTransition,
  transitionsBuilder: (context, animation, secondary, child) {
    if (context.reduceMotion) return child;
    return _SharedAxis(primary: animation, secondary: secondary, child: child);
  },
);

/// Fade-through for unrelated screens (Onboarding → Welcome → Home).
CustomTransitionPage<void> fadeThroughPage({
  required LocalKey key,
  required Widget child,
}) => CustomTransitionPage<void>(
  key: key,
  child: child,
  transitionDuration: AppDurations.slow,
  transitionsBuilder: (context, animation, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: AppCurves.standard),
    child: ScaleTransition(
      scale: Tween<double>(
        begin: AppMotionValues.fadeThroughStartScale,
        end: 1,
      ).animate(CurvedAnimation(parent: animation, curve: AppCurves.standard)),
      child: child,
    ),
  ),
);

class _SharedAxis extends StatelessWidget {
  const _SharedAxis({
    required this.primary,
    required this.secondary,
    required this.child,
  });

  final Animation<double> primary;
  final Animation<double> secondary;
  final Widget child;

  static const _travel = 0.25;

  @override
  Widget build(BuildContext context) {
    final enter = CurvedAnimation(parent: primary, curve: AppCurves.emphasized);
    final exit = CurvedAnimation(
      parent: secondary,
      curve: AppCurves.emphasized,
    );
    return SlideTransition(
      position: Tween(
        begin: const Offset(_travel, 0),
        end: Offset.zero,
      ).animate(enter),
      child: FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(-_travel, 0),
          ).animate(exit),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(exit),
            child: child,
          ),
        ),
      ),
    );
  }
}
