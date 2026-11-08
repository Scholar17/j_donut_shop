import 'package:j_donut_shop/core/session/session_storage.dart';

/// Test double for [SessionStorage]; no platform channels needed.
class InMemorySessionStorage implements SessionStorage {
  StoredSession? value;

  @override
  Future<StoredSession?> read() async => value;

  @override
  Future<void> write(StoredSession session) async => value = session;

  @override
  Future<void> clear() async => value = null;
}
