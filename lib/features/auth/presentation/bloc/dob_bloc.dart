import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/new_user_profile.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/validators/date_of_birth_validator.dart';
import 'submit_status.dart';

sealed class DobEvent {
  const DobEvent();
}

final class DobChanged extends DobEvent {
  const DobChanged({this.month, this.day, this.year});
  final int? month;
  final int? day;
  final int? year;
}

/// Creates the account from the whole registration draft.
final class DobSubmitted extends DobEvent {
  const DobSubmitted({
    required this.phone,
    required this.firstName,
    required this.lastName,
  });
  final String phone;
  final String firstName;
  final String lastName;
}

class DobState extends Equatable {
  const DobState({
    required this.today,
    this.month,
    this.day,
    this.year,
    this.status = SubmitStatus.idle,
    this.failure,
    this.user,
  });

  final DateTime today;
  final int? month;
  final int? day;
  final int? year;
  final SubmitStatus status;
  final Failure? failure;

  /// The created user (set on success).
  final AuthUser? user;

  DateOfBirthError? get error =>
      validateDateOfBirth(month: month, day: day, year: year, today: today);

  /// "Incomplete" is never shown inline; the disabled button says enough.
  DateOfBirthError? get visibleError =>
      error == DateOfBirthError.incomplete ? null : error;
  bool get canSubmit => error == null && status != SubmitStatus.submitting;

  @override
  List<Object?> get props => [today, month, day, year, status, failure, user];
}

class DobBloc extends Bloc<DobEvent, DobState> {
  DobBloc(
    this._registerUser, {
    DateTime Function() clock = DateTime.now,
    int? month,
    int? day,
    int? year,
  }) : super(DobState(today: clock(), month: month, day: day, year: year)) {
    on<DobChanged>(_onChanged);
    // droppable: a double tap on Continue creates the account once.
    on<DobSubmitted>(_onSubmitted, transformer: droppable());
  }

  final RegisterUser _registerUser;

  void _onChanged(DobChanged event, Emitter<DobState> emit) => emit(
    DobState(
      today: state.today,
      month: event.month,
      day: event.day,
      year: event.year,
    ),
  );

  Future<void> _onSubmitted(DobSubmitted event, Emitter<DobState> emit) async {
    if (!state.canSubmit) return;
    emit(_copy(status: SubmitStatus.submitting));
    final result = await _registerUser(
      NewUserProfile(
        phone: event.phone,
        firstName: event.firstName,
        lastName: event.lastName,
        dateOfBirth: DateTime(state.year!, state.month!, state.day!),
      ),
    );
    emit(
      result.fold(
        onSuccess: (user) => _copy(status: SubmitStatus.success, user: user),
        onFailure: (failure) =>
            _copy(status: SubmitStatus.failure, failure: failure),
      ),
    );
  }

  DobState _copy({
    required SubmitStatus status,
    Failure? failure,
    AuthUser? user,
  }) => DobState(
    today: state.today,
    month: state.month,
    day: state.day,
    year: state.year,
    status: status,
    failure: failure,
    user: user,
  );
}
