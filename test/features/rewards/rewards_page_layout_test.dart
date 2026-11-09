import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/connectivity/connectivity_cubit.dart';
import 'package:j_donut_shop/core/result/load_state.dart';
import 'package:j_donut_shop/core/theme/app_theme.dart';
import 'package:j_donut_shop/features/member/domain/entities/member.dart';
import 'package:j_donut_shop/features/member/domain/entities/tier.dart';
import 'package:j_donut_shop/features/rewards/presentation/bloc/rewards_cubit.dart';
import 'package:j_donut_shop/features/rewards/presentation/pages/rewards_page.dart';
import 'package:j_donut_shop/features/rewards/presentation/widgets/rewards_list.dart';
import 'package:j_donut_shop/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockRewardsCubit extends MockCubit<RewardsState>
    implements RewardsCubit {}

class _MockConnectivityCubit extends MockCubit<bool>
    implements ConnectivityCubit {}

/// Height of the stand-in nav bar; the body extends behind it like the
/// real shell (Scaffold.extendBody), so the page sees it as bottom padding.
const _navHeight = 100.0;

const _loaded = RewardsState(
  member: Loaded(Member(id: 'm_1', name: 'Hania', points: 680000)),
  tiers: [
    Tier(level: TierLevel.silver, minPoints: 679500),
    Tier(level: TierLevel.gold, minPoints: 680500),
    Tier(level: TierLevel.platinum, minPoints: 1500000),
  ],
);

Future<void> _pumpRewards(
  WidgetTester tester, {
  RewardsState state = const RewardsState(),
  double textScale = 1,
}) async {
  final cubit = _MockRewardsCubit();
  when(() => cubit.state).thenReturn(state);
  final connectivity = _MockConnectivityCubit();
  when(() => connectivity.state).thenReturn(true);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        extendBody: true,
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RewardsCubit>.value(value: cubit),
            BlocProvider<ConnectivityCubit>.value(value: connectivity),
          ],
          child: const RewardsPage(),
        ),
        bottomNavigationBar: const SizedBox(height: _navHeight),
      ),
    ),
  );
  // Let the entrance timeline run; skeletons shimmer forever, so no settle.
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('scrolled to the end, the grey panel reaches the screen bottom', (
    tester,
  ) async {
    await _pumpRewards(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pump(const Duration(seconds: 1));

    final screen = tester.getSize(find.byType(MaterialApp));
    final panel = tester.getRect(find.byType(RewardsList));
    // No white strip between the panel and the nav bar: the panel itself
    // runs on behind the nav bar to the very bottom.
    expect(panel.bottom, moreOrLessEquals(screen.height, epsilon: 0.5));
    expect(panel.bottom - _navHeight, greaterThan(panel.top));
  });

  testWidgets('page background is white on top and grey at the bottom', (
    tester,
  ) async {
    await _pumpRewards(tester);

    final box = tester.widget<DecoratedBox>(
      find.byKey(const Key('rewards.background')),
    );
    final gradient =
        (box.decoration as BoxDecoration).gradient! as LinearGradient;
    final colors = tester.element(find.byType(RewardsPage)).colors;

    expect(gradient.colors, [colors.surface, colors.surfaceMuted]);
    expect(gradient.stops, [0.5, 0.5]);
  });

  testWidgets('summary lays out on a small phone at 1.3x text', (tester) async {
    // 4.7" phone (iPhone SE 2/3: 375 x 667 logical).
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pumpRewards(tester, state: _loaded, textScale: 1.3);

    // The tier ladder grows its rungs instead of overflowing.
    expect(tester.takeException(), isNull);
  });
}
