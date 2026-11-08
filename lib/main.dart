import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(
    JDonutsApp(
      router: getIt<GoRouter>(),
      preferencesCubit: getIt<PreferencesCubit>(),
    ),
  );
}
