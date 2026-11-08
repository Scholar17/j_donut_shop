import '../entities/challenge.dart';
import '../entities/gift.dart';
import '../entities/member.dart';
import '../entities/tier.dart';

/// Local-only member data (private; never fetched from the public API).
abstract interface class MemberRepository {
  Stream<Member?> watchMember();
  Stream<List<Tier>> watchTiers();
  Stream<List<Challenge>> watchChallenges();
  Stream<List<Gift>> watchGifts();

  /// Keeps the member's display name in sync with the signed-in account.
  Future<void> updateName(String name);

  /// Mirrors an edited profile (name and photo) into the member record.
  Future<void> updateProfile({required String name, String? photoPath});
}
