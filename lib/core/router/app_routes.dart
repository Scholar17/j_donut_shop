import '../../features/auth/domain/entities/auth_mode.dart';

/// Every path in the app. Build locations with these helpers, never strings.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const home = '/home';
  static const rewards = '/rewards';
  static const scan = '/scan';
  static const wallet = '/wallet';
  static const settings = '/settings';

  static const productPattern = '/product/:id';
  static String product(String id) => '/product/$id';

  /// Auth steps live under `/register/...` or `/login/...`.
  static const authModeParam = 'mode';
  static const authShellPattern = '/:$authModeParam';
  static const phoneStep = 'phone';
  static const otpStep = 'otp';
  static const nameStep = 'name';
  static const dobStep = 'dob';

  static String phone(AuthMode mode) => '/${mode.name}/$phoneStep';
  static String otp(AuthMode mode) => '/${mode.name}/$otpStep';
  static String name() => '/${AuthMode.register.name}/$nameStep';
  static String dob() => '/${AuthMode.register.name}/$dobStep';

  /// Entry flows reachable without a session (change-phone is not one).
  static const entryModes = [AuthMode.register, AuthMode.login];

  /// Edit profile and its new-number verification (inside the Settings tab).
  static const profile = '/settings/profile';
  static const profileVerify = '/settings/profile/verify';

  /// Routes reachable without a session.
  static bool isPublic(String location) =>
      location == onboarding ||
      entryModes.any((mode) => location.startsWith('/${mode.name}/'));
}
