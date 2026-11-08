import 'package:flutter/widgets.dart';

/// Tabs of the main shell, in bottom-nav order.
enum MainTab { home, rewards, scan, wallet, settings }

/// Exposes the visible tab so pages kept alive by the indexed stack can
/// replay their entrance when they become visible again.
class ActiveTab extends InheritedWidget {
  const ActiveTab({required this.tab, required super.child, super.key});

  final MainTab tab;

  static MainTab? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActiveTab>()?.tab;

  @override
  bool updateShouldNotify(ActiveTab old) => old.tab != tab;
}
