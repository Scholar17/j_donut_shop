import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/member/domain/entities/member.dart';

void main() {
  test('a changed profile photo makes a different member', () {
    // Home rebuilds only when the member changes; a new photo must count.
    const before = Member(id: 'm1', name: 'Ye Min', points: 10);
    const after = Member(
      id: 'm1',
      name: 'Ye Min',
      points: 10,
      photoPath: '/docs/profile/avatar_1.jpg',
    );

    expect(after, isNot(before));
  });
}
