import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Simple screen for bottom-nav tabs that are out of scope (Scan, Wallet).
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.title, this.icon, super.key});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
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
                AppLocalizations.of(context).placeholderScreen(title),
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
