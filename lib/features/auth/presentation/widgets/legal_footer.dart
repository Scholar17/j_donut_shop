import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "By continuing, you acknowledge… Terms of Use and Privacy Policy."
class LegalFooter extends StatefulWidget {
  const LegalFooter({super.key});

  @override
  State<LegalFooter> createState() => _LegalFooterState();
}

class _LegalFooterState extends State<LegalFooter> {
  final _terms = TapGestureRecognizer();
  final _privacy = TapGestureRecognizer();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = context.text.bodySmall?.copyWith(
      color: context.colors.textHint,
    );
    final link = base?.copyWith(color: context.colors.accent);
    _terms.onTap = () => showComingSoon(context, l10n.termsOfUse);
    _privacy.onTap = () => showComingSoon(context, l10n.privacyPolicy);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: l10n.legalPrefix),
            TextSpan(text: l10n.termsOfUse, style: link, recognizer: _terms),
            TextSpan(text: l10n.and),
            TextSpan(
              text: l10n.privacyPolicy,
              style: link,
              recognizer: _privacy,
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
