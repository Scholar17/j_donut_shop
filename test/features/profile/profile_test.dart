import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/data/datasources/user_local_data_source.dart';
import 'package:j_donut_shop/features/auth/data/models/user_entity.dart';
import 'package:j_donut_shop/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_user.dart';
import 'package:j_donut_shop/features/auth/domain/entities/profile_update.dart';
import 'package:j_donut_shop/features/auth/domain/repositories/profile_photo_picker.dart';
import 'package:j_donut_shop/core/session/session_storage.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/request_otp.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/update_profile.dart';
import 'package:j_donut_shop/features/member/domain/repositories/member_repository.dart';
import 'package:j_donut_shop/features/profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/in_memory_session_storage.dart';

class MockUsers extends Mock implements UserLocalDataSource {}

class MockMembers extends Mock implements MemberRepository {}

class FakePicker implements ProfilePhotoPicker {
  @override
  Future<String?> pick(PhotoSource source) async => '/docs/profile/avatar.jpg';
}

const _profile = ProfileUpdate(firstName: 'Ye Min', phone: '+959254135592');

void main() {
  setUpAll(() {
    registerAuthFallbacks();
    registerFallbackValue(_profile);
    registerFallbackValue(UserEntity.fromDomain(testUser));
  });

  group('UpdateProfile', () {
    late MockAuthRepository repository;
    setUp(() => repository = MockAuthRepository());

    test('rejects digits in the name without calling the repository', () async {
      final result = await UpdateProfile(repository)(
        firstName: 'Ye 2',
        lastName: '',
        rawPhone: '09254135592',
      );

      expect((result as Error).failure, isA<ValidationFailure>());
      verifyNever(() => repository.updateProfile(any()));
    });

    test('saves trimmed names and the E.164 phone', () async {
      when(() => repository.updateProfile(any()))
          .thenAnswer((_) async => Result.success(testUser));

      await UpdateProfile(repository)(
        firstName: ' Ye Min ',
        lastName: ' ',
        rawPhone: '09 254 135 592',
      );

      final saved =
          verify(() => repository.updateProfile(captureAny())).captured.single
              as ProfileUpdate;
      expect(
        saved,
        const ProfileUpdate(firstName: 'Ye Min', phone: '+959254135592'),
      );
    });
  });

  group('FakeAuthRepository.updateProfile', () {
    late MockUsers users;
    late InMemorySessionStorage session;
    late FakeAuthRepository repository;
    const newPhone = '+959777123456';

    setUp(() async {
      users = MockUsers();
      session = InMemorySessionStorage();
      repository = FakeAuthRepository(users, session, latency: Duration.zero);
      await session.write(StoredSession(userId: testUser.id, token: 't'));
      when(() => users.findById(testUser.id))
          .thenReturn(UserEntity.fromDomain(testUser));
      when(() => users.findByPhone(any())).thenReturn(null);
      when(() => users.save(any())).thenAnswer((_) async {});
    });

    AuthFailureReason? reason(Result<Object?> r) => r.fold(
      onSuccess: (_) => null,
      onFailure: (f) => (f as AuthFailure).reason,
    );

    test('a new number must be verified by OTP first', () async {
      final result = await repository.updateProfile(
        const ProfileUpdate(firstName: 'Ye Min', phone: newPhone),
      );
      expect(reason(result), AuthFailureReason.phoneNotVerified);
    });

    test('a number owned by another account cannot be requested', () async {
      when(() => users.findByPhone(newPhone))
          .thenReturn(UserEntity.fromDomain(testUser));
      final result = await repository.requestOtp(
        phone: newPhone,
        mode: AuthMode.changePhone,
      );
      expect(reason(result), AuthFailureReason.phoneAlreadyRegistered);
    });

    test('after OTP verification the new number and photo are saved', () async {
      await repository.verifyOtp(
        phone: newPhone,
        code: FakeAuthConfig.otpCode,
        mode: AuthMode.changePhone,
      );

      final result = await repository.updateProfile(
        const ProfileUpdate(
          firstName: 'Ko Ko',
          phone: newPhone,
          photoPath: '/p.jpg',
        ),
      );

      final user = (result as Success<AuthUser>).value;
      expect(
        (user.phone, user.firstName, user.photoPath),
        (newPhone, 'Ko Ko', '/p.jpg'),
      );
    });
  });

  group('EditProfileBloc', () {
    late MockAuthRepository repository;
    late MockMembers members;

    setUp(() {
      repository = MockAuthRepository();
      members = MockMembers();
      when(() => repository.updateProfile(any()))
          .thenAnswer((_) async => Result.success(testUser));
      when(
        () => repository.requestOtp(
          phone: any(named: 'phone'),
          mode: any(named: 'mode'),
        ),
      ).thenAnswer((_) async => const Result.success(null));
      when(
        () => members.updateProfile(
          name: any(named: 'name'),
          photoPath: any(named: 'photoPath'),
        ),
      ).thenAnswer((_) async {});
    });

    EditProfileBloc build() => EditProfileBloc(
      user: testUser,
      updateProfile: UpdateProfile(repository),
      requestOtp: RequestOtp(repository),
      photoPicker: FakePicker(),
      members: members,
    );

    test('starts with the local phone format and nothing to save', () {
      final state = build().state;
      expect(state.rawPhone, '09254135592');
      expect(state.canSave, isFalse);
    });

    blocTest<EditProfileBloc, EditProfileState>(
      'a name change saves directly and syncs the member record',
      build: build,
      act: (bloc) => bloc
        ..add(const ProfileFieldChanged(ProfileField.first, 'Ko Ko'))
        ..add(const ProfileSaveRequested()),
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.status, EditProfileStatus.saved);
        verifyNever(
          () => repository.requestOtp(
            phone: any(named: 'phone'),
            mode: any(named: 'mode'),
          ),
        );
        verify(
          () =>
              members.updateProfile(name: testUser.firstName, photoPath: null),
        ).called(1);
      },
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'a phone change asks for OTP before saving',
      build: build,
      act: (bloc) => bloc
        ..add(const ProfileFieldChanged(ProfileField.phone, '09777123456'))
        ..add(const ProfileSaveRequested()),
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.status, EditProfileStatus.awaitingOtp);
        expect(bloc.state.newPhone, '+959777123456');
        verifyNever(() => repository.updateProfile(any()));
      },
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'picking a photo makes the form savable',
      build: build,
      act: (bloc) => bloc.add(const ProfilePhotoPicked(PhotoSource.gallery)),
      verify: (bloc) {
        expect(bloc.state.photoPath, '/docs/profile/avatar.jpg');
        expect(bloc.state.canSave, isTrue);
      },
    );
  });
}
