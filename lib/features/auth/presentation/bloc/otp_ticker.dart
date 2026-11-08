/// Emits remaining whole seconds: `total-1, total-2, … 0`, one per second.
/// Injected into OtpBloc so tests can use an instant ticker.
typedef CountdownTicker = Stream<int> Function(int totalSeconds);

Stream<int> periodicCountdown(int totalSeconds) => Stream<int>.periodic(
  const Duration(seconds: 1),
  (elapsed) => totalSeconds - elapsed - 1,
).take(totalSeconds);
