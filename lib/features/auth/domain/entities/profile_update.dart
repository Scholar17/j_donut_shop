import 'package:equatable/equatable.dart';

/// Edited profile fields. [phone] is E.164; [photoPath] `null` removes the
/// photo.
class ProfileUpdate extends Equatable {
  const ProfileUpdate({
    required this.firstName,
    required this.phone,
    this.lastName,
    this.photoPath,
  });

  final String firstName;
  final String? lastName;
  final String phone;
  final String? photoPath;

  @override
  List<Object?> get props => [firstName, lastName, phone, photoPath];
}
