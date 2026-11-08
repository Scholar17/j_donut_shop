import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/load_state.dart';
import '../../../member/domain/entities/member.dart';
import '../../../member/domain/entities/tier.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../../member/domain/usecases/tier_progress.dart' as tiers_logic;
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/refresh_catalog.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Home reads only the local database (via watch streams) and asks the
/// network to *update* that database; it never shows server data directly.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this._catalog,
    required this._members,
    required this._refreshCatalog,
    this.memberName,
  }) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefresh, transformer: droppable());
    on<HomeRefreshFailureShown>(
      (_, emit) => emit(state.copyWith(refreshFailure: () => null)),
    );
  }

  final CatalogRepository _catalog;
  final MemberRepository _members;
  final RefreshCatalog _refreshCatalog;

  /// Signed-in user's name, written into the single member record.
  final String? memberName;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (memberName != null) await _members.updateName(memberName!);
    add(const HomeRefreshRequested());
    await Future.wait([
      _watch(emit, _catalog.watchBanners(), (s, v) => s.copyWith(banners: v)),
      _watch(emit, _catalog.watchShops(), (s, v) => s.copyWith(shops: v)),
      _watch(emit, _members.watchMember(), (s, v) => s.copyWith(member: v)),
      emit.onEach(
        _members.watchTiers(),
        onData: (List<Tier> t) => emit(state.copyWith(tiers: t)),
      ),
      for (final section in HomeSection.values)
        _watch(
          emit,
          _catalog.watchSection(section),
          (s, v) => s.copyWith(sections: {...s.sections, section: v}),
        ),
    ]);
  }

  /// Maps a database stream into one [LoadState] field; a stream error only
  /// fails that section.
  Future<void> _watch<T>(
    Emitter<HomeState> emit,
    Stream<T> stream,
    HomeState Function(HomeState, LoadState<T>) update,
  ) => emit.onEach<T>(
    stream,
    onData: (value) => emit(update(state, Loaded(value))),
    onError: (error, _) => emit(update(state, Failed(CacheFailure('$error')))),
  );

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final result = await _refreshCatalog(force: event.force);
    emit(
      state.copyWith(
        isRefreshing: false,
        refreshFailure: () =>
            result.fold(onSuccess: (_) => null, onFailure: (f) => f),
      ),
    );
  }
}
