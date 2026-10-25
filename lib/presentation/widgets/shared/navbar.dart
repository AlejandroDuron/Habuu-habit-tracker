
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/tokens.dart';

enum HabuuTab {
  home('home', 'Inicio'),
  calendar('calendar', 'Calendario'),
  add('plus', 'Agregar'),
  profile('profile', 'Perfil');

  const HabuuTab(this.icon, this.label);

  final String icon;
  final String label;
}

class HabuuNavbar extends StatelessWidget {
  const HabuuNavbar({
    super.key,
    required this.selected,
    required this.onTabSelected,
  });

  final HabuuTab selected;
  final ValueChanged<HabuuTab> onTabSelected;

  static const double height = 69;

  static double bodyBottomInsetOf(BuildContext context) =>
      75 + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      height: height + bottomInset,
      padding: EdgeInsets.fromLTRB(
        36,
        8,
        36,
        8 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: HabuuColors.white80,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final tab in HabuuTab.values)
            Expanded(
              child: _NavbarItem(
                tab: tab,
                isSelected: tab == selected,
                onTap: () => onTabSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavbarItem extends StatelessWidget {
  const _NavbarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final HabuuTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 52,
          child: Column(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected
                      ? HabuuColors.primary500
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/navbar/${tab.icon}.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
