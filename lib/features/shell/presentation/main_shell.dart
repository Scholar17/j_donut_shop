import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Hosts the five bottom-nav tabs; each keeps its own navigation stack.
class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    this.showNavigation = true,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool showNavigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: !showNavigation
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: l10n.navReward,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: l10n.navScan,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: l10n.navWallet,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  label: l10n.navSettings,
                ),
              ],
            ),
    );
  }
}
