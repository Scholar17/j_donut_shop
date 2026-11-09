import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/member/data/models/member_entities.dart';

void main() {
  test('toDomain carries the photo picked in Edit profile', () {
    final row = MemberEntity(
      memberId: 'm1',
      name: 'Ye Min',
      points: 10,
      photoPath: '/docs/profile/avatar_1.jpg',
    );

    expect(row.toDomain().photoPath, '/docs/profile/avatar_1.jpg');
  });
}
