import 'package:flutter/material.dart';

/// Foto de perfil circular.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.asset, this.size = 175});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'Foto de perfil',
      ),
    );
  }
}
