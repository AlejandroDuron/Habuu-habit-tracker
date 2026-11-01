import 'package:flutter/material.dart';
import '../../screens/habits/habits_list_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/streaks/streaks_screen.dart';
import '../../widgets/shared/navbar.dart';
 
class HabuuShell extends StatefulWidget {
  const HabuuShell({super.key});
 
  @override
  State<HabuuShell> createState() => _HabuuShellState();
}
 
class _HabuuShellState extends State<HabuuShell> {
  HabuuTab _selectedTab = HabuuTab.home;
 
  final _streaksNavKey = GlobalKey<NavigatorState>();

  final _addNavKey = GlobalKey<NavigatorState>();
 
  late final List<Widget> _pages = [
    const HomePage(),
    Navigator(
      key: _streaksNavKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const StreakScreen(),
      ),
    ),
    Navigator(
      key: _addNavKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const HabitsListScreen(),
      ),
    ),
    const Center(child: Text('Perfil')),
  ];


  void _onTabSelected(HabuuTab tab) {
    // Si toca la pestaña activa, vuelve a la raíz de esa pestaña
    if (tab == _selectedTab) {
      if (tab == HabuuTab.calendar) {
        _streaksNavKey.currentState?.popUntil((r) => r.isFirst);
      }
      if (tab == HabuuTab.add) {
        _addNavKey.currentState?.popUntil((r) => r.isFirst);
      }
      return;
    }
 
    setState(() => _selectedTab = tab);
  }
 
  /// Navigator de la pestaña que se está viendo, si tiene uno propio
  NavigatorState? get _currentTabNav => switch (_selectedTab) {
        HabuuTab.calendar => _streaksNavKey.currentState,
        HabuuTab.add => _addNavKey.currentState,
        _ => null,
      };
 
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