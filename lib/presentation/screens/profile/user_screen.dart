import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../models/profile/user_profile.dart';
import '../../widgets/profile/back_title_header.dart';
import '../../widgets/profile/pond_scroll_view.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/profile_info_field.dart';

/// Datos personales del usuario, por ahora solo de lectura.
class UserScreen extends StatelessWidget {
  const UserScreen({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return PondScrollView(
      children: [
        BackTitleHeader(
          title: 'Usuario',
          onBack: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 31),
        Center(child: ProfileAvatar(asset: user.avatarAsset)),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 32,
            children: [
              ProfileInfoField(label: 'Nombre Completo', value: user.fullName),
              ProfileInfoField(
                label: 'Email',
                value: user.email,
                leadingIcon: ProfileAssets.mail,
              ),
              ProfileInfoField(
                label: 'Teléfono',
                value: user.phone,
                leadingIcon: ProfileAssets.phone,
              ),
              ProfileInfoField(
                label: 'Género',
                value: user.gender,
                trailingIcon: ProfileAssets.arrowDown,
              ),
              ProfileInfoField(
                label: 'Cumpleaños',
                value: user.birthday,
                trailingIcon: ProfileAssets.calendar,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
