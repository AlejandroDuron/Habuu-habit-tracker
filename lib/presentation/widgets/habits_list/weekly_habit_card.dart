import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../models/habits_list/weekly_habit_data.dart';
import '../habits/habit_icon_picker.dart';
import 'week_day_circle.dart';

class WeeklyHabitCard extends StatelessWidget {
  const WeeklyHabitCard({super.key, required this.data, this.onTap});

  final WeeklyHabitData data;
  final VoidCallback? onTap;

  static const _shortDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _fullDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  static const double _radius = 12;
  static const _shadow = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 2),
    blurRadius: 4,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [_shadow],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(data: data),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: WeekDayCircle(
                          label: _shortDays[i],
                          fullLabel: _fullDays[i],
                          state: data.days[i],
                          color: data.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data});

  final WeeklyHabitData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          habitIconFor(data.iconIndex),
          size: 22,
          color: HabuuColors.black90,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HabuuText.bodySmSemibold.copyWith(
              fontWeight: HabuuWeight.bold,
              color: HabuuColors.black90,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          data.frequencyLabel,
          style: HabuuText.captionMdMedium.copyWith(
            fontWeight: HabuuWeight.regular,
            color: HabuuColors.grey500,
          ),
        ),
      ],
    );
  }
}
