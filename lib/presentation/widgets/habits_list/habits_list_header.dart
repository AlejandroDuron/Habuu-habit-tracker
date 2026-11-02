import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

class HabitsListHeader extends StatelessWidget {
  const HabitsListHeader({super.key, this.onMore});

  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Tus Hábitos',
            textAlign: TextAlign.center,
            style: HabuuText.h5ExtraBold.copyWith(
              color: HabuuTextColors.accent,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onMore,
              behavior: HitTestBehavior.opaque,
              child: Semantics(
                label: 'Más opciones',
                button: true,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    size: 28,
                    color: HabuuIconColors.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}