import 'package:dio/dio.dart';

import '../../../../core/network/api_envelope.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import 'catalog_snapshot.dart';

/// Reads the public catalogue from the mock server (`/v1/...`).
class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._dio);

  final Dio _dio;

  static const _resources = ['products', 'sections', 'banners', 'shops'];

  /// Fetches all resources in parallel. Either every list arrives and parses,
  /// or a typed failure is returned and nothing is written.
  Future<Result<CatalogSnapshot>> fetchCatalog() async {
    try {
      final responses = await Future.wait(
        _resources.map((r) => _dio.get<Object>('/$r')),
      );
      final json = <String, dynamic>{};
      for (var i = 0; i < _resources.length; i++) {
        final parsed = ApiEnvelope.parseList(responses[i].data);
        if (parsed case Error(:final failure)) return Result.failure(failure);
        json[_resources[i]] =
            (parsed as Success<List<Map<String, dynamic>>>).value;
      }
      return Result.success(CatalogSnapshot.fromJson(json));
    } on DioException catch (error) {
      return Result.failure(_mapDioError(error));
    } on FormatException catch (error) {
      return Result.failure(
        ServerFailure('Malformed catalogue: ${error.message}'),
      );
    }
  }

  static Failure _mapDioError(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.connectionError => NetworkFailure(error.message),
    _ => ServerFailure('${error.response?.statusCode} ${error.message}'),
  };
}
