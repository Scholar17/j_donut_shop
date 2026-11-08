import 'package:objectbox/objectbox.dart';

import '../../domain/entities/auth_user.dart';

/// ObjectBox row for a locally registered user (fake back end).
@Entity()
class UserEntity {
  UserEntity({
    required this.userId,
    required this.phone,
    required this.firstName,
    required this.dateOfBirth,
    this.lastName,
    this.id = 0,
  });

  factory UserEntity.fromDomain(AuthUser user) => UserEntity(
    userId: user.id,
    phone: user.phone,
    firstName: user.firstName,
    lastName: user.lastName,
    dateOfBirth: user.dateOfBirth,
  );

  @Id()
  int id;

  @Unique()
  String userId;

  /// E.164; unique so one number maps to one account.
  @Unique()
  @Index()
  String phone;

  String firstName;
  String? lastName;

  @Property(type: PropertyType.date)
  DateTime dateOfBirth;

  AuthUser toDomain() => AuthUser(
    id: userId,
    phone: phone,
    firstName: firstName,
    lastName: lastName,
    dateOfBirth: dateOfBirth,
  );
}
