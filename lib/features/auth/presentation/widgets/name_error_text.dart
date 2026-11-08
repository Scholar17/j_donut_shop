import 'package:flutter/widgets.dart';

import '../../../../core/widgets/field_error_text.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/validators/name_validator.dart';

/// Localized inline message for a [NameValidationError].
class NameErrorText extends StatelessWidget {
  const NameErrorText({required this.error, super.key});
  final NameValidationError? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FieldErrorText(
      message: switch (error) {
        NameValidationError.required => l10n.nameRequired,
        NameValidationError.tooLong => l10n.nameTooLong(NameRules.maxLength),
        NameValidationError.invalidCharacters => l10n.nameInvalidCharacters,
        null => null,
      },
    );
  }
}
