import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../../utils/habit_style.dart';
import '../../models/habits_list/weekly_habit_data.dart';

class WeekDayCircle extends StatelessWidget {
  const WeekDayCircle({
    super.key,
    required this.label,
    required this.fullLabel,
    required this.state,
    required this.color,
  });

  final String label;
  final String fullLabel;
  final WeekDayState state;
  final Color color;

  static const double _maxSize = 40;
  static const double _borderWidth = 2;
  static const double _checkSize = 16;

  String get _stateLabel => switch (state) {
    WeekDayState.done => 'completado',
    WeekDayState.skipped => 'omitido',
    WeekDayState.empty => 'sin registro',
  };

  @override
  Widget build(BuildContext context) {
    final (fill, border) = switch (state) {
      WeekDayState.done => (color, readableOnWhite(color)),
      WeekDayState.skipped => (HabuuColors.error300, HabuuColors.grey150),
      WeekDayState.empty => (HabuuColors.grey150, HabuuColors.grey200),
    };

    return Semantics(
      label: '$fullLabel: $_stateLabel',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: HabuuText.captionMdMedium.copyWith(
              fontSize: 11,
              height: 1.2,
              fontWeight: HabuuWeight.regular,
              color: HabuuColors.grey500,
            ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxSize),
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: _borderWidth),
                ),
                child: state == WeekDayState.empty
                    ? null
                    : Center(
                        child: SvgPicture.asset(
                          HabitsListAssets.check,
                          width: _checkSize,
                          height: _checkSize,
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
