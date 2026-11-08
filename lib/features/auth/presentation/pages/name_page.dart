import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/auth_flow_cubit.dart';
import '../bloc/name_cubit.dart';
import '../widgets/auth_step_scaffold.dart';
import '../widgets/name_error_text.dart';

/// Screens 4–5: first and last name (step 3 of 4).
class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  late final _first = TextEditingController(
    text: context.read<NameCubit>().state.first,
  );
  late final _last = TextEditingController(
    text: context.read<NameCubit>().state.last,
  );

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _continue(NameState state) {
    context.read<AuthFlowCubit>().nameChanged(
      first: state.first,
      last: state.last,
    );
    context.push(AppRoutes.dob());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<NameCubit>();
    return BlocBuilder<NameCubit, NameState>(
      builder: (context, state) => AuthStepScaffold(
        step: 3,
        title: l10n.nameTitle,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _first,
              fieldKey: const Key('name.first'),
              hint: l10n.firstNameHint,
              hasError: state.visibleFirstError != null,
              autofocus: true,
              autofillHints: const [AutofillHints.givenName],
              textInputAction: TextInputAction.next,
              onChanged: cubit.firstChanged,
              onFocusLost: cubit.firstBlurred,
            ),
            NameErrorText(error: state.visibleFirstError),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _last,
              fieldKey: const Key('name.last'),
              hint: l10n.lastNameHint,
              hasError: state.visibleLastError != null,
              autofillHints: const [AutofillHints.familyName],
              textInputAction: TextInputAction.done,
              onChanged: cubit.lastChanged,
              onFocusLost: cubit.lastBlurred,
            ),
            NameErrorText(error: state.visibleLastError),
          ],
        ),
        action: PrimaryButton(
          key: const Key('name.continue'),
          label: l10n.continueLabel,
          onPressed: state.isValid ? () => _continue(state) : null,
        ),
      ),
    );
  }
}
