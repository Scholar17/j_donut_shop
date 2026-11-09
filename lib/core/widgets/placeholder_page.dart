import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Simple screen for bottom-nav tabs that are out of scope (Order, Wallet).
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    this.icon,
    this.message,
    super.key,
  });

  final String title;
  final IconData? icon;

  /// Replaces the default "coming soon" line.
  final String Function(AppLocalizations l10n)? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.construction_rounded,
                size: AppSpacing.xxl,
                color: context.colors.accent,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message?.call(l10n) ?? l10n.placeholderScreen(title),
                style: context.text.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
