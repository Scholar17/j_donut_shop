import 'package:equatable/equatable.dart';

/// Everything collected during registration, submitted in one call.
class NewUserProfile extends Equatable {
  const NewUserProfile({
    required this.phone,
    required this.firstName,
    required this.dateOfBirth,
    this.lastName,
  });

  final String phone;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;

  @override
  List<Object?> get props => [phone, firstName, lastName, dateOfBirth];
}
