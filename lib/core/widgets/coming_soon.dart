import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Placeholder feedback for integrations that are out of scope
/// (Google/Apple/Facebook sign-in, Terms, Privacy).
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).comingSoon(feature))),
    );
}
