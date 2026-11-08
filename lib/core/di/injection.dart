import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
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
import '../../features/settings/data/objectbox_preferences_repository.dart';
import '../../features/settings/domain/preferences_repository.dart';
import '../../features/settings/presentation/cubit/preferences_cubit.dart';
import '../../objectbox.g.dart';
import '../connectivity/network_status.dart';
import '../database/app_database.dart';
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
