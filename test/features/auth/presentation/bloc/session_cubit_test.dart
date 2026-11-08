import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/session_usecases.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  SessionCubit build() =>
      SessionCubit(RestoreSession(repository), LogOut(repository));

  blocTest<SessionCubit, SessionState>(
    'restore emits authenticated when a session is stored',
    setUp: () =>
        when(repository.restoreSession).thenAnswer((_) async => testUser),
    build: build,
    act: (cubit) => cubit.restore(),
    expect: () => [SessionAuthenticated(testUser)],
  );

  blocTest<SessionCubit, SessionState>(
    'a new user is marked as pending Welcome until it is completed',
    build: build,
    act: (cubit) => cubit
      ..signedIn(testUser, isNewUser: true)
      ..welcomeCompleted(),
    expect: () => [
      SessionAuthenticated(testUser, pendingWelcome: true),
      SessionAuthenticated(testUser),
    ],
  );

  blocTest<SessionCubit, SessionState>(
    'log out clears the stored session and emits unauthenticated',
    setUp: () => when(repository.logOut).thenAnswer((_) async {}),
    build: build,
    seed: () => SessionAuthenticated(testUser),
    act: (cubit) => cubit.logOut(),
    expect: () => [const SessionUnauthenticated()],
    verify: (_) => verify(repository.logOut).called(1),
  );
}
