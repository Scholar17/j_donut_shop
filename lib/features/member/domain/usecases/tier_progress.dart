import '../entities/tier.dart';

/// Computes the member's tier, the next tier and progress between them.
///
/// [ladder] may come unsorted from data; it must contain at least one tier.
TierProgress tierProgress(int points, List<Tier> ladder) {
  assert(ladder.isNotEmpty, 'Tier ladder must not be empty');
  final sorted = [...ladder]
    ..sort((a, b) => a.minPoints.compareTo(b.minPoints));
  final currentIndex = sorted.lastIndexWhere(
    (tier) => points >= tier.minPoints,
  );
  final current = sorted[currentIndex < 0 ? 0 : currentIndex];
  final nextIndex = (currentIndex < 0 ? 0 : currentIndex) + 1;
  final next = nextIndex < sorted.length ? sorted[nextIndex] : null;
  if (next == null) {
    return TierProgress(
      current: current,
      next: null,
      pointsToNext: 0,
      fractionToNext: 1,
    );
  }
  final span = next.minPoints - current.minPoints;
  final earned = (points - current.minPoints).clamp(0, span);
  return TierProgress(
    current: current,
    next: next,
    pointsToNext: next.minPoints - points.clamp(0, next.minPoints),
    fractionToNext: span == 0 ? 1 : earned / span,
  );
}
