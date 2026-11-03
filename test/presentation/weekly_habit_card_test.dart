import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/models/habits_list/weekly_habit_data.dart';
import 'package:habuu/presentation/widgets/habits_list/week_day_circle.dart';
import 'package:habuu/presentation/widgets/habits_list/weekly_habit_card.dart';

WeeklyHabitData _data({List<WeekDayState>? days}) => WeeklyHabitData(
      title: 'Correr',
      frequencyLabel: 'Diario',
      iconIndex: 0,
      color: const Color(0xFF4CAF50),
      days: days ?? List.filled(7, WeekDayState.empty),
    );

void main() {
  Future<void> pump(WidgetTester t, WeeklyHabitData data, {VoidCallback? onTap}) =>
      t.pumpWidget(MaterialApp(
        home: Scaffold(body: WeeklyHabitCard(data: data, onTap: onTap)),
      ));

  testWidgets('muestra el título del hábito', (t) async {
    await pump(t, _data());
    expect(find.text('Correr'), findsOneWidget);
  });

  testWidgets('muestra la etiqueta de frecuencia', (t) async {
    await pump(t, _data());
    expect(find.text('Diario'), findsOneWidget);
  });

  testWidgets('muestra 7 WeekDayCircle', (t) async {
    await pump(t, _data());
    expect(find.byType(WeekDayCircle), findsNWidgets(7));
  });

  testWidgets('onTap se llama al tocar la tarjeta', (t) async {
    var tapped = false;
    await pump(t, _data(), onTap: () => tapped = true);
    await t.tap(find.byType(WeeklyHabitCard));
    await t.pump();
    expect(tapped, isTrue);
  });
}
