import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/validators/phone_validator.dart';
import 'submit_status.dart';

export 'submit_status.dart';

sealed class PhoneEvent {
  const PhoneEvent();
}

final class PhoneChanged extends PhoneEvent {
  const PhoneChanged(this.raw);
  final String raw;
}

/// The field lost focus: from now on, show the inline error.
final class PhoneFocusLost extends PhoneEvent {
  const PhoneFocusLost();
}

final class PhoneSubmitted extends PhoneEvent {
  const PhoneSubmitted();
}

class PhoneState extends Equatable {
  const PhoneState({
    this.raw = '',
    this.showError = false,
    this.status = SubmitStatus.idle,
    this.failure,
    this.sentTo,
  });

  final String raw;

  /// Validation errors stay hidden until the first blur.
  final bool showError;
  final SubmitStatus status;
  final Failure? failure;

  /// E.164 number the OTP was sent to (set on success).
  final String? sentTo;

  PhoneValidationError? get validationError => validatePhone(raw);
  bool get canSubmit =>
      validationError == null && status != SubmitStatus.submitting;
  PhoneValidationError? get visibleError => showError ? validationError : null;

  PhoneState copyWith({
    String? raw,
    bool? showError,
    SubmitStatus? status,
    Failure? Function()? failure,
    String? sentTo,
  }) => PhoneState(
    raw: raw ?? this.raw,
    showError: showError ?? this.showError,
    status: status ?? this.status,
    failure: failure != null ? failure() : this.failure,
    sentTo: sentTo ?? this.sentTo,
  );

  @override
  List<Object?> get props => [raw, showError, status, failure, sentTo];
}

class PhoneBloc extends Bloc<PhoneEvent, PhoneState> {
  PhoneBloc(this._requestOtp, {required this.mode, String initialPhone = ''})
    : super(PhoneState(raw: initialPhone, showError: initialPhone.isNotEmpty)) {
    on<PhoneChanged>(_onChanged);
    on<PhoneFocusLost>(
      (_, emit) => emit(state.copyWith(showError: state.raw.isNotEmpty)),
    );
    // droppable: while a request is in flight, further submits are ignored,
    // so a double tap on Continue sends exactly one request.
    on<PhoneSubmitted>(_onSubmitted, transformer: droppable());
  }

  final RequestOtp _requestOtp;
  final AuthMode mode;

  void _onChanged(PhoneChanged event, Emitter<PhoneState> emit) => emit(
    state.copyWith(
      raw: event.raw,
      status: SubmitStatus.idle,
      failure: () => null,
    ),
  );

  Future<void> _onSubmitted(
    PhoneSubmitted event,
    Emitter<PhoneState> emit,
  ) async {
    if (!state.canSubmit) {
      return emit(state.copyWith(showError: true));
    }
    emit(state.copyWith(status: SubmitStatus.submitting, failure: () => null));
    final result = await _requestOtp(rawPhone: state.raw, mode: mode);
    emit(
      result.fold(
        onSuccess: (e164) =>
            state.copyWith(status: SubmitStatus.success, sentTo: e164),
        onFailure: (failure) => state.copyWith(
          status: SubmitStatus.failure,
          failure: () => failure,
        ),
      ),
    );
  }
}
