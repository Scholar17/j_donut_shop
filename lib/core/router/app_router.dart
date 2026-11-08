import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_mode.dart';
import '../../features/auth/presentation/bloc/auth_flow_cubit.dart';
import '../../features/auth/presentation/bloc/otp_bloc.dart';
import '../../features/auth/presentation/bloc/phone_bloc.dart';
import '../../features/auth/presentation/bloc/session_cubit.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/phone_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../di/injection.dart';
import '../widgets/placeholder_page.dart';
import 'app_routes.dart';
import 'auth_guard.dart';
import 'page_transitions.dart';
import 'stream_listenable.dart';

/// Builds the app's [GoRouter]. Screens are registered here, and the
/// [SessionCubit] drives every auth redirect.
abstract final class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter create(SessionCubit session) => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: StreamListenable(session.stream),
    redirect: (_, state) => authRedirect(session.state, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) =>
            fadeThroughPage(key: state.pageKey, child: const OnboardingPage()),
      ),
      _authFlow(),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (_, state) => fadeThroughPage(
          key: state.pageKey,
          child: const PlaceholderPage(title: 'Welcome'),
        ),
      ),
      GoRoute(
        path: AppRoutes.productPattern,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            PlaceholderPage(title: 'Product ${state.pathParameters['id']}'),
      ),
      _mainTabs(),
    ],
  );

  /// `/register/*` and `/login/*`. One [AuthFlowCubit] per flow keeps values
  /// across steps; keyed by mode so switching flow starts a fresh draft.
  static RouteBase _authFlow() => ShellRoute(
    builder: (_, state, child) {
      final mode = _modeOf(state);
      return BlocProvider(
        key: ValueKey(mode),
        create: (_) => AuthFlowCubit(mode),
        child: child,
      );
    },
    routes: [
      for (final mode in AuthMode.values) ...[_phoneStep(mode), _otpStep(mode)],
      _step(AppRoutes.name(), 'Name'),
      _step(AppRoutes.dob(), 'Date of birth'),
    ],
  );

  static GoRoute _phoneStep(AuthMode mode) => GoRoute(
    path: AppRoutes.phone(mode),
    pageBuilder: (context, state) => sharedAxisPage(
      key: state.pageKey,
      child: BlocProvider(
        create: (_) => PhoneBloc(
          getIt(),
          mode: mode,
          initialPhone: context.read<AuthFlowCubit>().state.rawPhone,
        ),
        child: const PhonePage(),
      ),
    ),
  );

  static GoRoute _otpStep(AuthMode mode) => GoRoute(
    path: AppRoutes.otp(mode),
    pageBuilder: (context, state) => sharedAxisPage(
      key: state.pageKey,
      child: BlocProvider(
        create: (_) => OtpBloc(
          verifyOtp: getIt(),
          requestOtp: getIt(),
          mode: mode,
          phone: context.read<AuthFlowCubit>().state.verifiedPhone ?? '',
        ),
        child: const OtpPage(),
      ),
    ),
  );

  static GoRoute _step(String path, String title) => GoRoute(
    path: path,
    pageBuilder: (_, state) => sharedAxisPage(
      key: state.pageKey,
      child: PlaceholderPage(title: title),
    ),
  );

  static AuthMode _modeOf(GoRouterState state) {
    final segment = state.uri.pathSegments.firstOrNull;
    return AuthMode.values.asNameMap()[segment] ?? AuthMode.register;
  }

  static RouteBase _mainTabs() => StatefulShellRoute.indexedStack(
    builder: (_, _, shell) => MainShell(navigationShell: shell),
    branches: [
      _tab(AppRoutes.home, const PlaceholderPage(title: 'Home')),
      _tab(AppRoutes.rewards, const PlaceholderPage(title: 'Rewards')),
      _tab(
        AppRoutes.scan,
        const PlaceholderPage(
          title: 'Scan',
          icon: Icons.qr_code_scanner_rounded,
        ),
      ),
      _tab(
        AppRoutes.wallet,
        const PlaceholderPage(
          title: 'Wallet',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ),
      _tab(AppRoutes.settings, const SettingsPage()),
    ],
  );

  static StatefulShellBranch _tab(String path, Widget page) =>
      StatefulShellBranch(
        routes: [GoRoute(path: path, builder: (_, _) => page)],
      );
}
