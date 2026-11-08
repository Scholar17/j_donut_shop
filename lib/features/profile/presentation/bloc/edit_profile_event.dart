part of 'edit_profile_bloc.dart';

enum ProfileField { first, last, phone }

sealed class EditProfileEvent {
  const EditProfileEvent();
}

final class ProfileFieldChanged extends EditProfileEvent {
  const ProfileFieldChanged(this.field, this.value);
  final ProfileField field;
  final String value;
}

final class ProfileFieldBlurred extends EditProfileEvent {
  const ProfileFieldBlurred(this.field);
  final ProfileField field;
}

final class ProfilePhotoPicked extends EditProfileEvent {
  const ProfilePhotoPicked(this.source);
  final PhotoSource source;
}

final class ProfilePhotoRemoved extends EditProfileEvent {
  const ProfilePhotoRemoved();
}

/// Save tapped. A changed phone goes through OTP first.
final class ProfileSaveRequested extends EditProfileEvent {
  const ProfileSaveRequested();
}

/// Result of the verify screen for the new number.
final class ProfileNewPhoneVerified extends EditProfileEvent {
  const ProfileNewPhoneVerified({required this.verified});
  final bool verified;
}
