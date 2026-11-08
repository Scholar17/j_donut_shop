import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/session_cubit.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Restore before the first frame so the guard opens Home or Onboarding
  // directly, with no splash flicker.
  await getIt<SessionCubit>().restore();
  runApp(
    BlocProvider.value(
      value: getIt<SessionCubit>(),
      child: JDonutsApp(
        router: getIt<GoRouter>(),
        preferencesCubit: getIt<PreferencesCubit>(),
      ),
    ),
  );
}
