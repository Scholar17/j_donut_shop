import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_mode.dart';

/// Everything typed so far in the Phone → OTP → Name → DOB flow.
///
/// Lives in a ShellRoute above the step routes, so pressing back re-opens a
/// step with its values intact; leaving the flow disposes it.
class AuthDraft extends Equatable {
  const AuthDraft({
    required this.mode,
    this.rawPhone = '',
    this.verifiedPhone,
    this.firstName = '',
    this.lastName = '',
    this.month,
    this.day,
    this.year,
  });

  final AuthMode mode;
  final String rawPhone;

  /// E.164 number the OTP was sent to.
  final String? verifiedPhone;
  final String firstName;
  final String lastName;
  final int? month;
  final int? day;
  final int? year;

  AuthDraft copyWith({
    String? rawPhone,
    String? verifiedPhone,
    String? firstName,
    String? lastName,
    int? Function()? month,
    int? Function()? day,
    int? Function()? year,
  }) => AuthDraft(
    mode: mode,
    rawPhone: rawPhone ?? this.rawPhone,
    verifiedPhone: verifiedPhone ?? this.verifiedPhone,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    month: month != null ? month() : this.month,
    day: day != null ? day() : this.day,
    year: year != null ? year() : this.year,
  );

  @override
  List<Object?> get props => [
    mode,
    rawPhone,
    verifiedPhone,
    firstName,
    lastName,
    month,
    day,
    year,
  ];
}

class AuthFlowCubit extends Cubit<AuthDraft> {
  AuthFlowCubit(AuthMode mode) : super(AuthDraft(mode: mode));

  void phoneChanged(String raw) => emit(state.copyWith(rawPhone: raw));

  void otpSent(String e164) => emit(state.copyWith(verifiedPhone: e164));

  void nameChanged({required String first, required String last}) =>
      emit(state.copyWith(firstName: first, lastName: last));

  void dateOfBirthChanged({int? month, int? day, int? year}) => emit(
    state.copyWith(month: () => month, day: () => day, year: () => year),
  );
}
