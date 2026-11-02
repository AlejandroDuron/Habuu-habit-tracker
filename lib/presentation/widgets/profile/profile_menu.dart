import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../models/profile/profile_menu_entry.dart';

/// Menú de opciones del perfil. Cada grupo es un bloque blanco;
/// juntos forman una sola tarjeta con las esquinas de arriba y abajo redondeadas.
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key, required this.groups});

  final List<List<ProfileMenuEntry>> groups;

  static const _radius = Radius.circular(HabuuRadius.sm);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(_radius),
        boxShadow: habuuElevation500,
      ),
      child: Column(
        children: [
          for (var i = 0; i < groups.length; i++)
            _MenuGroup(
              entries: groups[i],
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? _radius : Radius.zero,
                bottom: i == groups.length - 1 ? _radius : Radius.zero,
              ),
              // El grupo de arriba proyecta sombra sobre el siguiente
              elevated: i < groups.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({
    required this.entries,
    required this.borderRadius,
    required this.elevated,
  });

  final List<ProfileMenuEntry> entries;
  final BorderRadius borderRadius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: borderRadius,
        boxShadow: elevated ? habuuElevation100 : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          spacing: 8,
          children: [for (final entry in entries) _MenuTile(entry: entry)],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.entry});

  final ProfileMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.isDestructive
        ? HabuuTextColors.error
        : HabuuTextColors.primaryBlack;

    return InkWell(
      onTap: entry.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          children: [
            SvgPicture.asset(entry.icon, width: 24, height: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.label,
                style: HabuuText.bodyLgRegular.copyWith(color: color),
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              entry.isDestructive
                  ? ProfileAssets.arrowRightError
                  : ProfileAssets.arrowRight,
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
