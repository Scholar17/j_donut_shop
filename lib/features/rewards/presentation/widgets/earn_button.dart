import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Earn: active with a breathing glow when the challenge is complete, grey
/// otherwise. Press feedback only (no action, per the spec).
class EarnButton extends StatefulWidget {
  const EarnButton({required this.active, super.key});

  final bool active;

  @override
  State<EarnButton> createState() => _EarnButtonState();
}

class _EarnButtonState extends State<EarnButton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.earnPulse,
  );

  static const _width = 92.0;
  static const _height = 44.0;
  static const _glowBlur = 16.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(EarnButton old) {
    super.didUpdateWidget(old);
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.active && !context.reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final curved = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
    return Semantics(
      button: true,
      enabled: widget.active,
      label: AppLocalizations.of(context).earn,
      child: PressableScale(
        onTap: HapticFeedback.selectionClick,
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, child) => Transform.scale(
            scale: widget.active
                ? 1 + (AppMotionValues.earnPulseScale - 1) * curved.value
                : 1,
            child: Container(
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                color: widget.active ? colors.primary : colors.disabled,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  if (widget.active)
                    BoxShadow(
                      color: colors.primary.withValues(
                        alpha: 0.5 * curved.value,
                      ),
                      blurRadius: _glowBlur,
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
          child: Text(
            AppLocalizations.of(context).earn.toUpperCase(),
            style: context.text.labelLarge?.copyWith(color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}
