import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_error_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/validators/phone_validator.dart';
import '../bloc/auth_flow_cubit.dart';
import '../bloc/phone_bloc.dart';
import '../widgets/auth_step_scaffold.dart';

/// Screen 2: phone number (step 1 of 4).
class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  late final _controller = TextEditingController(
    text: context.read<PhoneBloc>().state.raw,
  );

  static const _maxInputLength = 16;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, PhoneState state) {
    context.read<AuthFlowCubit>()
      ..phoneChanged(state.raw)
      ..otpSent(state.sentTo!);
    context.push(AppRoutes.otp(context.read<PhoneBloc>().mode));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<PhoneBloc, PhoneState>(
      listenWhen: (prev, next) =>
          prev.status != next.status && next.status == SubmitStatus.success,
      listener: _onStateChanged,
      builder: (context, state) => AuthStepScaffold(
        step: 1,
        title: l10n.phoneTitle,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _controller,
              fieldKey: const Key('phone.field'),
              hint: l10n.phoneHint,
              prefixText: PhoneRules.countryCode,
              hasError: state.visibleError != null || state.failure != null,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s+-]')),
                LengthLimitingTextInputFormatter(_maxInputLength),
              ],
              autofocus: true,
              onChanged: (raw) =>
                  context.read<PhoneBloc>().add(PhoneChanged(raw)),
              onFocusLost: () =>
                  context.read<PhoneBloc>().add(const PhoneFocusLost()),
              onSubmitted: (_) =>
                  context.read<PhoneBloc>().add(const PhoneSubmitted()),
            ),
            _PhoneError(state: state),
          ],
        ),
        action: PrimaryButton(
          key: const Key('phone.continue'),
          label: l10n.continueLabel,
          isLoading: state.status == SubmitStatus.submitting,
          onPressed: state.canSubmit
              ? () => context.read<PhoneBloc>().add(const PhoneSubmitted())
              : null,
        ),
      ),
    );
  }
}

class _PhoneError extends StatelessWidget {
  const _PhoneError({required this.state});
  final PhoneState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.failure;
    if (failure is AuthFailure) return _switchFlowLink(context, failure.reason);
    if (failure != null) return FieldErrorText(message: failure.message(l10n));
    return FieldErrorText(
      message: switch (state.visibleError) {
        PhoneValidationError.empty => l10n.phoneRequired,
        PhoneValidationError.invalid => l10n.phoneInvalid,
        null => null,
      },
    );
  }

  /// "Not registered → Register instead" / "Already registered → Log in instead".
  /// Replaces the current flow and carries the typed number across.
  Widget _switchFlowLink(BuildContext context, AuthFailureReason reason) {
    final l10n = AppLocalizations.of(context);
    final toRegister = reason == AuthFailureReason.phoneNotRegistered;
    final target = toRegister ? AuthMode.register : AuthMode.login;
    return FieldErrorText(
      key: const Key('phone.switchFlow'),
      message: toRegister
          ? l10n.phoneNotRegistered
          : l10n.phoneAlreadyRegistered,
      actionLabel: toRegister ? l10n.registerInstead : l10n.logInInstead,
      onAction: () =>
          context.pushReplacement(AppRoutes.phone(target), extra: state.raw),
    );
  }
}
