import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/rewards_cubit.dart';

/// "Eat more earn more | Gift" with an indicator that slides between them.
class RewardsTabs extends StatelessWidget {
  const RewardsTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final RewardsTab selected;
  final ValueChanged<RewardsTab> onSelected;

  static const _height = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isEarn = selected == RewardsTab.earn;
    return Container(
      height: _height,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isEarn ? Alignment.centerLeft : Alignment.centerRight,
            duration: context.motion(AppDurations.tabSwitch),
            curve: AppCurves.emphasized,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _label(context, l10n.eatMoreEarnMore, RewardsTab.earn),
              _label(context, l10n.gift, RewardsTab.gift),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text, RewardsTab tab) {
    final active = tab == selected;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: PressableScale(
          key: Key('rewards.tab.${tab.name}'),
          onTap: () => onSelected(tab),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: context.motion(AppDurations.tabSwitch),
              style: context.text.titleSmall!.copyWith(
                color: active
                    ? context.colors.onPrimary
                    : context.colors.textSecondary,
              ),
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
