import '../../objectbox.g.dart';
import 'db_meta_entity.dart';

/// Reads and writes the single [DbMetaEntity] row (seed version, last sync).
class SyncMetaStore {
  SyncMetaStore(Store store) : _box = store.box<DbMetaEntity>();

  final Box<DbMetaEntity> _box;

  DbMetaEntity get _meta => _box.getAll().firstOrNull ?? DbMetaEntity();

  int get seedVersion => _meta.seedVersion;
  DateTime? get lastSyncedAt => _meta.lastSyncedAt;

  void markSeeded(int version) => _box.put(_meta..seedVersion = version);
  void markSynced(DateTime at) => _box.put(_meta..lastSyncedAt = at);
}
