import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/settings/data/objectbox_preferences_repository.dart';
import '../../features/settings/domain/preferences_repository.dart';
import '../../features/settings/presentation/cubit/preferences_cubit.dart';
import '../../objectbox.g.dart';
import '../connectivity/network_status.dart';
import '../database/app_database.dart';
import '../network/dio_factory.dart';
import '../session/session_storage.dart';

/// Global service locator. Only the composition root (this file, `main`, and
/// route builders) calls `getIt`; widgets receive dependencies via BlocProvider.
final GetIt getIt = GetIt.instance;

/// Registers every dependency in layer order: core → data → domain → blocs.
Future<void> configureDependencies() async {
  await _registerCore();
  _registerSettings();
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
