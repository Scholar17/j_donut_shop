import 'package:equatable/equatable.dart';

import 'failure.dart';

/// Per-section UI state: every Home section shows its own skeleton, empty
/// and error state independently of the others.
sealed class LoadState<T> extends Equatable {
  const LoadState();

  @override
  List<Object?> get props => [];
}

final class Loading<T> extends LoadState<T> {
  const Loading();
}

final class Loaded<T> extends LoadState<T> {
  const Loaded(this.value);
  final T value;

  @override
  List<Object?> get props => [value];
}

final class Failed<T> extends LoadState<T> {
  const Failed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
