import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/member/domain/entities/tier.dart';
import 'package:j_donut_shop/features/rewards/presentation/widgets/tier_ladder.dart';
import 'package:j_donut_shop/features/rewards/presentation/widgets/tier_shield.dart';

import '../../helpers/pump_app.dart';

const _silver = Tier(level: TierLevel.silver, minPoints: 0);
const _gold = Tier(level: TierLevel.gold, minPoints: 1000);
const _platinum = Tier(level: TierLevel.platinum, minPoints: 5000);

Future<void> _pumpLadder(WidgetTester tester) => tester.pumpPage(
  const Scaffold(
    body: SingleChildScrollView(
      child: TierLadder(
        tiers: [_silver, _gold, _platinum],
        progress: TierProgress(
          current: _silver,
          next: _gold,
          pointsToNext: 500,
          fractionToNext: 0.5,
        ),
        entrance: AlwaysStoppedAnimation(1),
      ),
    ),
  ),
);

void main() {
  testWidgets('each connector runs from one shield to the next', (
    tester,
  ) async {
    await _pumpLadder(tester);

    final shields = find.byType(TierShield);
    expect(shields, findsNWidgets(3));
    for (final (i, level) in [TierLevel.silver, TierLevel.gold].indexed) {
      final line = tester.getRect(
        find.byKey(Key('tierLadder.connector.${level.name}')),
      );
      final above = tester.getRect(shields.at(i));
      final below = tester.getRect(shields.at(i + 1));
      expect(line.top, moreOrLessEquals(above.bottom, epsilon: 0.5));
      expect(line.bottom, moreOrLessEquals(below.top, epsilon: 0.5));
    }
    // Every connector is the same length, even under Gold's two-line
    // subtitle.
    final lengths = [TierLevel.silver, TierLevel.gold].map(
      (l) => tester
          .getSize(find.byKey(Key('tierLadder.connector.${l.name}')))
          .height,
    );
    expect(lengths.first, moreOrLessEquals(lengths.last, epsilon: 0.5));
    // The last tier has no connector.
    expect(
      find.byKey(const Key('tierLadder.connector.platinum')),
      findsNothing,
    );
  });

  testWidgets('shields show their rank as stars and the subtitles', (
    tester,
  ) async {
    await _pumpLadder(tester);

    final stars = tester
        .widgetList<TierShield>(find.byType(TierShield))
        .map((s) => s.stars);
    expect(stars, [1, 2, 3]);
    expect(find.text("You're here now"), findsOneWidget);
    expect(find.text('500 pts Remaining\nto become Gold'), findsOneWidget);
    expect(find.text("You'll be here soon"), findsOneWidget);
  });
}
