import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/connectivity/connectivity_cubit.dart';
import 'package:j_donut_shop/core/connectivity/network_status.dart';

/// Each `isOnline` call returns the next queued completer, so a test decides
/// when (and in which order) probes finish.
class _FakeNetwork implements NetworkStatus {
  final changes = StreamController<bool>.broadcast();
  final probes = <Completer<bool>>[];

  @override
  Future<bool> get isOnline {
    final probe = Completer<bool>();
    probes.add(probe);
    return probe.future;
  }

  @override
  Stream<bool> get onStatusChange => changes.stream;
}

void main() {
  test('a slow stale probe does not overwrite a newer online event', () {
    fakeAsync((async) {
      final network = _FakeNetwork();
      final cubit = ConnectivityCubit(network);

      network.changes.add(true); // newer: interface came up and probe passed
      async.flushMicrotasks();
      network.probes.first.complete(false); // launch probe times out late
      async.flushMicrotasks();

      expect(cubit.state, isTrue);
      unawaited(cubit.close());
    });
  });

  test('when offline it re-checks and clears the banner on recovery', () {
    fakeAsync((async) {
      final network = _FakeNetwork();
      final cubit = ConnectivityCubit(
        network,
        recheckInterval: const Duration(seconds: 10),
      );

      network.probes.single.complete(false); // one failed probe
      async.flushMicrotasks();
      expect(cubit.state, isFalse);

      async.elapse(const Duration(seconds: 10)); // automatic re-check
      expect(network.probes, hasLength(2));
      network.probes.last.complete(true);
      async.flushMicrotasks();

      expect(cubit.state, isTrue);
      unawaited(cubit.close());
    });
  });

  test('stays online without re-checking while online', () {
    fakeAsync((async) {
      final network = _FakeNetwork();
      final cubit = ConnectivityCubit(network);

      network.probes.single.complete(true);
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 1));

      expect(cubit.state, isTrue);
      expect(network.probes, hasLength(1));
      unawaited(cubit.close());
    });
  });
}
