import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../motion/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Shimmering placeholder block. Loading states use skeletons, not spinners.
class Skeleton extends StatelessWidget {
  const Skeleton({
    this.width,
    this.height,
    this.radius = AppRadius.md,
    super.key,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final block = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (context.reduceMotion) return block;
    return Shimmer.fromColors(
      baseColor: colors.skeletonBase,
      highlightColor: colors.skeletonHighlight,
      period: AppDurations.shimmerCycle,
      child: block,
    );
  }
}
