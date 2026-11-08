import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/auth_mode.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/repositories/profile_photo_picker.dart';
import '../../../auth/domain/usecases/request_otp.dart';
import '../../../auth/domain/usecases/update_profile.dart';
import '../../../auth/domain/validators/name_validator.dart';
import '../../../auth/domain/validators/phone_validator.dart';
import '../../../member/domain/repositories/member_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// Edit profile. Save is `droppable`: a double tap saves (or sends an OTP)
/// once. Same validators as registration.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({
    required AuthUser user,
    required this._updateProfile,
    required this._requestOtp,
    required this._photoPicker,
    required this._members,
  }) : super(EditProfileState.from(user)) {
    on<ProfileFieldChanged>(_onChanged);
    on<ProfileFieldBlurred>(
      (e, emit) => emit(state.copyWith(touched: {...state.touched, e.field})),
    );
    on<ProfilePhotoPicked>(_onPhotoPicked, transformer: droppable());
    on<ProfilePhotoRemoved>(
      (_, emit) => emit(state.copyWith(photoPath: () => null)),
    );
    on<ProfileSaveRequested>(_onSave, transformer: droppable());
    on<ProfileNewPhoneVerified>(_onPhoneVerified, transformer: droppable());
  }

  final UpdateProfile _updateProfile;
  final RequestOtp _requestOtp;
  final ProfilePhotoPicker _photoPicker;

  /// Home and Rewards read the member record; keep its name/photo in sync.
  final MemberRepository _members;

  void _onChanged(ProfileFieldChanged event, Emitter<EditProfileState> emit) =>
      emit(
        switch (event.field) {
          ProfileField.first => state.copyWith(first: event.value),
          ProfileField.last => state.copyWith(last: event.value),
          ProfileField.phone => state.copyWith(rawPhone: event.value),
        }.copyWith(failure: () => null),
      );

  Future<void> _onPhotoPicked(
    ProfilePhotoPicked event,
    Emitter<EditProfileState> emit,
  ) async {
    final path = await _photoPicker.pick(event.source);
    if (path != null) emit(state.copyWith(photoPath: () => path));
  }

  Future<void> _onSave(
    ProfileSaveRequested event,
    Emitter<EditProfileState> emit,
  ) async {
    if (!state.canSave) {
      return emit(state.copyWith(touched: ProfileField.values.toSet()));
    }
    if (!state.phoneChanged) return _save(emit);
    emit(
      state.copyWith(
        status: EditProfileStatus.requestingOtp,
        failure: () => null,
      ),
    );
    final sent = await _requestOtp(
      rawPhone: state.rawPhone,
      mode: AuthMode.changePhone,
    );
    sent.fold(
      onSuccess: (e164) => emit(
        state.copyWith(
          status: EditProfileStatus.awaitingOtp,
          newPhone: () => e164,
        ),
      ),
      onFailure: (f) => emit(
        state.copyWith(status: EditProfileStatus.editing, failure: () => f),
      ),
    );
  }

  Future<void> _onPhoneVerified(
    ProfileNewPhoneVerified event,
    Emitter<EditProfileState> emit,
  ) async {
    if (!event.verified) {
      return emit(
        state.copyWith(status: EditProfileStatus.editing, newPhone: () => null),
      );
    }
    await _save(emit);
  }

  Future<void> _save(Emitter<EditProfileState> emit) async {
    emit(state.copyWith(status: EditProfileStatus.saving, failure: () => null));
    final result = await _updateProfile(
      firstName: state.first,
      lastName: state.last,
      rawPhone: state.rawPhone,
      photoPath: state.photoPath,
    );
    switch (result) {
      case Success(value: final user):
        await _members.updateProfile(
          name: user.firstName,
          photoPath: user.photoPath,
        );
        emit(state.copyWith(status: EditProfileStatus.saved, original: user));
      case Error(:final failure):
        emit(
          state.copyWith(
            status: EditProfileStatus.editing,
            failure: () => failure,
          ),
        );
    }
  }
}
