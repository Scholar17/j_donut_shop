import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The signed-in user's session token, kept in the Keychain / Keystore.
class StoredSession {
  const StoredSession({required this.userId, required this.token});
  final String userId;
  final String token;
}

/// Persists the session in encrypted platform storage, never in ObjectBox.
abstract interface class SessionStorage {
  Future<StoredSession?> read();
  Future<void> write(StoredSession session);
  Future<void> clear();
}

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _userIdKey = 'session.user_id';
  static const _tokenKey = 'session.token';

  @override
  Future<StoredSession?> read() async {
    final userId = await _storage.read(key: _userIdKey);
    final token = await _storage.read(key: _tokenKey);
    if (userId == null || token == null) return null;
    return StoredSession(userId: userId, token: token);
  }

  @override
  Future<void> write(StoredSession session) async {
    await _storage.write(key: _userIdKey, value: session.userId);
    await _storage.write(key: _tokenKey, value: session.token);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _tokenKey);
  }
}
