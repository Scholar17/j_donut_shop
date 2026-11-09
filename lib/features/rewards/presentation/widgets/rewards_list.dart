import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/widgets/section_message.dart';
import '../bloc/rewards_cubit.dart';
import 'challenge_card.dart';
import 'gift_card.dart';

/// Grey panel holding the active tab's cards. Switching tabs cross-slides
/// the list in the direction of the indicator.
class RewardsList extends StatelessWidget {
  const RewardsList({
    required this.state,
    required this.replay,
    this.bottomInset = 0,
    super.key,
  });

  final RewardsState state;

  /// Changes on every Rewards entrance so the cards stagger in again.
  final int replay;

  /// Space for the nav bar under the cards. The panel pads itself (rather
  /// than the page's list), so its grey runs on behind the nav bar with no
  /// white gap.
  final double bottomInset;

  static const _slide = 0.15;
  static const _skeletonHeight = 140.0;
  static const _skeletonCount = 3;

  @override
  Widget build(BuildContext context) {
    final towardsGift = state.tab == RewardsTab.gift;
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.5 + bottomInset,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.lg,
        AppSpacing.pageGutter,
        AppSpacing.xxl + bottomInset,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.tabSwitch),
        switchInCurve: AppCurves.emphasized,
        switchOutCurve: AppCurves.exit,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey('${state.tab}-$replay');
          final dx = (incoming == towardsGift) ? _slide : -_slide;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: Offset(dx, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey('${state.tab}-$replay'),
          child: towardsGift ? _gifts(context) : _challenges(context),
        ),
      ),
    );
  }

  Widget _challenges(BuildContext context) => switch (state.challenges) {
    Loading() => _skeletons(),
    Failed() => SectionMessage.error(onRetry: () {}),
    Loaded(:final value) when value.isEmpty => _empty(
      context,
      AppLocalizations.of(context).noChallenges,
    ),
    Loaded(:final value) => _column([
      for (var i = 0; i < value.length; i++)
        ChallengeCard(challenge: value[i], index: i),
    ]),
  };

  Widget _gifts(BuildContext context) => switch (state.gifts) {
    Loading() => _skeletons(),
    Failed() => SectionMessage.error(onRetry: () {}),
    Loaded(:final value) when value.isEmpty => _empty(
      context,
      AppLocalizations.of(context).noGifts,
    ),
    Loaded(:final value) => _column([
      for (var i = 0; i < value.length; i++)
        GiftCard(gift: value[i], memberPoints: state.points, index: i),
    ]),
  };

  Widget _column(List<Widget> cards) => Column(
    children: [
      for (final card in cards) ...[
        card,
        const SizedBox(height: AppSpacing.md),
      ],
    ],
  );

  Widget _skeletons() => _column([
    for (var i = 0; i < _skeletonCount; i++)
      const Skeleton(height: _skeletonHeight, radius: AppRadius.lg),
  ]);

  Widget _empty(BuildContext context, String message) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Text(
      message,
      style: context.text.bodyLarge,
      textAlign: TextAlign.center,
    ),
  );
}
