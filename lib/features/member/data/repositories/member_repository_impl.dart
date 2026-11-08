import '../../domain/entities/challenge.dart';
import '../../domain/entities/gift.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/tier.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/member_local_data_source.dart';

class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl(this._local);

  final MemberLocalDataSource _local;

  @override
  Stream<Member?> watchMember() =>
      _local.watchMember().map((row) => row?.toDomain());

  @override
  Stream<List<Tier>> watchTiers() =>
      _local.watchTiers().map((rows) => [for (final r in rows) r.toDomain()]);

  @override
  Stream<List<Challenge>> watchChallenges() => _local.watchChallenges().map(
    (rows) => [for (final r in rows) r.toDomain()],
  );

  @override
  Stream<List<Gift>> watchGifts() =>
      _local.watchGifts().map((rows) => [for (final r in rows) r.toDomain()]);

  @override
  Future<void> updateName(String name) => _local.updateName(name);
}
