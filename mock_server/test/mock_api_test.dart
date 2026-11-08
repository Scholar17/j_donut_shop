import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:jdonuts_mock_server/mock_api.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  final handler = buildApi(
    catalogFile: File('data/catalog.json'),
    publicDir: Directory('public'),
  );

  Future<Map<String, dynamic>> get(Handler h, String path, {int status = 200}) async {
    final response = await h(Request('GET', Uri.parse('http://localhost$path')));
    expect(response.statusCode, status);
    return jsonDecode(await response.readAsString()) as Map<String, dynamic>;
  }

  for (final resource in resources) {
    test('/v1/$resource answers a {data, error, meta} envelope', () async {
      final body = await get(handler, '/v1/$resource');

      expect(body['data'], isA<List<dynamic>>());
      expect(body['error'], isNull);
      expect(body['meta'], containsPair('version', 2));
    });
  }

  test('unknown routes are 404', () async {
    final response = await handler(Request('GET', Uri.parse('http://localhost/v1/nope')));
    expect(response.statusCode, 404);
  });

  test('--fail-rate 1 answers 503 with an error envelope', () async {
    final flaky = buildApi(
      catalogFile: File('data/catalog.json'),
      publicDir: Directory('public'),
      failRate: 1,
      random: Random(1),
    );

    final body = await get(flaky, '/v1/products', status: 503);

    expect(body['data'], isNull);
    expect(body['error'], isNotNull);
  });
}
