import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/home/domain/repositories/catalog_repository.dart';
import 'package:j_donut_shop/features/home/domain/usecases/refresh_catalog.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  final now = DateTime(2026, 11, 8, 12);
  late MockCatalogRepository repository;
  late RefreshCatalog refresh;

  setUp(() {
    repository = MockCatalogRepository();
    refresh = RefreshCatalog(repository, clock: () => now);
    when(repository.refresh)
        .thenAnswer((_) async => const Result.success(null));
  });

  test('refreshes when the catalogue was never synced', () async {
    when(() => repository.lastSyncedAt).thenReturn(null);
    await refresh();
    verify(repository.refresh).called(1);
  });

  test(
    'skips a background refresh within five minutes of the last sync',
    () async {
      when(() => repository.lastSyncedAt)
          .thenReturn(now.subtract(const Duration(minutes: 2)));
      await refresh();
      verifyNever(repository.refresh);
    },
  );

  test('pull-to-refresh (force) always hits the repository', () async {
    when(() => repository.lastSyncedAt)
        .thenReturn(now.subtract(const Duration(minutes: 2)));
    await refresh(force: true);
    verify(repository.refresh).called(1);
  });

  test('refreshes again once the interval has passed', () async {
    when(() => repository.lastSyncedAt)
        .thenReturn(now.subtract(const Duration(minutes: 6)));
    await refresh();
    verify(repository.refresh).called(1);
  });
}
