import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

class HabitsListHeader extends StatelessWidget {
  const HabitsListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Center(
        child: Text(
          'Tus Hábitos',
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold.copyWith(
            color: HabuuTextColors.accent,
          ),
        ),
      ),
    );
  }
}
