import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_error_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/validators/date_of_birth_validator.dart';
import '../bloc/auth_flow_cubit.dart';
import '../bloc/dob_bloc.dart';
import '../bloc/session_cubit.dart';
import '../bloc/submit_status.dart';
import '../widgets/auth_step_scaffold.dart';
import '../widgets/month_picker_field.dart';

/// Screen 6: date of birth (step 4 of 4; the ring morphs into a check).
class DobPage extends StatefulWidget {
  const DobPage({super.key});

  @override
  State<DobPage> createState() => _DobPageState();
}

class _DobPageState extends State<DobPage> {
  late final DobState _initial = context.read<DobBloc>().state;
  late final _day = TextEditingController(text: _initial.day?.toString() ?? '');
  late final _year = TextEditingController(
    text: _initial.year?.toString() ?? '',
  );

  static const _dayDigits = 2;
  static const _yearDigits = 4;

  @override
  void dispose() {
    _day.dispose();
    _year.dispose();
    super.dispose();
  }

  void _changed({int? month}) {
    final state = context.read<DobBloc>().state;
    final next = DobChanged(
      month: month ?? state.month,
      day: int.tryParse(_day.text),
      year: int.tryParse(_year.text),
    );
    context.read<AuthFlowCubit>().dateOfBirthChanged(
      month: next.month,
      day: next.day,
      year: next.year,
    );
    context.read<DobBloc>().add(next);
  }

  void _submit() {
    final draft = context.read<AuthFlowCubit>().state;
    context.read<DobBloc>().add(
      DobSubmitted(
        phone: draft.verifiedPhone ?? '',
        firstName: draft.firstName,
        lastName: draft.lastName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<DobBloc, DobState>(
      listenWhen: (prev, next) =>
          prev.status != next.status && next.status == SubmitStatus.success,
      // The guard sees a new user and opens Welcome.
      listener: (context, state) =>
          context.read<SessionCubit>().signedIn(state.user!, isNewUser: true),
      builder: (context, state) => AuthStepScaffold(
        step: 4,
        title: l10n.dobTitle,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonthPickerField(
              month: state.month,
              hint: l10n.monthHint,
              hasError: state.visibleError != null,
              onChanged: (month) => _changed(month: month),
            ),
            const SizedBox(height: AppSpacing.md),
            _numberField(
              _day,
              l10n.dayHint,
              _dayDigits,
              const Key('dob.day'),
              state,
            ),
            const SizedBox(height: AppSpacing.md),
            _numberField(
              _year,
              l10n.yearHint,
              _yearDigits,
              const Key('dob.year'),
              state,
            ),
            FieldErrorText(
              key: const Key('dob.error'),
              message: _message(l10n, state),
            ),
          ],
        ),
        action: PrimaryButton(
          key: const Key('dob.continue'),
          label: l10n.continueLabel,
          isLoading: state.status == SubmitStatus.submitting,
          onPressed: state.canSubmit ? _submit : null,
        ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String hint,
    int digits,
    Key key,
    DobState state,
  ) => AppTextField(
    controller: controller,
    fieldKey: key,
    hint: hint,
    hasError: state.visibleError != null,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(digits),
    ],
    onChanged: (_) => _changed(),
  );

  String? _message(AppLocalizations l10n, DobState state) {
    if (state.failure != null) return state.failure!.message(l10n);
    return switch (state.visibleError) {
      DateOfBirthError.invalidDate => l10n.dobInvalidDate,
      DateOfBirthError.inFuture => l10n.dobInFuture,
      DateOfBirthError.tooYoung => l10n.dobTooYoung(
        DateOfBirthRules.minimumAge,
      ),
      DateOfBirthError.incomplete || null => null,
    };
  }
}
