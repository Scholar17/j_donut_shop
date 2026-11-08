part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

/// Subscribes to every local stream and kicks off a background refresh.
final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// [force]: pull-to-refresh bypasses the background throttle.
final class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested({this.force = false});
  final bool force;
}

final class HomeRefreshFailureShown extends HomeEvent {
  const HomeRefreshFailureShown();
}
