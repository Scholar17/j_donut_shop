import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class JdNavItem {
  const JdNavItem({this.icon, this.iconBuilder, required this.label})
    : assert(icon != null || iconBuilder != null);

  final IconData? icon;

  /// Custom-drawn icon, used instead of [icon]; receives the tint colour.
  final Widget Function(Color color)? iconBuilder;
  final String label;
}

/// Cyan bar whose active tab is a pink pill with icon and label. The bar is
/// inset from the screen edges, on a band beside its upper half (colour per
/// tab, see [upperBandColor]) and a full-width pink strip under its lower
/// half.
///
/// On a tap the pill moves to the new tab at once (no slide), starting at
/// that tab's narrow width, then grows with it while the label is revealed
/// (clipped with "…" until it fits). The other tabs reflow in the same
/// motion, because every slot animates its width with one duration and curve.
class JdBottomNav extends StatelessWidget {
  const JdBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.upperBandColor,
    super.key,
  });

  final List<JdNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Colour beside the bar's upper half; defaults to the surface (white).
  final Color? upperBandColor;

  static const _activeShare = 0.32;
  static const _pillHeight = 48.0;
  static const _pillBorderWidth = 1.5;

  /// Gap between the screen edges and the cyan bar.
  static const _sideInset = AppSpacing.sm;

  /// Bar height above the system inset: padding + pill + padding.
  static const _barHeight = AppSpacing.sm * 2 + _pillHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.motion(AppDurations.navPillGrow);
    final systemInset = MediaQuery.paddingOf(context).bottom;
    // Behind the inset bar: a band beside its upper half, a pink strip under
    // its lower half (plus the gesture area).
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: _barHeight / 2,
          child: ColoredBox(
            key: const Key('nav.topStrip'),
            color: upperBandColor ?? colors.surface,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _barHeight / 2 + systemInset,
          child: ColoredBox(
            key: const Key('nav.baseStrip'),
            color: colors.accent,
          ),
        ),
        Container(
          key: const Key('nav.bar'),
          margin: const EdgeInsets.symmetric(horizontal: _sideInset),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm + systemInset,
          ),
          child: _items(duration),
        ),
      ],
    );
  }

  Widget _items(Duration duration) => LayoutBuilder(
    builder: (context, constraints) {
      final active = constraints.maxWidth * _activeShare;
      final other = (constraints.maxWidth - active) / (items.length - 1);
      return SizedBox(
        height: _pillHeight,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _slot(context, i, i == currentIndex ? active : other, duration),
          ],
        ),
      );
    },
  );

  Widget _slot(
    BuildContext context,
    int index,
    double width,
    Duration duration,
  ) {
    final item = items[index];
    final isActive = index == currentIndex;
    return Semantics(
      button: true,
      selected: isActive,
      label: item.label,
      child: GestureDetector(
        key: Key('nav.$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelected(index),
        child: AnimatedContainer(
          duration: duration,
          curve: AppCurves.navPillGrow,
          width: width,
          height: _pillHeight,
          // Not animated on purpose: the pill appears on the new tab at once
          // and vanishes from the old one; only the width grows.
          child: DecoratedBox(
            decoration: isActive
                ? _pillDecoration(context.colors)
                : const BoxDecoration(),
            child: _SlotContent(item: item, isActive: isActive),
          ),
        ),
      ),
    );
  }

  static BoxDecoration _pillDecoration(AppColors colors) => BoxDecoration(
    color: colors.accent,
    borderRadius: BorderRadius.circular(AppRadius.pill),
    border: Border.all(color: colors.onPrimary, width: _pillBorderWidth),
  );
}

/// Icon, plus the label on the active tab.
class _SlotContent extends StatelessWidget {
  const _SlotContent({required this.item, required this.isActive});

  final JdNavItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final onPrimary = context.colors.onPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.iconBuilder?.call(onPrimary) ??
              Icon(item.icon, color: onPrimary),
          if (isActive)
            // Flexible + ellipsis: the growing slot reveals the label
            // ("R…", "Rewa…", "Reward") instead of popping it in.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xxs),
                child: ExcludeSemantics(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(
                      color: onPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
