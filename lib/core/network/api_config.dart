import 'dart:io' show Platform;

/// Endpoint and timeout settings for the optional mock server.
///
/// Override the base URL at build time:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080`.
abstract final class ApiConfig {
  static const _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Android emulators reach the host machine through 10.0.2.2.
  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:8080';
  }

  static const apiVersion = '/v1';
  static const connectTimeout = Duration(seconds: 5);
  static const receiveTimeout = Duration(seconds: 10);
  static const sendTimeout = Duration(seconds: 10);

  static const maxRetries = 3;
  static const retryBaseDelay = Duration(milliseconds: 400);
}
