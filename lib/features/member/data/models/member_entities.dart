import 'package:objectbox/objectbox.dart';

import '../../../../core/data/json_reader.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/tier.dart';

@Entity()
class MemberEntity {
  MemberEntity({
    required this.memberId,
    required this.name,
    required this.points,
    this.photoUrl,
    this.photoAsset,
    this.notificationCount = 0,
    this.rewardsCount = 0,
    this.id = 0,
  });

  factory MemberEntity.fromJson(Map<String, dynamic> json) => MemberEntity(
    memberId: json.read<String>('id'),
    name: json.read<String>('name'),
    points: json.read<int>('points'),
    photoUrl: json.readOrNull<String>('photoUrl'),
    photoAsset: json.readOrNull<String>('photoAsset'),
    notificationCount: json.readOrNull<int>('notificationCount') ?? 0,
    rewardsCount: json.readOrNull<int>('rewardsCount') ?? 0,
  );

  @Id()
  int id;
  @Unique(onConflict: ConflictStrategy.replace)
  String memberId;
  String name;
  int points;
  String? photoUrl;
  String? photoAsset;
  int notificationCount;
  int rewardsCount;

  Member toDomain() => Member(
    id: memberId,
    name: name,
    points: points,
    photoUrl: photoUrl,
    photoAsset: photoAsset,
    notificationCount: notificationCount,
    rewardsCount: rewardsCount,
  );
}

@Entity()
class TierEntity {
  TierEntity({required this.level, required this.minPoints, this.id = 0});

  factory TierEntity.fromJson(Map<String, dynamic> json) {
    final level = json.read<String>('level');
    if (!TierLevel.values.any((tier) => tier.name == level)) {
      throw FormatException('Unknown tier level "$level"');
    }
    return TierEntity(level: level, minPoints: json.read<int>('minPoints'));
  }

  @Id()
  int id;
  @Unique(onConflict: ConflictStrategy.replace)
  String level;
  int minPoints;

  Tier toDomain() =>
      Tier(level: TierLevel.values.byName(level), minPoints: minPoints);
}

@Entity()
class ChallengeEntity {
  ChallengeEntity({
    required this.challengeId,
    required this.title,
    required this.progress,
    required this.target,
    required this.rewardPoints,
    required this.art,
    required this.sortOrder,
    this.id = 0,
  });

  factory ChallengeEntity.fromJson(Map<String, dynamic> json, int order) {
    final art = json.read<String>('art');
    if (!ChallengeArt.values.any((value) => value.name == art)) {
      throw FormatException('Unknown challenge art "$art"');
    }
    return ChallengeEntity(
      challengeId: json.read<String>('id'),
      title: json.read<String>('title'),
      progress: json.read<int>('progress'),
      target: json.read<int>('target'),
      rewardPoints: json.read<int>('rewardPoints'),
      art: art,
      sortOrder: order,
    );
  }

  @Id()
  int id;
  @Unique(onConflict: ConflictStrategy.replace)
  String challengeId;
  String title;
  int progress;
  int target;
  int rewardPoints;
  String art;
  int sortOrder;

  Challenge toDomain() => Challenge(
    id: challengeId,
    title: title,
    progress: progress,
    target: target,
    rewardPoints: rewardPoints,
    art: ChallengeArt.values.byName(art),
  );
}
