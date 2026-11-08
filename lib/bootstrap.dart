import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/connectivity/connectivity_cubit.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/session_cubit.dart';
import 'features/home/domain/repositories/catalog_repository.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';

/// Builds the ready-to-run app: DI, session restore and seed all finish
/// before the first frame. Shared by `main` and the integration test.
Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Restore first so the guard opens Home or Onboarding directly.
  await getIt<SessionCubit>().restore();
  // Seed before the first frame: a first launch in airplane mode still has a
  // full catalogue.
  await getIt<CatalogRepository>().seedIfNeeded();
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: getIt<SessionCubit>()),
      BlocProvider.value(value: getIt<ConnectivityCubit>()),
    ],
    child: JDonutsApp(
      router: getIt<GoRouter>(),
      preferencesCubit: getIt<PreferencesCubit>(),
    ),
  );
}
