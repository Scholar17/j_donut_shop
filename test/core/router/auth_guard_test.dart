import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/router/app_routes.dart';
import 'package:j_donut_shop/core/router/auth_guard.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/session_cubit.dart';

import '../../helpers/auth_mocks.dart';

void main() {
  const signedOut = SessionUnauthenticated();
  final signedIn = SessionAuthenticated(testUser);
  final justRegistered = SessionAuthenticated(testUser, pendingWelcome: true);

  group('signed out', () {
    test('is sent from Home to Onboarding', () {
      expect(authRedirect(signedOut, AppRoutes.home), AppRoutes.onboarding);
    });

    test('is sent from a product deep link to Onboarding', () {
      expect(
        authRedirect(signedOut, AppRoutes.product('p_coconut')),
        AppRoutes.onboarding,
      );
    });

    test('may open auth steps', () {
      expect(authRedirect(signedOut, AppRoutes.otp(AuthMode.login)), isNull);
    });
  });

  group('signed in', () {
    test('relaunching on Onboarding opens Home', () {
      expect(authRedirect(signedIn, AppRoutes.onboarding), AppRoutes.home);
    });

    test('finishing log in on the OTP step opens Home', () {
      expect(
        authRedirect(signedIn, AppRoutes.otp(AuthMode.login)),
        AppRoutes.home,
      );
    });

    test('may open product detail', () {
      expect(authRedirect(signedIn, AppRoutes.product('p_coconut')), isNull);
    });

    test('cannot return to Welcome after it was completed', () {
      expect(authRedirect(signedIn, AppRoutes.welcome), AppRoutes.home);
    });
  });

  group('just registered', () {
    test('finishing date of birth opens Welcome', () {
      expect(authRedirect(justRegistered, AppRoutes.dob()), AppRoutes.welcome);
    });

    test('stays on Welcome', () {
      expect(authRedirect(justRegistered, AppRoutes.welcome), isNull);
    });
  });
}
