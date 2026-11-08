import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class JdNavItem {
  const JdNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Cyan bar with a pink pill that slides to the active tab.
///
/// The active slot is wider (icon + label). Slot widths and the pill's
/// position animate with the same duration and curve, so the pill always
/// lands exactly on its slot.
class JdBottomNav extends StatelessWidget {
  const JdBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<JdNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _activeShare = 0.32;
  static const _pillHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.motion(AppDurations.navPillSlide);
    return Container(
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
        AppSpacing.sm + MediaQuery.paddingOf(context).bottom,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final active = constraints.maxWidth * _activeShare;
          final other = (constraints.maxWidth - active) / (items.length - 1);
          return SizedBox(
            height: _pillHeight,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: duration,
                  curve: AppCurves.emphasized,
                  left: currentIndex * other,
                  width: active,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: colors.onPrimary, width: 1.5),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _slot(
                        context,
                        i,
                        i == currentIndex ? active : other,
                        duration,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _slot(
    BuildContext context,
    int index,
    double width,
    Duration duration,
  ) {
    final item = items[index];
    final isActive = index == currentIndex;
    final onPrimary = context.colors.onPrimary;
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
          curve: AppCurves.emphasized,
          width: width,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: onPrimary),
              Flexible(
                child: AnimatedSize(
                  duration: duration,
                  curve: AppCurves.emphasized,
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xxs),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: context.text.labelLarge?.copyWith(
                              color: onPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
