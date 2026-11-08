import 'dart:convert';

import '../../../../core/data/json_reader.dart';
import '../../../../core/database/sync_meta_store.dart';
import '../../../member/data/datasources/member_local_data_source.dart';
import 'catalog_local_data_source.dart';
import 'catalog_snapshot.dart';

/// Loads the raw seed file; injected so tests don't need the asset bundle.
typedef SeedLoader = Future<String> Function();

/// Imports `assets/seed/catalog.json` into ObjectBox once per seed version,
/// so the very first launch works with no network at all.
class SeedImporter {
  SeedImporter({
    required this.load,
    required this._catalog,
    required this._member,
    required this._meta,
  });

  final SeedLoader load;
  final CatalogLocalDataSource _catalog;
  final MemberLocalDataSource _member;
  final SyncMetaStore _meta;

  /// Returns true when the seed was (re)imported.
  Future<bool> importIfNeeded() async {
    final json = jsonDecode(await load()) as Map<String, dynamic>;
    final version = json.read<int>('version');
    if (_meta.seedVersion >= version && !_catalog.isEmpty) return false;
    _catalog.replaceAll(CatalogSnapshot.fromJson(json));
    _member.importSeed(json);
    _meta.markSeeded(version);
    return true;
  }
}
