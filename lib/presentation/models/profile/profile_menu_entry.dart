import 'package:flutter/foundation.dart';

/// Una fila del menú de perfil.
/// [isDestructive] la pinta en rojo, como "Cerrar sesión".
class ProfileMenuEntry {
  const ProfileMenuEntry({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;
}
