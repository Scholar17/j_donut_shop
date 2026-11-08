import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../member/domain/entities/gift.dart';

/// Gift tab item: visual feedback only.
class GiftCard extends StatelessWidget {
  const GiftCard({
    required this.gift,
    required this.memberPoints,
    required this.index,
    super.key,
  });

  final Gift gift;
  final int memberPoints;
  final int index;

  static const _iconRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final affordable = gift.isAffordable(memberPoints);
    return StaggeredEntrance(
      index: index,
      child: PressableScale(
        onTap: HapticFeedback.selectionClick,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: _iconRadius,
                backgroundColor: affordable ? colors.accent : colors.disabled,
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gift.title, style: context.text.titleMedium),
                    Text(
                      AppLocalizations.of(context)
                          .pointsShort(formatThousands(gift.costPoints)),
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: affordable ? colors.accent : colors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
