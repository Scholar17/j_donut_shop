import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_status.dart';

/// App-wide reachability (true = online). Drives the offline banner and lets
/// screens refresh in the background when the network comes back.
///
/// Two guards keep the banner honest:
/// - **Latest wins.** Each check is numbered; a slow, older result (e.g. the
///   launch check timing out) can never overwrite a newer one.
/// - **Self-healing.** While offline it re-checks every [recheckInterval], so
///   one failed probe (phone waking up, battery saver) does not leave the
///   banner up until the next Wi-Fi/mobile change.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._network, {this.recheckInterval = defaultRecheck})
    : super(true) {
    _subscription = _network.onStatusChange.listen((online) {
      _latest++; // supersedes any check still in flight
      _apply(online);
    });
    unawaited(check());
  }

  static const defaultRecheck = Duration(seconds: 10);

  final NetworkStatus _network;
  final Duration recheckInterval;
  late final StreamSubscription<bool> _subscription;
  Timer? _recheck;
  int _latest = 0;

  /// Probes now; the result is dropped if a newer one arrived meanwhile.
  Future<void> check() async {
    final id = ++_latest;
    final online = await _network.isOnline;
    if (isClosed || id != _latest) return;
    _apply(online);
  }

  void _apply(bool online) {
    _recheck?.cancel();
    if (!online) _recheck = Timer(recheckInterval, check);
    emit(online);
  }

  @override
  Future<void> close() async {
    _recheck?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}
