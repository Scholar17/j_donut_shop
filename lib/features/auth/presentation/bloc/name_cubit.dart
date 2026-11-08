import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/validators/name_validator.dart';

class NameState extends Equatable {
  const NameState({
    this.first = '',
    this.last = '',
    this.firstTouched = false,
    this.lastTouched = false,
  });

  final String first;
  final String last;

  /// Errors appear only after a field has lost focus once.
  final bool firstTouched;
  final bool lastTouched;

  NameValidationError? get firstError => validateFirstName(first);
  NameValidationError? get lastError => validateLastName(last);
  bool get isValid => firstError == null && lastError == null;

  NameValidationError? get visibleFirstError =>
      firstTouched ? firstError : null;
  NameValidationError? get visibleLastError => lastTouched ? lastError : null;

  NameState copyWith({
    String? first,
    String? last,
    bool? firstTouched,
    bool? lastTouched,
  }) => NameState(
    first: first ?? this.first,
    last: last ?? this.last,
    firstTouched: firstTouched ?? this.firstTouched,
    lastTouched: lastTouched ?? this.lastTouched,
  );

  @override
  List<Object?> get props => [first, last, firstTouched, lastTouched];
}

/// Name step. A Cubit: purely local validation, no async submit to guard.
class NameCubit extends Cubit<NameState> {
  NameCubit({String first = '', String last = ''})
    : super(
        NameState(
          first: first,
          last: last,
          firstTouched: first.isNotEmpty,
          lastTouched: last.isNotEmpty,
        ),
      );

  void firstChanged(String value) => emit(state.copyWith(first: value));
  void lastChanged(String value) => emit(state.copyWith(last: value));
  void firstBlurred() => emit(state.copyWith(firstTouched: true));
  void lastBlurred() => emit(state.copyWith(lastTouched: true));
}
