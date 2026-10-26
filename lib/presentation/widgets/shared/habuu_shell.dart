
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

  late final List<Widget> _pages = [
    const HomePage(),
    const StreakScreen(),
    const Center(child: Text('Agregar')),
    const Center(child: Text('Perfil')),
  ];

  void _onTabSelected(HabuuTab tab) {
    if (tab == _selectedTab) return;

    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _selectedTab.index,
        children: _pages,
      ),
      bottomNavigationBar: HabuuNavbar(
        selected: _selectedTab,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
