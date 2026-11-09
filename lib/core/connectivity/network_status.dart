import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the internet is actually reachable, not just whether a
/// Wi-Fi or mobile interface is up (captive portals and dead hotspots report
/// "connected" too).
abstract interface class NetworkStatus {
  Future<bool> get isOnline;

  /// Re-checks reachability on every network-interface change. Repeated
  /// values are possible; consumers de-duplicate.
  Stream<bool> get onStatusChange;
}

class ConnectivityNetworkStatus implements NetworkStatus {
  ConnectivityNetworkStatus(this._connectivity, {ReachabilityProbe? probe})
    : _probe = probe ?? ReachabilityProbe();

  final Connectivity _connectivity;
  final ReachabilityProbe _probe;

  @override
  Future<bool> get isOnline async {
    final interfaces = await _connectivity.checkConnectivity();
    return _hasInterface(interfaces) && await _probe.canReachInternet();
  }

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.asyncMap(
        (interfaces) async =>
            _hasInterface(interfaces) && await _probe.canReachInternet(),
      );

  bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}

/// Opens TCP sockets to public resolvers on HTTPS and DNS ports, all at
/// once; reachable as soon as any one connects. Several ports matter: some
/// networks block DNS (53) to public resolvers while web traffic works.
class ReachabilityProbe {
  ReachabilityProbe({
    this.endpoints = const [
      ('1.1.1.1', 443),
      ('8.8.8.8', 443),
      ('1.1.1.1', 53),
      ('8.8.8.8', 53),
    ],
    this.timeout = const Duration(seconds: 3),
  });

  final List<(String host, int port)> endpoints;
  final Duration timeout;

  Future<bool> canReachInternet() {
    final result = Completer<bool>();
    var failures = 0;
    for (final (host, port) in endpoints) {
      unawaited(
        _tryConnect(host, port).then((ok) {
          if (result.isCompleted) return;
          if (ok) return result.complete(true);
          if (++failures == endpoints.length) result.complete(false);
        }),
      );
    }
    return result.future;
  }

  Future<bool> _tryConnect(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
