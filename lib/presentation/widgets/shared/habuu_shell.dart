import 'package:flutter/material.dart';
import '../../screens/habits/habits_list_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/streaks/streaks_screen.dart';
import '../../widgets/shared/navbar.dart';
 
class HabuuShell extends StatefulWidget {
  const HabuuShell({super.key});
 
  @override
  State<HabuuShell> createState() => _HabuuShellState();
}
 
class _HabuuShellState extends State<HabuuShell> {
  HabuuTab _selectedTab = HabuuTab.home;
 
  /// Pestañas con navegación propia, para abrir pantallas sin perder la barra
  final _navKeys = {
    HabuuTab.calendar: GlobalKey<NavigatorState>(),
    HabuuTab.add: GlobalKey<NavigatorState>(),
    HabuuTab.profile: GlobalKey<NavigatorState>(),
  };

  late final List<Widget> _pages = [
    const HomePage(),
    _tabNavigator(HabuuTab.calendar, const StreakScreen()),
    _tabNavigator(HabuuTab.add, const HabitsListScreen()),
    _tabNavigator(
      HabuuTab.profile,
      ProfileScreen(onGoToPond: () => _onTabSelected(HabuuTab.home)),
    ),
  ];

  Widget _tabNavigator(HabuuTab tab, Widget root) => Navigator(
        key: _navKeys[tab],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => root),
      );

  void _onTabSelected(HabuuTab tab) {
    // Si toca la pestaña activa, vuelve a la raíz de esa pestaña
    if (tab == _selectedTab) {
      _navKeys[tab]?.currentState?.popUntil((r) => r.isFirst);
      return;
    }

    setState(() => _selectedTab = tab);
  }

  /// Navigator de la pestaña que se está viendo, si tiene uno propio
  NavigatorState? get _currentTabNav => _navKeys[_selectedTab]?.currentState;
 
  @override
  Widget build(BuildContext context) {
    return PopScope(

      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _currentTabNav;
        if (nav != null && nav.canPop()) {
          nav.pop();
        }
      },
      child: Scaffold(
        extendBody: false,
        body: IndexedStack(
          index: _selectedTab.index,
          children: _pages,
        ),
        bottomNavigationBar: HabuuNavbar(
          selected: _selectedTab,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}