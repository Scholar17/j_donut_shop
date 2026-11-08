part of 'otp_bloc.dart';

sealed class OtpEvent {
  const OtpEvent();
}

/// The boxes changed (typing, backspace or paste).
final class OtpCodeChanged extends OtpEvent {
  const OtpCodeChanged(this.code);
  final String code;
}

final class OtpResendPressed extends OtpEvent {
  const OtpResendPressed();
}

final class _OtpTicked extends OtpEvent {
  const _OtpTicked(this.secondsLeft);
  final int secondsLeft;
}

final class _OtpVerifyRequested extends OtpEvent {
  const _OtpVerifyRequested();
}

enum OtpStatus { editing, verifying, resending, verified }

class OtpState extends Equatable {
  const OtpState({
    required this.phone,
    required this.secondsLeft,
    this.code = '',
    this.status = OtpStatus.editing,
    this.wrongAttempts = 0,
    this.shakeCount = 0,
    this.failure,
    this.outcome,
  });

  /// E.164 number the code was sent to.
  final String phone;
  final String code;
  final OtpStatus status;
  final int secondsLeft;
  final int wrongAttempts;

  /// Incremented on every wrong code; the UI shakes when it changes.
  final int shakeCount;
  final Failure? failure;
  final OtpOutcome? outcome;

  bool get isLocked => wrongAttempts >= OtpRules.maxWrongAttempts;
  bool get canResend => secondsLeft == 0 && status != OtpStatus.resending;
  bool get acceptsInput => !isLocked && status == OtpStatus.editing;
  int get attemptsLeft => OtpRules.maxWrongAttempts - wrongAttempts;

  OtpState copyWith({
    String? code,
    OtpStatus? status,
    int? secondsLeft,
    int? wrongAttempts,
    int? shakeCount,
    Failure? Function()? failure,
    OtpOutcome? outcome,
  }) => OtpState(
    phone: phone,
    code: code ?? this.code,
    status: status ?? this.status,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    wrongAttempts: wrongAttempts ?? this.wrongAttempts,
    shakeCount: shakeCount ?? this.shakeCount,
    failure: failure != null ? failure() : this.failure,
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    phone,
    code,
    status,
    secondsLeft,
    wrongAttempts,
    shakeCount,
    failure,
    outcome,
  ];
}
