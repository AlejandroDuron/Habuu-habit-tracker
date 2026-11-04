import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/tokens.dart';

/// Etiqueta arriba y el campo abajo, como todos los datos del perfil.
class ProfileFieldFrame extends StatelessWidget {
  const ProfileFieldFrame({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: HabuuText.subtitleSmMedium.copyWith(
            color: HabuuTextColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Texto que escribe el usuario. Los campos que no se pueden editar usan
/// el gris de [profileReadOnlyTextStyle].
TextStyle get profileFieldTextStyle =>
    HabuuText.bodyLgRegular.copyWith(color: HabuuTextColors.primaryBlack);

TextStyle get profileReadOnlyTextStyle =>
    HabuuText.bodyLgRegular.copyWith(color: HabuuTextColors.tertiaryGrey);

InputDecoration profileInputDecoration({
  String? hint,
  String? leadingIcon,
  String? trailingIcon,
  String? errorText,
}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: HabuuColors.grey0,
    hintText: hint,
    hintStyle: HabuuText.bodyLgRegular.copyWith(color: HabuuColors.grey400),
    contentPadding: const EdgeInsets.all(12),
    prefixIcon: leadingIcon == null ? null : _FieldIcon(leadingIcon),
    prefixIconConstraints: _iconConstraints,
    suffixIcon: trailingIcon == null ? null : _FieldIcon(trailingIcon),
    suffixIconConstraints: _iconConstraints,
    errorText: errorText,
    errorStyle: HabuuText.captionMdMedium.copyWith(color: HabuuColors.error600),
    errorMaxLines: 2,
    enabledBorder: _border(HabuuColors.grey200),
    disabledBorder: _border(HabuuColors.grey200),
    focusedBorder: _border(HabuuColors.primary500),
    errorBorder: _border(HabuuColors.error500),
    focusedErrorBorder: _border(HabuuColors.error500),
  );
}

const _iconConstraints = BoxConstraints(minWidth: 48, minHeight: 24);

OutlineInputBorder _border(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(HabuuRadius.sm),
  borderSide: BorderSide(color: color, width: 1.5),
);

class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SvgPicture.asset(asset, width: 24, height: 24),
    );
  }
}
