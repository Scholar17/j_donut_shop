import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/widgets/section_message.dart';
import '../../../member/domain/entities/member.dart';
import '../../../shell/presentation/active_tab.dart';
import '../bloc/rewards_cubit.dart';
import '../widgets/points_ring.dart';
import '../widgets/rewards_badge.dart';
import '../widgets/rewards_list.dart';
import '../widgets/rewards_tabs.dart';
import '../widgets/tier_ladder.dart';

/// Screen 10. One master timeline ([_entrance]) drives the badge pop, tier
/// ladder and points ring; it replays every time the tab becomes visible.
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  late final _entrance = AnimationController(
    vsync: this,
    duration: AppDurations.rewardsEntrance,
  );
  MainTab? _lastTab;

  /// Bumped on each replay so the cards re-run their staggered entrance.
  int _replay = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tab = ActiveTab.of(context) ?? MainTab.rewards;
    final becameVisible = tab == MainTab.rewards && _lastTab != MainTab.rewards;
    _lastTab = tab;
    if (!becameVisible) return;
    if (context.reduceMotion) {
      _entrance.value = 1;
    } else {
      _entrance.forward(from: 0);
      _replay++;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      // White behind the header half, grey behind the panel half, so an
      // overscroll bounce past either end shows the colour that is there.
      backgroundColor: colors.surface,
      body: BlocBuilder<RewardsCubit, RewardsState>(
        builder: (context, state) => Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                key: const Key('rewards.background'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 0.5],
                    colors: [colors.surface, colors.surfaceMuted],
                  ),
                ),
              ),
            ),
            ListView(
              // No bottom padding: the grey panel pads itself for the nav bar
              // (Scaffold.extendBody) so its grey reaches the screen bottom.
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + AppSpacing.md,
              ),
              children: [
                _Header(state: state, entrance: _entrance),
                const SizedBox(height: AppSpacing.lg),
                _Summary(state: state, entrance: _entrance),
                const SizedBox(height: AppSpacing.xl),
                _Lists(
                  state: state,
                  replay: _replay,
                  bottomInset: MediaQuery.paddingOf(context).bottom,
                ),
              ],
            ),
            const SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: OfflineBanner(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.entrance});

  final RewardsState state;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final count = switch (state.member) {
      Loaded<Member?>(value: final m?) => m.rewardsCount,
      _ => 0,
    };
    return Row(
      children: [
        const SizedBox(width: AppSpacing.pageGutter),
        Expanded(
          child: Text(
            AppLocalizations.of(context).rewardsTitle,
            style: context.text.headlineMedium,
          ),
        ),
        RewardsBadge(count: count, entrance: entrance),
      ],
    );
  }
}

/// Tier ladder (left) and the points ring bleeding off the right edge.
class _Summary extends StatelessWidget {
  const _Summary({required this.state, required this.entrance});

  final RewardsState state;
  final Animation<double> entrance;

  static const _ringWidthFactor = 0.56;
  static const _ringBleed = 0.16;
  static const _ladderFlex = 5;
  static const _skeletonHeight = 240.0;

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    if (state.member is Failed<Member?>) {
      return SectionMessage.error(onRetry: () {}, height: _skeletonHeight);
    }
    if (progress == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
        child: Skeleton(height: _skeletonHeight, radius: AppRadius.lg),
      );
    }
    final ringSize = MediaQuery.sizeOf(context).width * _ringWidthFactor;
    final sweep = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.1, 0.85, curve: AppCurves.sweep),
    );
    return ClipRect(
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.pageGutter),
          Expanded(
            flex: _ladderFlex,
            child: TierLadder(
              tiers: state.tiers,
              progress: progress,
              entrance: entrance,
            ),
          ),
          Transform.translate(
            offset: Offset(ringSize * _ringBleed, 0),
            child: PointsRing(
              size: ringSize,
              progress: state.ladderFraction,
              points: state.points,
              sweep: sweep,
            ),
          ),
        ],
      ),
    );
  }
}

class _Lists extends StatelessWidget {
  const _Lists({
    required this.state,
    required this.replay,
    required this.bottomInset,
  });

  final RewardsState state;
  final int replay;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: RewardsTabs(
            selected: state.tab,
            onSelected: context.read<RewardsCubit>().selectTab,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        RewardsList(state: state, replay: replay, bottomInset: bottomInset),
      ],
    );
  }
}
