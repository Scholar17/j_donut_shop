import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/datasources/user_local_data_source.dart';
import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/request_otp.dart';
import '../../features/auth/domain/usecases/session_usecases.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/presentation/bloc/session_cubit.dart';
import '../../features/home/data/datasources/catalog_local_data_source.dart';
import '../../features/home/data/datasources/catalog_remote_data_source.dart';
import '../../features/home/data/datasources/seed_importer.dart';
import '../../features/home/data/repositories/catalog_repository_impl.dart';
import '../../features/home/domain/repositories/catalog_repository.dart';
import '../../features/home/domain/usecases/refresh_catalog.dart';
import '../../features/member/data/datasources/member_local_data_source.dart';
import '../../features/member/data/repositories/member_repository_impl.dart';
import '../../features/member/domain/repositories/member_repository.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/settings/data/objectbox_preferences_repository.dart';
import '../../features/settings/domain/preferences_repository.dart';
import '../../features/settings/presentation/cubit/preferences_cubit.dart';
import '../../objectbox.g.dart';
import '../connectivity/connectivity_cubit.dart';
import '../connectivity/network_status.dart';
import '../database/app_database.dart';
import '../database/sync_meta_store.dart';
import '../network/dio_factory.dart';
import '../router/app_router.dart';
import '../session/session_storage.dart';

/// Global service locator. Only the composition root (this file, `main`, and
/// route builders) calls `getIt`; widgets receive dependencies via BlocProvider.
final GetIt getIt = GetIt.instance;

/// Registers every dependency in layer order: core → data → domain → blocs.
Future<void> configureDependencies() async {
  await _registerCore();
  _registerSettings();
  _registerAuth();
  _registerCatalog();
  getIt.registerLazySingleton<GoRouter>(() => AppRouter.create(getIt()));
}

Future<void> _registerCore() async {
  final store = await AppDatabase.open();
  getIt
    ..registerSingleton<Store>(store, dispose: (s) => s.close())
    ..registerLazySingleton<Dio>(DioFactory.create)
    ..registerLazySingleton<NetworkStatus>(
      () => ConnectivityNetworkStatus(Connectivity()),
    )
    ..registerLazySingleton(() => ConnectivityCubit(getIt()))
    ..registerLazySingleton(() => SyncMetaStore(getIt()))
    ..registerLazySingleton<SessionStorage>(
      () => SecureSessionStorage(const FlutterSecureStorage()),
    );
}

void _registerSettings() {
  getIt
    ..registerLazySingleton<PreferencesRepository>(
      () => ObjectBoxPreferencesRepository(getIt()),
    )
    ..registerLazySingleton<PreferencesCubit>(() => PreferencesCubit(getIt()));
}

void _registerAuth() {
  getIt
    ..registerLazySingleton(() => UserLocalDataSource(getIt()))
    ..registerLazySingleton<AuthRepository>(
      () => FakeAuthRepository(getIt(), getIt()),
    )
    ..registerFactory(() => RequestOtp(getIt()))
    ..registerFactory(() => VerifyOtp(getIt()))
    ..registerFactory(() => RegisterUser(getIt()))
    ..registerLazySingleton(
      () => SessionCubit(RestoreSession(getIt()), LogOut(getIt())),
    );
}

void _registerCatalog() {
  getIt
    ..registerLazySingleton(() => CatalogLocalDataSource(getIt()))
    ..registerLazySingleton(() => CatalogRemoteDataSource(getIt()))
    ..registerLazySingleton(() => MemberLocalDataSource(getIt()))
    ..registerLazySingleton(
      () => SeedImporter(
        load: () => rootBundle.loadString(seedAssetPath),
        catalog: getIt(),
        member: getIt(),
        meta: getIt(),
      ),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        local: getIt(),
        remote: getIt(),
        seed: getIt(),
        meta: getIt(),
        network: getIt(),
      ),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<MemberRepository>(
      () => MemberRepositoryImpl(getIt()),
    )
    ..registerFactory(() => RefreshCatalog(getIt()));
}

/// Bundled catalogue imported on first launch.
const seedAssetPath = 'assets/seed/catalog.json';
