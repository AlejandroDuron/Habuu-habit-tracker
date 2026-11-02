import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/tokens.dart';

/// Etiqueta + caja de solo lectura con un dato del usuario.
/// Los íconos son opcionales: [leadingIcon] va antes del texto y [trailingIcon] al final.
class ProfileInfoField extends StatelessWidget {
  const ProfileInfoField({
    super.key,
    required this.label,
    required this.value,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final String? leadingIcon;
  final String? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HabuuText.subtitleSmMedium.copyWith(
            color: HabuuTextColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HabuuColors.grey0,
            borderRadius: BorderRadius.circular(HabuuRadius.sm),
            border: Border.all(color: HabuuColors.grey200, width: 1.5),
          ),
          child: Row(
            spacing: 12,
            children: [
              if (leadingIcon != null) _icon(leadingIcon!),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HabuuText.bodyLgRegular.copyWith(
                    color: HabuuTextColors.tertiaryGrey,
                  ),
                ),
              ),
              if (trailingIcon != null) _icon(trailingIcon!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _icon(String asset) => SvgPicture.asset(asset, width: 24, height: 24);
}
