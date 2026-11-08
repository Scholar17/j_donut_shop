import 'package:equatable/equatable.dart';

/// The single loyalty-member record that Home and Rewards both read.
class Member extends Equatable {
  const Member({
    required this.id,
    required this.name,
    required this.points,
    this.photoUrl,
    this.photoAsset,
    this.notificationCount = 0,
    this.rewardsCount = 0,
  });

  final String id;
  final String name;
  final int points;
  final String? photoUrl;
  final String? photoAsset;
  final int notificationCount;

  /// Unclaimed rewards (the "Rewards 3" badge).
  final int rewardsCount;

  @override
  List<Object?> get props => [
    id,
    name,
    points,
    photoUrl,
    photoAsset,
    notificationCount,
    rewardsCount,
  ];
}
