import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';

/// Título de pantalla con flecha para regresar a la izquierda.
class BackTitleHeader extends StatelessWidget {
  const BackTitleHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Volver',
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SvgPicture.asset(
                ProfileAssets.back,
                width: 32,
                height: 32,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: HabuuText.h5ExtraBold.copyWith(
                color: HabuuTextColors.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
