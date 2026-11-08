import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../objectbox.g.dart';
import 'database_migrator.dart';

/// Opens the ObjectBox [Store] and runs pending data migrations.
abstract final class AppDatabase {
  static const _directoryName = 'jdonuts-db';

  /// Data migrations by target version. Add a new entry for each release that
  /// needs to reshape stored data; never edit or remove a shipped entry.
  static final Map<int, MigrationStep> migrations = {
    1: (_) {}, // v1: initial schema, nothing to transform.
  };

  static Future<Store> open() async {
    final docs = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docs.path, _directoryName));
    DatabaseMigrator(store, migrations).migrate();
    return store;
  }
}
