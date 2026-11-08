import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/field_error_text.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/otp_outcome.dart';
import '../bloc/otp_bloc.dart';
import '../bloc/session_cubit.dart';
import '../widgets/auth_step_scaffold.dart';
import '../widgets/otp_code_input.dart';

/// Screen 3: verify number (step 2 of 4).
class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  void _onVerified(BuildContext context, OtpState state) {
    switch (state.outcome!) {
      // Log in: the router guard sees the session and opens Home.
      case SignedIn(:final user):
        context.read<SessionCubit>().signedIn(user);
      case PhoneVerified():
        context.push(AppRoutes.name());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<OtpBloc, OtpState>(
      listenWhen: (prev, next) =>
          prev.status != next.status && next.status == OtpStatus.verified,
      listener: _onVerified,
      builder: (context, state) => AuthStepScaffold(
        step: 2,
        title: l10n.otpTitle,
        subtitle: l10n.otpSentTo(state.phone),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OtpCodeInput(
              code: state.code,
              shakeCount: state.shakeCount,
              enabled: state.acceptsInput,
              hasError: state.failure != null,
              onChanged: (code) =>
                  context.read<OtpBloc>().add(OtpCodeChanged(code)),
            ),
            _OtpMessage(state: state),
            const SizedBox(height: AppSpacing.lg),
            _ResendRow(state: state),
          ],
        ),
      ),
    );
  }
}

class _OtpMessage extends StatelessWidget {
  const _OtpMessage({required this.state});
  final OtpState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == OtpStatus.verifying) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: LinearProgressIndicator(
          color: context.colors.accent,
          backgroundColor: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      );
    }
    return FieldErrorText(
      key: const Key('otp.error'),
      message: _message(context),
    );
  }

  String? _message(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.isLocked) return l10n.otpLocked;
    final failure = state.failure;
    if (failure == null) return null;
    final isWrongCode =
        failure is AuthFailure &&
        failure.reason == AuthFailureReason.invalidOtp;
    return isWrongCode
        ? l10n.otpWrong(state.attemptsLeft)
        : failure.message(l10n);
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.state});
  final OtpState state;

  static String _format(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = context.text.bodyMedium?.copyWith(
      color: context.colors.accent,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.otpDidNotReceive, style: context.text.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        AnimatedSwitcher(
          duration: AppDurations.fast,
          child: state.canResend
              ? PressableScale(
                  key: const Key('otp.resend'),
                  onTap: () =>
                      context.read<OtpBloc>().add(const OtpResendPressed()),
                  child: Text(
                    l10n.otpResend,
                    style: accent?.copyWith(fontWeight: FontWeight.w700),
                  ),
                )
              : Text.rich(
                  key: const Key('otp.countdown'),
                  _countdownSpan(l10n, _format(state.secondsLeft), accent),
                  style: context.text.bodyMedium,
                ),
        ),
      ],
    );
  }

  /// Highlights only the time inside the localized "resend in {time} min".
  TextSpan _countdownSpan(
    AppLocalizations l10n,
    String time,
    TextStyle? accent,
  ) {
    final parts = l10n.otpResendIn(time).split(time);
    return TextSpan(
      children: [
        TextSpan(text: parts.first),
        TextSpan(text: time, style: accent),
        if (parts.length > 1) TextSpan(text: parts.last),
      ],
    );
  }
}
