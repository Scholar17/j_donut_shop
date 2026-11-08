import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/art_palette.dart';
import '../../../../core/widgets/donut_art.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/session_cubit.dart';
import '../widgets/welcome_tile.dart';

/// Screen 7: shown once after registration. Tiles slide in staggered, then
/// the title fades up; "Let's explore" lets the router guard open Home.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _tilesFlex = 3;
  static const _contentFlex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundTint,
      body: Column(
        children: [
          const Expanded(flex: _tilesFlex, child: _TileGrid()),
          Expanded(
            flex: _contentFlex,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: _WelcomeContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileGrid extends StatelessWidget {
  const _TileGrid();

  /// Right column starts lower, like the design's offset masonry.
  static const _rightColumnOffset = 0.18;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _column(
              const [
                (ArtPalette.circleLilac, DonutStyle.grape),
                (ArtPalette.circlePeach, DonutStyle.strawberry),
              ],
              startIndex: 0,
              fromLeft: true,
              topFraction: 0,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _column(
              const [
                (ArtPalette.circleBlush, DonutStyle.chocolate),
                (ArtPalette.circleButter, DonutStyle.vanilla),
              ],
              startIndex: 1,
              fromLeft: false,
              topFraction: _rightColumnOffset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(
    List<(Color, DonutStyle)> tiles, {
    required int startIndex,
    required bool fromLeft,
    required double topFraction,
  }) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: EdgeInsets.only(top: constraints.maxHeight * topFraction),
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: constraints.maxHeight,
        child: Column(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              Expanded(
                child: WelcomeTile(
                  index: startIndex + i * 2,
                  color: tiles[i].$1,
                  donut: tiles[i].$2,
                  fromLeft: fromLeft,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    ),
  );
}

class _WelcomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StaggeredEntrance(
          index: 0,
          baseDelay: AppDurations.welcomeTitleDelay,
          child: Text(
            l10n.welcomeTitle,
            style: context.text.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        StaggeredEntrance(
          index: 1,
          baseDelay: AppDurations.welcomeTitleDelay,
          child: PrimaryButton(
            key: const Key('welcome.explore'),
            label: l10n.letsExplore,
            onPressed: () => context.read<SessionCubit>().welcomeCompleted(),
          ),
        ),
      ],
    );
  }
}
