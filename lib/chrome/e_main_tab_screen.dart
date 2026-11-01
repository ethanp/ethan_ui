import 'package:flutter/material.dart';

import 'e_scaffold_shell.dart';
import 'e_tab_bar.dart';

/// One bottom tab: its [ETabBar] entry and the root [screen] of its stack.
class const EMainTab({
  required final IconData icon,
  required final String label,
  required final Widget screen,
});

/// An app's main tabs: an [ETabBar] over one navigation stack per tab, so
/// each tab keeps its pushed routes while another is showing. Reselecting
/// the current tab pops its stack to the root. [wrapTabScreen] decorates
/// every tab's root screen, e.g. with an app-wide banner.
class const EMainTabScreen({
  super.key,
  required final List<EMainTab> tabs,
  final Widget Function(Widget screen)? wrapTabScreen,
}) extends StatefulWidget {
  @override
  State<EMainTabScreen> createState() => _EMainTabScreenState();
}

class _EMainTabScreenState() extends State<EMainTabScreen> {
  int _selectedTabIndex = 0;
  late final List<GlobalKey<NavigatorState>> _tabNavigatorKeys =
      List.generate(widget.tabs.length, (_) => GlobalKey<NavigatorState>());

  @override
  Widget build(BuildContext context) {
    return EScaffoldShell(
      contentMaxWidth: double.infinity,
      bottomBar: ETabBar(
        selectedIndex: _selectedTabIndex,
        tabs: [
          for (final tab in widget.tabs) ETab(icon: tab.icon, label: tab.label),
        ],
        onSelected: _showTabOrPopItToRoot,
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          for (var tabIndex = 0; tabIndex < widget.tabs.length; tabIndex++)
            _tabStack(tabIndex),
        ],
      ),
    );
  }

  void _showTabOrPopItToRoot(int index) {
    if (index == _selectedTabIndex) {
      _tabNavigatorKeys[index].currentState?.popUntil(
        (route) => route.isFirst,
      );
      return;
    }
    setState(() => _selectedTabIndex = index);
  }

  Widget _tabStack(int tabIndex) {
    final Widget screen = widget.tabs[tabIndex].screen;
    return Navigator(
      key: _tabNavigatorKeys[tabIndex],
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => widget.wrapTabScreen?.call(screen) ?? screen,
      ),
    );
  }
}
