import 'package:equatable/equatable.dart';

/// Which progress artwork a challenge card draws.
enum ChallengeArt { donut, coffee }

/// "Eat 4 Coco donuts", "Drink 12 cups americano".
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.rewardPoints,
    required this.art,
  });

  final String id;
  final String title;
  final int progress;
  final int target;
  final int rewardPoints;
  final ChallengeArt art;

  bool get isComplete => progress >= target;
  double get fraction => target == 0 ? 0 : (progress / target).clamp(0, 1);

  @override
  List<Object?> get props => [id, title, progress, target, rewardPoints, art];
}
