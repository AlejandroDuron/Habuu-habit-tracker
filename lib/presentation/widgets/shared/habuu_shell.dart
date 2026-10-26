import 'package:flutter/material.dart';
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

  late final List<Widget> _pages = [
    const HomePage(),
    Navigator(
      key: _streaksNavKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const StreakScreen(),
      ),
    ),
    const Center(child: Text('Agregar')),
    const Center(child: Text('Perfil')),
  ];

  void _onTabSelected(HabuuTab tab) {
    // Si toca la pestaña activa, vuelve a la raíz de esa pestaña
    if (tab == _selectedTab) {
      if (tab == HabuuTab.calendar) {
        _streaksNavKey.currentState?.popUntil((r) => r.isFirst);
      }
      return;
    }

    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Que el botón/gesto "atrás" cierre primero TrophiesScreen
      // y no salga de toda la app
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _streaksNavKey.currentState;
        if (_selectedTab == HabuuTab.calendar && (nav?.canPop() ?? false)) {
          nav!.pop();
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