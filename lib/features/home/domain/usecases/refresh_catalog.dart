import '../../../../core/result/result.dart';
import '../repositories/catalog_repository.dart';

/// Refreshes the catalogue from the server.
///
/// Background refreshes (app start, connectivity regained) are throttled to
/// once per [minInterval]; pull-to-refresh passes `force: true`.
class RefreshCatalog {
  RefreshCatalog(
    this._repository, {
    this.minInterval = const Duration(minutes: 5),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CatalogRepository _repository;
  final Duration minInterval;
  final DateTime Function() _clock;

  Future<Result<void>> call({bool force = false}) async {
    final last = _repository.lastSyncedAt;
    final isFresh = last != null && _clock().difference(last) < minInterval;
    if (!force && isFresh) return const Result.success(null);
    return _repository.refresh();
  }
}
