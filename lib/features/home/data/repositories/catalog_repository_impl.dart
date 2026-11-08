import '../../../../core/connectivity/network_status.dart';
import '../../../../core/database/sync_meta_store.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../datasources/seed_importer.dart';

/// Offline-first catalogue: ObjectBox is the single source of truth.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required this._local,
    required this._remote,
    required this._seed,
    required this._meta,
    required this._network,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CatalogLocalDataSource _local;
  final CatalogRemoteDataSource _remote;
  final SeedImporter _seed;
  final SyncMetaStore _meta;
  final NetworkStatus _network;
  final DateTime Function() _clock;

  @override
  Future<Result<void>> seedIfNeeded() async {
    try {
      await _seed.importIfNeeded();
      return const Result.success(null);
    } on Exception catch (error) {
      return Result.failure(CacheFailure('Seed import failed: $error'));
    }
  }

  @override
  Stream<List<PromoBanner>> watchBanners() =>
      _local.watchBanners().map((rows) => [for (final r in rows) r.toDomain()]);

  @override
  Stream<List<Product>> watchSection(HomeSection section) => _local
      .watchSection(section.key)
      .map((rows) => [for (final r in rows) r.toDomain()]);

  @override
  Stream<List<Shop>> watchShops() =>
      _local.watchShops().map((rows) => [for (final r in rows) r.toDomain()]);

  @override
  DateTime? get lastSyncedAt => _meta.lastSyncedAt;

  @override
  Future<Result<void>> refresh() async {
    if (!await _network.isOnline) {
      return const Result.failure(
        NetworkFailure('Offline: kept cached catalogue'),
      );
    }
    final fetched = await _remote.fetchCatalog();
    return switch (fetched) {
      Success(:final value) => _save(() {
        _local.replaceAll(value);
        _meta.markSynced(_clock());
      }),
      Error(:final failure) => Result.failure(failure),
    };
  }

  Result<void> _save(void Function() write) {
    try {
      write();
      return const Result.success(null);
    } on Exception catch (error) {
      return Result.failure(CacheFailure('Saving catalogue failed: $error'));
    }
  }
}
