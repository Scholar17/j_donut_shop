import 'dart:async';

import 'package:dio/dio.dart';

import 'api_config.dart';

/// Retries idempotent requests on transient failures with exponential backoff.
///
/// Only GETs are retried so a retried POST can never duplicate a write.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = ApiConfig.maxRetries,
    this.baseDelay = ApiConfig.retryBaseDelay,
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _attemptKey = 'retry_attempt';
  static const _retryableStatusCodes = {408, 429, 500, 502, 503, 504};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }
    await Future<void>.delayed(baseDelay * (1 << attempt));
    options.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method != 'GET') return false;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => _retryableStatusCodes.contains(
        err.response?.statusCode,
      ),
      _ => false,
    };
  }
}
