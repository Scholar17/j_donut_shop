import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_error_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/repositories/profile_photo_picker.dart';
import '../../../auth/domain/validators/phone_validator.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../../auth/presentation/widgets/name_error_text.dart';
import '../bloc/edit_profile_bloc.dart';
import '../widgets/profile_avatar.dart';

/// Settings → Edit profile: photo, first/last name and phone number.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileState _initial = context.read<EditProfileBloc>().state;
  late final _first = TextEditingController(text: _initial.first);
  late final _last = TextEditingController(text: _initial.last);
  late final _phone = TextEditingController(text: _initial.rawPhone);

  static const _avatarSize = 112.0;
  static const _maxPhoneLength = 16;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _onStatus(BuildContext context, EditProfileState state) async {
    final bloc = context.read<EditProfileBloc>();
    if (state.status == EditProfileStatus.awaitingOtp) {
      final verified = await context.push<bool>(
        AppRoutes.profileVerify,
        extra: state.newPhone,
      );
      bloc.add(ProfileNewPhoneVerified(verified: verified ?? false));
    } else if (state.status == EditProfileStatus.saved) {
      context.read<SessionCubit>().userUpdated(state.original);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileSaved)),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: _onStatus,
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: [
              Center(
                child: ProfileAvatar(
                  name: state.first,
                  photoPath: state.photoPath,
                  size: _avatarSize,
                  onTap: () => _showPhotoSheet(
                    context,
                    hasPhoto: state.photoPath != null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ..._fields(context, state),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                key: const Key('profile.save'),
                label: l10n.save,
                isLoading: state.isBusy,
                onPressed: state.canSave
                    ? () => context.read<EditProfileBloc>().add(
                        const ProfileSaveRequested(),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fields(BuildContext context, EditProfileState state) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<EditProfileBloc>();
    void changed(ProfileField f, String v) =>
        bloc.add(ProfileFieldChanged(f, v));
    void blurred(ProfileField f) => bloc.add(ProfileFieldBlurred(f));
    return [
      _Label(l10n.firstNameLabel),
      AppTextField(
        controller: _first,
        fieldKey: const Key('profile.first'),
        hint: l10n.firstNameHint,
        hasError: state.shows(ProfileField.first) && state.firstError != null,
        onChanged: (v) => changed(ProfileField.first, v),
        onFocusLost: () => blurred(ProfileField.first),
      ),
      NameErrorText(
        error: state.shows(ProfileField.first) ? state.firstError : null,
      ),
      const SizedBox(height: AppSpacing.md),
      _Label(l10n.lastNameLabel),
      AppTextField(
        controller: _last,
        fieldKey: const Key('profile.last'),
        hint: l10n.lastNameHint,
        hasError: state.shows(ProfileField.last) && state.lastError != null,
        onChanged: (v) => changed(ProfileField.last, v),
        onFocusLost: () => blurred(ProfileField.last),
      ),
      NameErrorText(
        error: state.shows(ProfileField.last) ? state.lastError : null,
      ),
      const SizedBox(height: AppSpacing.md),
      _Label(l10n.phoneNumberLabel),
      AppTextField(
        controller: _phone,
        fieldKey: const Key('profile.phone'),
        hint: l10n.phoneHint,
        prefixText: PhoneRules.countryCode,
        keyboardType: TextInputType.phone,
        hasError:
            (state.shows(ProfileField.phone) && state.phoneError != null) ||
            state.failure != null,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\s+-]')),
          LengthLimitingTextInputFormatter(_maxPhoneLength),
        ],
        onChanged: (v) => changed(ProfileField.phone, v),
        onFocusLost: () => blurred(ProfileField.phone),
      ),
      FieldErrorText(
        key: const Key('profile.phoneError'),
        message: _phoneMessage(l10n, state),
      ),
      if (state.phoneChanged && state.phoneError == null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(l10n.verifyNewNumber, style: context.text.bodySmall),
        ),
    ];
  }

  String? _phoneMessage(AppLocalizations l10n, EditProfileState state) {
    final failure = state.failure;
    if (failure is AuthFailure &&
        failure.reason == AuthFailureReason.phoneAlreadyRegistered) {
      return l10n.phoneAlreadyRegistered;
    }
    if (failure != null) return failure.message(l10n);
    if (!state.shows(ProfileField.phone)) return null;
    return switch (state.phoneError) {
      PhoneValidationError.empty => l10n.phoneRequired,
      PhoneValidationError.invalid => l10n.phoneInvalid,
      null => null,
    };
  }

  Future<void> _showPhotoSheet(
    BuildContext context, {
    required bool hasPhoto,
  }) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<EditProfileBloc>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(sheet, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(sheet, 'gallery'),
            ),
            if (hasPhoto)
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: context.colors.danger,
                ),
                title: Text(
                  l10n.removePhoto,
                  style: TextStyle(color: context.colors.danger),
                ),
                onTap: () => Navigator.pop(sheet, 'remove'),
              ),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'camera':
        bloc.add(const ProfilePhotoPicked(PhotoSource.camera));
      case 'gallery':
        bloc.add(const ProfilePhotoPicked(PhotoSource.gallery));
      case 'remove':
        bloc.add(const ProfilePhotoRemoved());
    }
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(text, style: context.text.titleSmall),
  );
}
