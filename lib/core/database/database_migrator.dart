import '../../objectbox.g.dart';
import 'db_meta_entity.dart';

/// One data migration step: runs when upgrading *to* [version].
typedef MigrationStep = void Function(Store store);

/// Applies pending data migrations in order inside one write transaction.
class DatabaseMigrator {
  DatabaseMigrator(this._store, this._steps);

  final Store _store;

  /// Keyed by target version; versions must start at 1 and be contiguous.
  final Map<int, MigrationStep> _steps;

  int get latestVersion => _steps.keys.fold(0, (a, b) => a > b ? a : b);

  void migrate() {
    final box = _store.box<DbMetaEntity>();
    _store.runInTransaction(TxMode.write, () {
      final meta = box.getAll().firstOrNull ?? DbMetaEntity();
      for (var v = meta.schemaVersion + 1; v <= latestVersion; v++) {
        _steps[v]?.call(_store);
        meta.schemaVersion = v;
      }
      box.put(meta);
    });
  }

  DbMetaEntity get meta =>
      _store.box<DbMetaEntity>().getAll().firstOrNull ?? DbMetaEntity();

  void markSeeded(int seedVersion) {
    final box = _store.box<DbMetaEntity>();
    box.put(meta..seedVersion = seedVersion);
  }
}
