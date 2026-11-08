import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/connectivity/network_status.dart';
import 'package:j_donut_shop/core/database/sync_meta_store.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/home/data/datasources/catalog_local_data_source.dart';
import 'package:j_donut_shop/features/home/data/datasources/catalog_remote_data_source.dart';
import 'package:j_donut_shop/features/home/data/datasources/catalog_snapshot.dart';
import 'package:j_donut_shop/features/home/data/datasources/seed_importer.dart';
import 'package:j_donut_shop/features/home/data/repositories/catalog_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockLocal extends Mock implements CatalogLocalDataSource {}

class MockRemote extends Mock implements CatalogRemoteDataSource {}

class MockSeed extends Mock implements SeedImporter {}

class MockMeta extends Mock implements SyncMetaStore {}

class MockNetwork extends Mock implements NetworkStatus {}

void main() {
  final now = DateTime(2026, 11, 8);
  const empty = CatalogSnapshot(
    products: [],
    sections: [],
    banners: [],
    shops: [],
  );
  late MockLocal local;
  late MockRemote remote;
  late MockMeta meta;
  late MockNetwork network;
  late CatalogRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(empty));

  setUp(() {
    local = MockLocal();
    remote = MockRemote();
    meta = MockMeta();
    network = MockNetwork();
    repository = CatalogRepositoryImpl(
      local: local,
      remote: remote,
      seed: MockSeed(),
      meta: meta,
      network: network,
      clock: () => now,
    );
  });

  test('offline refresh fails fast without calling the server', () async {
    when(() => network.isOnline).thenAnswer((_) async => false);

    final result = await repository.refresh();

    expect((result as Error).failure, isA<NetworkFailure>());
    verifyZeroInteractions(remote);
    verifyNever(() => local.replaceAll(any()));
  });

  test(
    'a successful fetch replaces the catalogue and records the sync time',
    () async {
      when(() => network.isOnline).thenAnswer((_) async => true);
      when(remote.fetchCatalog)
          .thenAnswer((_) async => const Result.success(empty));

      final result = await repository.refresh();

      expect(result.isSuccess, isTrue);
      verify(() => local.replaceAll(empty)).called(1);
      verify(() => meta.markSynced(now)).called(1);
    },
  );

  test('a server failure leaves the cached catalogue untouched', () async {
    when(() => network.isOnline).thenAnswer((_) async => true);
    when(remote.fetchCatalog)
        .thenAnswer((_) async => const Result.failure(ServerFailure()));

    final result = await repository.refresh();

    expect((result as Error).failure, isA<ServerFailure>());
    verifyNever(() => local.replaceAll(any()));
    verifyNever(() => meta.markSynced(any()));
  });
}
