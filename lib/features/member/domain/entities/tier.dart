import 'package:equatable/equatable.dart';

enum TierLevel { bronze, silver, gold, platinum }

/// A rung on the loyalty ladder, unlocked at [minPoints].
class Tier extends Equatable {
  const Tier({required this.level, required this.minPoints});

  final TierLevel level;
  final int minPoints;

  @override
  List<Object?> get props => [level, minPoints];
}

/// Where a member stands on the ladder.
class TierProgress extends Equatable {
  const TierProgress({
    required this.current,
    required this.next,
    required this.pointsToNext,
    required this.fractionToNext,
  });

  final Tier current;

  /// `null` at the top tier.
  final Tier? next;
  final int pointsToNext;

  /// 0–1 progress from [current] to [next]; 1 at the top tier.
  final double fractionToNext;

  bool get isTopTier => next == null;

  @override
  List<Object?> get props => [current, next, pointsToNext, fractionToNext];
}
