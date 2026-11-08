import 'package:equatable/equatable.dart';

/// A registered customer.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.dateOfBirth,
    this.lastName,
    this.photoPath,
  });

  final String id;

  /// E.164, e.g. `+959254135592`.
  final String phone;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;

  /// Local file path of the profile photo, `null` for none.
  final String? photoPath;

  AuthUser copyWith({
    String? phone,
    String? firstName,
    String? Function()? lastName,
    String? Function()? photoPath,
  }) => AuthUser(
    id: id,
    phone: phone ?? this.phone,
    firstName: firstName ?? this.firstName,
    lastName: lastName != null ? lastName() : this.lastName,
    dateOfBirth: dateOfBirth,
    photoPath: photoPath != null ? photoPath() : this.photoPath,
  );

  String get displayName =>
      [firstName, if (lastName != null) lastName].join(' ');

  @override
  List<Object?> get props => [
    id,
    phone,
    firstName,
    lastName,
    dateOfBirth,
    photoPath,
  ];
}
