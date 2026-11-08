import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "ADD TO CART | 3,200 MMK" with a live total that pops when it changes.
class AddToCartButton extends StatefulWidget {
  const AddToCartButton({
    required this.total,
    required this.onPressed,
    required this.addedCount,
    super.key,
  });

  final int total;
  final VoidCallback onPressed;

  /// Plays a pulse each time this increases.
  final int addedCount;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );

  static const _pulseScale = 0.06;
  static const _dividerHeight = 18.0;

  @override
  void didUpdateWidget(AddToCartButton old) {
    super.didUpdateWidget(old);
    if (widget.addedCount > old.addedCount && !context.reduceMotion) {
      _pulse.forward(from: 0);
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final style = context.text.labelLarge?.copyWith(color: colors.onPrimary);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(
        scale:
            1 +
            _pulseScale *
                Curves.easeOut.transform(1 - (2 * _pulse.value - 1).abs()),
        child: child,
      ),
      child: PressableScale(
        key: const Key('product.addToCart'),
        onTap: widget.onPressed,
        child: Container(
          height: AppSizes.buttonHeight,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.addToCart.toUpperCase(), style: style),
              Container(
                width: 1,
                height: _dividerHeight,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                color: colors.onPrimary,
              ),
              AnimatedSwitcher(
                duration: context.motion(AppDurations.fast),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: Text(
                  l10n.priceMmk(formatThousands(widget.total)).toUpperCase(),
                  key: ValueKey(widget.total),
                  style: style,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
