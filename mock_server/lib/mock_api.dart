import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

/// Public catalogue resources served under `/v1/<resource>`.
const resources = ['products', 'sections', 'banners', 'shops'];

/// Builds the API handler.
///
/// [catalogFile] is re-read on every request, so editing it and pulling to
/// refresh in the app demonstrates a live sync. [failRate] (0–1) makes that
/// share of requests answer 503 to exercise the app's retry interceptor.
Handler buildApi({
  required File catalogFile,
  required Directory publicDir,
  Duration latency = Duration.zero,
  double failRate = 0,
  Random? random,
}) {
  final rng = random ?? Random();
  final router = Router()
    ..get('/v1/health', (Request _) => _json(200, _envelope({'status': 'ok'}, version: 1)))
    ..mount('/v1/images/', createStaticHandler('${publicDir.path}/images'));
  for (final resource in resources) {
    router.get('/v1/$resource', (Request _) => _resource(catalogFile, resource));
  }
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_latency(latency))
      .addMiddleware(_chaos(failRate, rng))
      .addHandler(router.call);
}

Response _resource(File catalogFile, String resource) {
  try {
    final catalog = jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
    final data = catalog[resource];
    if (data is! List) {
      return _json(404, _error('Unknown resource "$resource"'));
    }
    return _json(200, _envelope(data, version: catalog['version'] as int? ?? 1));
  } on FormatException catch (e) {
    return _json(500, _error('catalog.json is invalid: ${e.message}'));
  }
}

Map<String, Object?> _envelope(Object data, {required int version}) => {
      'data': data,
      'error': null,
      'meta': {
        'version': version,
        'count': data is List ? data.length : 1,
        'generatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    };

Map<String, Object?> _error(String message) => {
      'data': null,
      'error': {'message': message},
      'meta': {'generatedAt': DateTime.now().toUtc().toIso8601String()},
    };

Response _json(int status, Object body) => Response(
      status,
      body: jsonEncode(body),
      headers: {HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'},
    );

Middleware _latency(Duration latency) => (inner) => (request) async {
      if (latency > Duration.zero) await Future<void>.delayed(latency);
      return inner(request);
    };

Middleware _chaos(double failRate, Random rng) => (inner) => (request) {
      final isApi = !request.url.path.startsWith('v1/images/') && request.url.path != 'v1/health';
      if (isApi && rng.nextDouble() < failRate) {
        return _json(503, _error('Simulated outage (--fail-rate)'));
      }
      return inner(request);
    };
