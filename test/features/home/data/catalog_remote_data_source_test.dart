import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/home/data/datasources/catalog_remote_data_source.dart';
import 'package:j_donut_shop/features/home/data/datasources/catalog_snapshot.dart';

/// Serves canned JSON per path, or throws [error] for every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.bodies, {this.error});

  final Map<String, Object> bodies;
  final DioExceptionType? error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (error != null) {
      throw DioException(requestOptions: options, type: error!);
    }
    return ResponseBody.fromString(
      jsonEncode(bodies[options.path]),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final seed = jsonDecode(
    File('assets/seed/catalog.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  Map<String, Object> envelopes() => {
    for (final r in ['products', 'sections', 'banners', 'shops'])
      '/$r': {
        'data': seed[r],
        'error': null,
        'meta': {'version': 1},
      },
  };

  CatalogRemoteDataSource source(FakeAdapter adapter) =>
      CatalogRemoteDataSource(Dio()..httpClientAdapter = adapter);

  test('the bundled seed parses into a full catalogue', () {
    final snapshot = CatalogSnapshot.fromJson(seed);

    expect(snapshot.products, hasLength(16));
    expect(snapshot.shops, hasLength(4));
    expect(snapshot.products.first.priceMmk, 3200);
  });

  test('unwraps {data, error, meta} envelopes from every endpoint', () async {
    final result = await source(FakeAdapter(envelopes())).fetchCatalog();

    final snapshot = (result as Success<CatalogSnapshot>).value;
    expect(snapshot.banners.map((b) => b.sortOrder), [0, 1, 2]);
  });

  test('an error envelope becomes a ServerFailure', () async {
    final bodies = envelopes()
      ..['/shops'] = {'data': null, 'error': 'boom', 'meta': {}};

    final result = await source(FakeAdapter(bodies)).fetchCatalog();

    expect((result as Error).failure, isA<ServerFailure>());
  });

  test('a timeout becomes a NetworkFailure', () async {
    final adapter = FakeAdapter(
      const {},
      error: DioExceptionType.connectionTimeout,
    );

    final result = await source(adapter).fetchCatalog();

    expect((result as Error).failure, isA<NetworkFailure>());
  });

  test('a malformed product becomes a ServerFailure, not a crash', () async {
    final bodies = envelopes()
      ..['/products'] = {
        'data': [
          {'id': 'x', 'code': 1},
        ],
        'error': null,
        'meta': {},
      };

    final result = await source(FakeAdapter(bodies)).fetchCatalog();

    expect((result as Error).failure, isA<ServerFailure>());
  });
}
