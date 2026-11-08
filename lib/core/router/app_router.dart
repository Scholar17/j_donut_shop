import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_mode.dart';
import '../../features/auth/presentation/bloc/auth_flow_cubit.dart';
import '../../features/auth/presentation/bloc/dob_bloc.dart';
import '../../features/auth/presentation/bloc/name_cubit.dart';
import '../../features/auth/presentation/bloc/otp_bloc.dart';
import '../../features/auth/presentation/bloc/phone_bloc.dart';
import '../../features/auth/presentation/bloc/session_cubit.dart';
import '../../features/auth/presentation/pages/dob_page.dart';
import '../../features/auth/presentation/pages/name_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/phone_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/bloc/product_detail_cubit.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/widgets/product_image.dart';
import '../../features/profile/presentation/bloc/edit_profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/rewards/presentation/bloc/rewards_cubit.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
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
        pageBuilder: (_, state) =>
            fadeThroughPage(key: state.pageKey, child: const WelcomePage()),
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
      for (final mode in AppRoutes.entryModes) ...[
        _phoneStep(mode),
        _otpStep(mode),
      ],
      _nameStep(),
      _dobStep(),
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

  static GoRoute _nameStep() => GoRoute(
    path: AppRoutes.name(),
    pageBuilder: (context, state) {
      final draft = context.read<AuthFlowCubit>().state;
      return sharedAxisPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) =>
              NameCubit(first: draft.firstName, last: draft.lastName),
          child: const NamePage(),
        ),
      );
    },
  );

  static GoRoute _dobStep() => GoRoute(
    path: AppRoutes.dob(),
    pageBuilder: (context, state) {
      final draft = context.read<AuthFlowCubit>().state;
      return sharedAxisPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => DobBloc(
            getIt(),
            month: draft.month,
            day: draft.day,
            year: draft.year,
          ),
          child: const DobPage(),
        ),
      );
    },
  );

  static AuthMode _modeOf(GoRouterState state) {
    final segment = state.uri.pathSegments.firstOrNull;
    return AuthMode.values.asNameMap()[segment] ?? AuthMode.register;
  }

  static RouteBase _mainTabs() => StatefulShellRoute.indexedStack(
    builder: (_, state, shell) => MainShell(
      navigationShell: shell,
      // Product detail is full-screen: the nav slides away.
      showNavigation:
          !state.uri.path.startsWith('/product/') &&
          !state.uri.path.startsWith(AppRoutes.profile),
    ),
    branches: [
      StatefulShellBranch(
        // `/product/:id` lives in the Home branch so the Hero image can fly
        // from the tile (Hero only animates within one Navigator).
        routes: [
          GoRoute(path: AppRoutes.home, builder: _homeBuilder),
          GoRoute(path: AppRoutes.productPattern, pageBuilder: _productPage),
        ],
      ),
      _tab(
        AppRoutes.rewards,
        BlocProvider(
          create: (_) => RewardsCubit(getIt()),
          child: const RewardsPage(),
        ),
      ),
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
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsPage(),
            routes: [_profileRoute()],
          ),
        ],
      ),
    ],
  );

  /// `/product/:id`. The Hero tag comes from the tapped tile (`extra`);
  /// deep links fall back to a default tag.
  static Page<void> _productPage(BuildContext context, GoRouterState state) {
    final id = state.pathParameters['id']!;
    final tag = state.extra is String
        ? state.extra! as String
        : productHeroTag(id, 'link');
    return fadeThroughPage(
      key: state.pageKey,
      child: BlocProvider(
        create: (_) => ProductDetailCubit(getIt(), id),
        child: ProductDetailPage(heroTag: tag),
      ),
    );
  }

  /// `/settings/profile` and its new-number OTP step `/settings/profile/verify`.
  static GoRoute _profileRoute() => GoRoute(
    path: 'profile',
    pageBuilder: (context, state) {
      final session =
          context.read<SessionCubit>().state as SessionAuthenticated;
      return sharedAxisPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => EditProfileBloc(
            user: session.user,
            updateProfile: getIt(),
            requestOtp: getIt(),
            photoPicker: getIt(),
            members: getIt(),
          ),
          child: const EditProfilePage(),
        ),
      );
    },
    routes: [
      GoRoute(
        path: 'verify',
        pageBuilder: (context, state) => sharedAxisPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => OtpBloc(
              verifyOtp: getIt(),
              requestOtp: getIt(),
              mode: AuthMode.changePhone,
              phone: state.extra! as String,
            ),
            child: OtpPage(
              step: null,
              onPhoneVerified: (context) => context.pop(true),
            ),
          ),
        ),
      ),
    ],
  );

  static Widget _homeBuilder(BuildContext context, GoRouterState state) {
    final session = context.read<SessionCubit>().state;
    return BlocProvider(
      create: (_) => HomeBloc(
        catalog: getIt(),
        members: getIt(),
        refreshCatalog: getIt(),
        memberName: session is SessionAuthenticated
            ? session.user.firstName
            : null,
      )..add(const HomeStarted()),
      child: const HomePage(),
    );
  }

  static StatefulShellBranch _tab(String path, Widget page) =>
      StatefulShellBranch(
        routes: [GoRoute(path: path, builder: (_, _) => page)],
      );
}
