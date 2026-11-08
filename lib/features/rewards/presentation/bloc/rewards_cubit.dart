import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/load_state.dart';
import '../../../member/domain/entities/challenge.dart';
import '../../../member/domain/entities/gift.dart';
import '../../../member/domain/entities/member.dart';
import '../../../member/domain/entities/tier.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../../member/domain/usecases/tier_progress.dart';

enum RewardsTab { earn, gift }

class RewardsState extends Equatable {
  const RewardsState({
    this.member = const Loading(),
    this.tiers = const [],
    this.challenges = const Loading(),
    this.gifts = const Loading(),
    this.tab = RewardsTab.earn,
  });

  final LoadState<Member?> member;
  final List<Tier> tiers;
  final LoadState<List<Challenge>> challenges;
  final LoadState<List<Gift>> gifts;
  final RewardsTab tab;

  /// Same member record and tier ladder as Home: both screens always agree.
  TierProgress? get progress => switch (member) {
    Loaded(value: final m?) when tiers.isNotEmpty => tierProgress(
      m.points,
      tiers,
    ),
    _ => null,
  };

  /// Points ring fill: progress along the whole ladder.
  double get ladderFraction => ladderProgress(points, tiers);

  int get points => switch (member) {
    Loaded(value: final m?) => m.points,
    _ => 0,
  };

  RewardsState copyWith({
    LoadState<Member?>? member,
    List<Tier>? tiers,
    LoadState<List<Challenge>>? challenges,
    LoadState<List<Gift>>? gifts,
    RewardsTab? tab,
  }) => RewardsState(
    member: member ?? this.member,
    tiers: tiers ?? this.tiers,
    challenges: challenges ?? this.challenges,
    gifts: gifts ?? this.gifts,
    tab: tab ?? this.tab,
  );

  @override
  List<Object?> get props => [member, tiers, challenges, gifts, tab];
}

/// Rewards reads points and challenges from the same local data as Home.
/// A Cubit: no buttons have logic (spec), only a tab switch.
class RewardsCubit extends Cubit<RewardsState> {
  RewardsCubit(MemberRepository repository) : super(const RewardsState()) {
    _subscriptions = [
      _listen<Member?>(
        repository.watchMember(),
        (s, v) => s.copyWith(member: v),
      ),
      _listen<List<Challenge>>(
        repository.watchChallenges(),
        (s, v) => s.copyWith(challenges: v),
      ),
      _listen<List<Gift>>(
        repository.watchGifts(),
        (s, v) => s.copyWith(gifts: v),
      ),
      repository.watchTiers().listen(
        (tiers) => emit(state.copyWith(tiers: tiers)),
      ),
    ];
  }

  late final List<StreamSubscription<Object?>> _subscriptions;

  void selectTab(RewardsTab tab) => emit(state.copyWith(tab: tab));

  StreamSubscription<T> _listen<T>(
    Stream<T> stream,
    RewardsState Function(RewardsState, LoadState<T>) update,
  ) => stream.listen(
    (value) => emit(update(state, Loaded(value))),
    onError: (Object error) =>
        emit(update(state, Failed(CacheFailure('$error')))),
  );

  @override
  Future<void> close() async {
    await Future.wait(_subscriptions.map((s) => s.cancel()));
    return super.close();
  }
}
