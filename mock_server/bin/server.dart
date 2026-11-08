import 'dart:io';

import 'package:args/args.dart';
import 'package:jdonuts_mock_server/mock_api.dart';
import 'package:shelf/shelf_io.dart' as io;

/// dart run bin/server.dart [--port 8080] [--latency 300] [--fail-rate 0.3]
Future<void> main(List<String> arguments) async {
  final args = (ArgParser()
        ..addOption('port', defaultsTo: '8080')
        ..addOption('latency', help: 'Delay per request in ms', defaultsTo: '0')
        ..addOption('fail-rate', help: '0–1 share of API calls answering 503', defaultsTo: '0'))
      .parse(arguments);
  final root = File.fromUri(Platform.script).parent.parent.path;
  final handler = buildApi(
    catalogFile: File('$root/data/catalog.json'),
    publicDir: Directory('$root/public'),
    latency: Duration(milliseconds: int.parse(args['latency'] as String)),
    failRate: double.parse(args['fail-rate'] as String),
  );
  // 0.0.0.0 so a phone on the same Wi-Fi (or via `adb reverse`) can reach it.
  final server = await io.serve(handler, InternetAddress.anyIPv4, int.parse(args['port'] as String));
  stdout.writeln('J\'Donuts mock API on http://${server.address.host}:${server.port}/v1');
}
