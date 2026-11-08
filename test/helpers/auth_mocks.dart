import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_user.dart';
import 'package:j_donut_shop/features/auth/domain/entities/new_user_profile.dart';
import 'package:j_donut_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

final testUser = AuthUser(
  id: 'u_1',
  phone: '+959254135592',
  firstName: 'Ye Min',
  lastName: 'Phyoe Win',
  dateOfBirth: DateTime(1980, 5),
);

/// Call once in `setUpAll` so `any()` works for custom argument types.
void registerAuthFallbacks() {
  registerFallbackValue(AuthMode.register);
  registerFallbackValue(
    NewUserProfile(phone: '', firstName: '', dateOfBirth: DateTime(2000)),
  );
}
