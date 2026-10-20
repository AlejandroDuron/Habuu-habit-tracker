import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/habuu_tokens.dart';

/// Pestañas de la barra de navegación inferior, en orden de aparición.
enum HabuuTab {
  home('home'),
  calendar('calendar'),
  add('plus'),
  profile('profile');

  const HabuuTab(this.icon);

  final String icon;
}

/// Barra de navegación inferior de Habuu.
///
/// Debe usarse como `bottomNavigationBar` de un [Scaffold] con `extendBody: true`
/// para que el fondo de la pantalla se vea detrás de la barra translúcida.
/// El contenido debe dejar [HabuuNavbar.bodyBottomInsetOf] libre abajo.
class HabuuNavbar extends StatelessWidget {
  const HabuuNavbar({super.key, required this.selected, this.onTabSelected});

  /// Pestaña marcada con el indicador superior.
  final HabuuTab selected;

  final ValueChanged<HabuuTab>? onTabSelected;

  static const double height = 69;

  /// Espacio que el contenido debe dejar libre abajo para no quedar detrás
  /// de la barra: 75px como en Figma, más el área del sistema si existe.
  static double bodyBottomInsetOf(BuildContext context) =>
      75 + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      height: height + bottomInset,
      padding: EdgeInsets.fromLTRB(36, 8, 36, 8 + bottomInset),
      decoration: const BoxDecoration(
        color: HabuuColors.white80,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final tab in HabuuTab.values)
            Expanded(
              child: _NavbarItem(
                tab: tab,
                isSelected: tab == selected,
                onTap: onTabSelected == null ? null : () => onTabSelected!(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavbarItem extends StatelessWidget {
  const _NavbarItem({required this.tab, required this.isSelected, this.onTap});

  final HabuuTab tab;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 4,
            color: isSelected ? HabuuColors.primary500 : Colors.transparent,
          ),
          SizedBox(
            height: 44,
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
    );
  }
}
