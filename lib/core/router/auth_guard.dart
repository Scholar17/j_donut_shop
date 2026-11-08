import '../../features/auth/presentation/bloc/session_cubit.dart';
import 'app_routes.dart';

/// Pure redirect rule, unit-testable without a widget tree.
///
/// - Signed out on a private route → Onboarding.
/// - Just registered → Welcome (once).
/// - Signed in on Onboarding/auth steps/Welcome → Home.
String? authRedirect(SessionState session, String location) {
  final isPublic = AppRoutes.isPublic(location);
  return switch (session) {
    SessionUnauthenticated() => isPublic ? null : AppRoutes.onboarding,
    SessionAuthenticated(pendingWelcome: true) =>
      location == AppRoutes.welcome ? null : AppRoutes.welcome,
    SessionAuthenticated() =>
      isPublic || location == AppRoutes.welcome ? AppRoutes.home : null,
  };
}
