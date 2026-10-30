import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';

/// Ícono + de las tarjetas.
class AddIcon extends StatelessWidget {
  const AddIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -0.75,
            top: -1.75,
            child: SvgPicture.asset(HomeAssets.add, width: 19.5, height: 19.75),
          ),
        ],
      ),
    );
  }
}
