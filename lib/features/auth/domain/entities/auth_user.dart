import 'package:equatable/equatable.dart';

/// A registered customer.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.dateOfBirth,
    this.lastName,
  });

  final String id;

  /// E.164, e.g. `+959254135592`.
  final String phone;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;

  String get displayName =>
      [firstName, if (lastName != null) lastName].join(' ');

  @override
  List<Object?> get props => [id, phone, firstName, lastName, dateOfBirth];
}
