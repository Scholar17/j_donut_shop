import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'active_tab.dart';
import 'jd_bottom_nav.dart';

/// Hosts the five tabs (each keeps its own stack) and the sliding-pill nav.
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
    final index = navigationShell.currentIndex;
    return Scaffold(
      extendBody: true,
      body: ActiveTab(tab: MainTab.values[index], child: navigationShell),
      bottomNavigationBar: !showNavigation
          ? null
          : JdBottomNav(
              currentIndex: index,
              onSelected: (i) =>
                  navigationShell.goBranch(i, initialLocation: i == index),
              items: [
                JdNavItem(icon: Icons.home_outlined, label: l10n.navHome),
                JdNavItem(
                  icon: Icons.emoji_events_outlined,
                  label: l10n.navReward,
                ),
                JdNavItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: l10n.navScan,
                ),
                JdNavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.navWallet,
                ),
                JdNavItem(
                  icon: Icons.settings_outlined,
                  label: l10n.navSettings,
                ),
              ],
            ),
    );
  }
}
