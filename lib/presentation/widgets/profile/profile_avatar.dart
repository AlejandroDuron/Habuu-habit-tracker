import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';

/// Avatar circular con las iniciales de [name]. Sin nombre, un ícono de
/// persona.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, this.size = 175});

  final String name;
  final double size;

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsOf(name);

    return Semantics(
      label: 'Foto de perfil',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: HabuuColors.primary0,
          shape: BoxShape.circle,
        ),
        child: initials.isEmpty
            ? Icon(
                Icons.person_rounded,
                size: size * 0.5,
                color: HabuuColors.primary500,
              )
            : Text(
                initials,
                style: HabuuText.h5ExtraBold.copyWith(
                  fontSize: size * 0.34,
                  height: 1,
                  color: HabuuColors.primary500,
                ),
              ),
      ),
    );
  }
}
