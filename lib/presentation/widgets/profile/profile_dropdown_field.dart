import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import 'profile_field_style.dart';

/// Lista desplegable del perfil. [labelOf] dice qué texto mostrar por
/// opción, así sirve para cualquier enum.
class ProfileDropdownField<T> extends StatelessWidget {
  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.labelOf,
    required this.value,
    required this.onChanged,
    this.hint = 'Selecciona una opción',
  });

  final String label;
  final List<T> options;
  final String Function(T option) labelOf;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ProfileFieldFrame(
      label: label,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        onChanged: onChanged,
        isExpanded: true,
        hint: Text(
          hint,
          style: HabuuText.bodyLgRegular.copyWith(color: HabuuColors.grey400),
        ),
        icon: SvgPicture.asset(ProfileAssets.arrowDown, width: 24, height: 24),
        style: profileFieldTextStyle,
        dropdownColor: HabuuColors.white100,
        borderRadius: BorderRadius.circular(HabuuRadius.sm),
        decoration: profileInputDecoration(),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(labelOf(option))),
        ],
      ),
    );
  }
}
