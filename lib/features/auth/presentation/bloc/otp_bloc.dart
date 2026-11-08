import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/entities/otp_outcome.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/validators/otp_validator.dart';
import 'otp_ticker.dart';

part 'otp_state.dart';

/// OTP step: auto-verifies at 6 digits, locks after 3 wrong codes until
/// Resend, which unlocks at 0:00 and restarts the 5:00 countdown.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc({
    required this._verifyOtp,
    required this._requestOtp,
    required this.mode,
    required String phone,
    this._ticker = periodicCountdown,
  }) : super(OtpState(phone: phone, secondsLeft: _cooldownSeconds)) {
    on<OtpCodeChanged>(_onCodeChanged);
    on<_OtpVerifyRequested>(_onVerify, transformer: droppable());
    on<OtpResendPressed>(_onResend, transformer: droppable());
    on<_OtpTicked>(
      (event, emit) => emit(state.copyWith(secondsLeft: event.secondsLeft)),
    );
    _startCountdown();
  }

  final VerifyOtp _verifyOtp;
  final RequestOtp _requestOtp;
  final CountdownTicker _ticker;
  final AuthMode mode;
  StreamSubscription<int>? _countdown;

  static final _cooldownSeconds = OtpRules.resendCooldown.inSeconds;

  void _startCountdown() {
    unawaited(_countdown?.cancel());
    _countdown = _ticker(_cooldownSeconds).listen((s) => add(_OtpTicked(s)));
  }

  void _onCodeChanged(OtpCodeChanged event, Emitter<OtpState> emit) {
    if (!state.acceptsInput) return;
    final code = sanitizeOtpInput(event.code);
    emit(state.copyWith(code: code, failure: () => null));
    if (isOtpComplete(code)) add(const _OtpVerifyRequested());
  }

  Future<void> _onVerify(
    _OtpVerifyRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(state.copyWith(status: OtpStatus.verifying));
    final result = await _verifyOtp(
      phone: state.phone,
      code: state.code,
      mode: mode,
    );
    result.fold(
      onSuccess: (outcome) =>
          emit(state.copyWith(status: OtpStatus.verified, outcome: outcome)),
      onFailure: (failure) => emit(_wrongCode(failure)),
    );
  }

  /// Clears the boxes, triggers the shake and counts the attempt.
  OtpState _wrongCode(Failure failure) {
    final isWrongCode =
        failure is AuthFailure &&
        failure.reason == AuthFailureReason.invalidOtp;
    return state.copyWith(
      code: '',
      status: OtpStatus.editing,
      wrongAttempts: isWrongCode
          ? state.wrongAttempts + 1
          : state.wrongAttempts,
      shakeCount: state.shakeCount + 1,
      failure: () => failure,
    );
  }

  Future<void> _onResend(OtpResendPressed event, Emitter<OtpState> emit) async {
    if (!state.canResend) return;
    emit(state.copyWith(status: OtpStatus.resending, failure: () => null));
    final result = await _requestOtp(rawPhone: state.phone, mode: mode);
    result.fold(
      onSuccess: (_) {
        emit(
          OtpState(
            phone: state.phone,
            secondsLeft: _cooldownSeconds,
            shakeCount: state.shakeCount,
          ),
        );
        _startCountdown();
      },
      onFailure: (failure) => emit(
        state.copyWith(status: OtpStatus.editing, failure: () => failure),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _countdown?.cancel();
    return super.close();
  }
}
