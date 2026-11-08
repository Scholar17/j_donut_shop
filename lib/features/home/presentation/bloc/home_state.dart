part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.member = const Loading(),
    this.tiers = const [],
    this.banners = const Loading(),
    this.sections = const {},
    this.shops = const Loading(),
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final LoadState<Member?> member;
  final List<Tier> tiers;
  final LoadState<List<PromoBanner>> banners;
  final Map<HomeSection, LoadState<List<Product>>> sections;
  final LoadState<List<Shop>> shops;
  final bool isRefreshing;

  /// Last refresh error (shown once as a snackbar; data stays visible).
  final Failure? refreshFailure;

  LoadState<List<Product>> section(HomeSection s) =>
      sections[s] ?? const Loading();

  TierProgress? get tierProgress {
    final current = member;
    if (current is! Loaded<Member?> || current.value == null || tiers.isEmpty) {
      return null;
    }
    return tiers_logic.tierProgress(current.value!.points, tiers);
  }

  HomeState copyWith({
    LoadState<Member?>? member,
    List<Tier>? tiers,
    LoadState<List<PromoBanner>>? banners,
    Map<HomeSection, LoadState<List<Product>>>? sections,
    LoadState<List<Shop>>? shops,
    bool? isRefreshing,
    Failure? Function()? refreshFailure,
  }) => HomeState(
    member: member ?? this.member,
    tiers: tiers ?? this.tiers,
    banners: banners ?? this.banners,
    sections: sections ?? this.sections,
    shops: shops ?? this.shops,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    refreshFailure: refreshFailure != null
        ? refreshFailure()
        : this.refreshFailure,
  );

  @override
  List<Object?> get props => [
    member,
    tiers,
    banners,
    sections,
    shops,
    isRefreshing,
    refreshFailure,
  ];
}
