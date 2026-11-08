import '../../../../core/data/json_reader.dart';
import '../../../../objectbox.g.dart';
import '../models/member_entities.dart';

/// ObjectBox access for the member, tier ladder and challenges.
class MemberLocalDataSource {
  MemberLocalDataSource(this._store);

  final Store _store;

  Box<MemberEntity> get _members => _store.box<MemberEntity>();
  Box<TierEntity> get _tiers => _store.box<TierEntity>();
  Box<ChallengeEntity> get _challenges => _store.box<ChallengeEntity>();

  Stream<MemberEntity?> watchMember() => _members
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.findFirst());

  Stream<List<TierEntity>> watchTiers() =>
      (_tiers.query()..order(TierEntity_.minPoints))
          .watch(triggerImmediately: true)
          .map((query) => query.find());

  Stream<List<ChallengeEntity>> watchChallenges() =>
      (_challenges.query()..order(ChallengeEntity_.sortOrder))
          .watch(triggerImmediately: true)
          .map((query) => query.find());

  Future<void> updateName(String name) async {
    final member = _members.getAll().firstOrNull;
    if (member == null || member.name == name) return;
    await _members.putAsync(member..name = name);
  }

  /// Seeds member data in one transaction from the seed JSON.
  void importSeed(Map<String, dynamic> json) {
    final member = MemberEntity.fromJson(
      json.read<Map<String, dynamic>>('member'),
    );
    final tiers = json.readList('tiers').map(TierEntity.fromJson).toList();
    final challenges = json.readList('challenges');
    _store.runInTransaction(TxMode.write, () {
      _members.put(member);
      _tiers
        ..removeAll()
        ..putMany(tiers);
      _challenges
        ..removeAll()
        ..putMany([
          for (var i = 0; i < challenges.length; i++)
            ChallengeEntity.fromJson(challenges[i], i),
        ]);
    });
  }
}
