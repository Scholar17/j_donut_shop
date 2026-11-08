import '../result/failure.dart';
import '../result/result.dart';

/// Unwraps the mock server's `{data, error, meta}` envelope.
abstract final class ApiEnvelope {
  /// Returns `data` as a list of JSON maps, or a [ServerFailure].
  static Result<List<Map<String, dynamic>>> parseList(Object? body) {
    if (body is! Map<String, dynamic>) {
      return const Result.failure(ServerFailure('Body is not an envelope'));
    }
    final error = body['error'];
    if (error != null) {
      return Result.failure(ServerFailure(error.toString()));
    }
    final data = body['data'];
    if (data is! List) {
      return const Result.failure(ServerFailure('Envelope data is not a list'));
    }
    return Result.success(data.cast<Map<String, dynamic>>());
  }

  /// Same as [parseList] for a single-object payload.
  static Result<Map<String, dynamic>> parseObject(Object? body) {
    if (body is! Map<String, dynamic>) {
      return const Result.failure(ServerFailure('Body is not an envelope'));
    }
    final error = body['error'];
    if (error != null) return Result.failure(ServerFailure(error.toString()));
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return const Result.failure(ServerFailure('Envelope data is not an object'));
    }
    return Result.success(data);
  }
}
