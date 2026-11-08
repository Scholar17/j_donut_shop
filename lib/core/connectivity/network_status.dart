import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the internet is actually reachable, not just whether a
/// Wi-Fi or mobile interface is up (captive portals and dead hotspots report
/// "connected" too).
abstract interface class NetworkStatus {
  Future<bool> get isOnline;

  /// Emits only when reachability flips.
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
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .asyncMap(
        (interfaces) async =>
            _hasInterface(interfaces) && await _probe.canReachInternet(),
      )
      .distinct();

  bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}

/// Opens a TCP socket to public DNS resolvers; succeeds only with real egress.
class ReachabilityProbe {
  ReachabilityProbe({
    this.hosts = const ['1.1.1.1', '8.8.8.8'],
    this.port = 53,
    this.timeout = const Duration(seconds: 3),
  });

  final List<String> hosts;
  final int port;
  final Duration timeout;

  Future<bool> canReachInternet() async {
    for (final host in hosts) {
      if (await _tryConnect(host)) return true;
    }
    return false;
  }

  Future<bool> _tryConnect(String host) async {
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
