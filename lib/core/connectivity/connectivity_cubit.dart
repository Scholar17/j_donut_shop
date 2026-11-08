import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_status.dart';

/// App-wide reachability (true = online). Drives the offline banner and lets
/// screens refresh in the background when the network comes back.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._network) : super(true) {
    _subscription = _network.onStatusChange.listen(emit);
    unawaited(
      _network.isOnline.then((online) => isClosed ? null : emit(online)),
    );
  }

  final NetworkStatus _network;
  late final StreamSubscription<bool> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
