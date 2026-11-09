import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'active_tab.dart';
import 'donut_outline_icon.dart';
import 'jd_bottom_nav.dart';

/// Hosts the five tabs (each keeps its own stack) and the pill nav.
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
              upperBandColor: _upperBandColor(context, MainTab.values[index]),
              onSelected: (i) =>
                  navigationShell.goBranch(i, initialLocation: i == index),
              items: [
                JdNavItem(icon: Icons.home_outlined, label: l10n.navHome),
                JdNavItem(
                  icon: Icons.emoji_events_outlined,
                  label: l10n.navReward,
                ),
                JdNavItem(
                  iconBuilder: (color) => DonutOutlineIcon(color: color),
                  label: l10n.navOrder,
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

  /// Band beside the nav bar's upper half: grey on Home and Rewards, white
  /// elsewhere.
  static Color _upperBandColor(BuildContext context, MainTab tab) =>
      switch (tab) {
        MainTab.home || MainTab.rewards => context.colors.surfaceMuted,
        MainTab.order ||
        MainTab.wallet ||
        MainTab.settings => context.colors.surface,
      };
}
