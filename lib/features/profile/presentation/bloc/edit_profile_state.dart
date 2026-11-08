part of 'edit_profile_bloc.dart';

enum EditProfileStatus {
  editing,

  /// Sending an OTP to the new number.
  requestingOtp,

  /// OTP sent: the page opens the verify screen for [EditProfileState.newPhone].
  awaitingOtp,
  saving,
  saved,
}

class EditProfileState extends Equatable {
  const EditProfileState({
    required this.original,
    required this.first,
    required this.last,
    required this.rawPhone,
    required this.photoPath,
    this.status = EditProfileStatus.editing,
    this.touched = const {},
    this.failure,
    this.newPhone,
  });

  factory EditProfileState.from(AuthUser user) => EditProfileState(
    original: user,
    first: user.firstName,
    last: user.lastName ?? '',
    rawPhone: localPhone(user.phone),
    photoPath: user.photoPath,
  );

  final AuthUser original;
  final String first;
  final String last;

  /// Typed after the fixed `+95`, e.g. `09254135592`.
  final String rawPhone;
  final String? photoPath;
  final EditProfileStatus status;

  /// Fields that lost focus once (their errors are now visible).
  final Set<ProfileField> touched;
  final Failure? failure;

  /// E.164 number waiting for OTP verification.
  final String? newPhone;

  NameValidationError? get firstError => validateFirstName(first);
  NameValidationError? get lastError => validateLastName(last);
  PhoneValidationError? get phoneError => validatePhone(rawPhone);

  bool get phoneChanged => normalizePhone(rawPhone) != original.phone;
  bool get isBusy =>
      status == EditProfileStatus.requestingOtp ||
      status == EditProfileStatus.saving;
  bool get isValid =>
      firstError == null && lastError == null && phoneError == null;

  bool get hasChanges =>
      first.trim() != original.firstName ||
      last.trim() != (original.lastName ?? '') ||
      phoneChanged ||
      photoPath != original.photoPath;

  bool get canSave => isValid && hasChanges && !isBusy;

  bool shows(ProfileField field) => touched.contains(field);

  /// `+959254135592` → `09254135592` (how Myanmar users type it).
  static String localPhone(String e164) =>
      e164.startsWith(PhoneRules.countryCode)
      ? '0${e164.substring(PhoneRules.countryCode.length)}'
      : e164;

  EditProfileState copyWith({
    String? first,
    String? last,
    String? rawPhone,
    String? Function()? photoPath,
    EditProfileStatus? status,
    Set<ProfileField>? touched,
    Failure? Function()? failure,
    String? Function()? newPhone,
    AuthUser? original,
  }) => EditProfileState(
    original: original ?? this.original,
    first: first ?? this.first,
    last: last ?? this.last,
    rawPhone: rawPhone ?? this.rawPhone,
    photoPath: photoPath != null ? photoPath() : this.photoPath,
    status: status ?? this.status,
    touched: touched ?? this.touched,
    failure: failure != null ? failure() : this.failure,
    newPhone: newPhone != null ? newPhone() : this.newPhone,
  );

  @override
  List<Object?> get props => [
    original,
    first,
    last,
    rawPhone,
    photoPath,
    status,
    touched,
    failure,
    newPhone,
  ];
}
