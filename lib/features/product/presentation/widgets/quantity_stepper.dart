import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// − 1 + pill. The number rolls up on increase and down on decrease.
class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.canDecrement,
    super.key,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canDecrement;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late int _previous = widget.quantity;
  bool _increasing = true;

  static const _numberWidth = 44.0;

  @override
  void didUpdateWidget(QuantityStepper old) {
    super.didUpdateWidget(old);
    if (old.quantity != widget.quantity) {
      _increasing = widget.quantity > _previous;
      _previous = widget.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(color: context.colors.border, blurRadius: AppSpacing.md),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            key: const Key('qty.minus'),
            icon: Icons.remove_rounded,
            label: l10n.decreaseQuantity,
            onTap: widget.canDecrement ? widget.onDecrement : null,
          ),
          SizedBox(width: _numberWidth, child: _number(context)),
          _RoundButton(
            key: const Key('qty.plus'),
            icon: Icons.add_rounded,
            label: l10n.increaseQuantity,
            onTap: widget.onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _number(BuildContext context) => ClipRect(
    child: AnimatedSwitcher(
      duration: context.motion(AppDurations.fast),
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(widget.quantity);
        final dy = (_increasing == incoming) ? 1.0 : -1.0;
        return SlideTransition(
          position: Tween(
            begin: Offset(0, dy),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        '${widget.quantity}',
        key: ValueKey(widget.quantity),
        textAlign: TextAlign.center,
        style: context.text.headlineSmall,
      ),
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    child: PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: context.motion(AppDurations.fast),
        width: AppSizes.iconButton,
        height: AppSizes.iconButton,
        decoration: BoxDecoration(
          color: onTap == null
              ? context.colors.disabled
              : context.colors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: context.colors.onPrimary),
      ),
    ),
  );
}
