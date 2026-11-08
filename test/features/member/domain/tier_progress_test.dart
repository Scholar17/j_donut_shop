import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/member/domain/entities/tier.dart';
import 'package:j_donut_shop/features/member/domain/usecases/tier_progress.dart';

void main() {
  const silver = Tier(level: TierLevel.silver, minPoints: 0);
  const gold = Tier(level: TierLevel.gold, minPoints: 680500);
  const platinum = Tier(level: TierLevel.platinum, minPoints: 1500000);
  const ladder = [platinum, silver, gold]; // unsorted on purpose

  test('680,000 points is Silver with 500 points to Gold', () {
    final progress = tierProgress(680000, ladder);

    expect(progress.current, silver);
    expect(progress.next, gold);
    expect(progress.pointsToNext, 500);
  });

  test('progress fraction is measured between the current and next tier', () {
    final progress = tierProgress(340250, ladder);
    expect(progress.fractionToNext, closeTo(0.5, 0.0001));
  });

  test('reaching the threshold exactly promotes to that tier', () {
    expect(tierProgress(680500, ladder).current, gold);
  });

  test('the top tier has no next tier and full progress', () {
    final progress = tierProgress(2000000, ladder);

    expect(progress.isTopTier, isTrue);
    expect(progress.pointsToNext, 0);
    expect(progress.fractionToNext, 1);
  });

  test('negative points fall back to the lowest tier', () {
    expect(tierProgress(-10, ladder).current, silver);
  });

  group('ladderProgress', () {
    test('is points relative to the top tier', () {
      expect(ladderProgress(750000, ladder), closeTo(0.5, 0.0001));
    });

    test('caps at 1 beyond the top tier', () {
      expect(ladderProgress(3000000, ladder), 1);
    });

    test('is 0 for an empty ladder', () {
      expect(ladderProgress(10, const []), 0);
    });
  });
}
