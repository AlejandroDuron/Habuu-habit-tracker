import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/widgets/habits_list/habits_list_view.dart';

import '../fakes/fake_habit_data_source.dart';

void main() {
  Future<void> pump(WidgetTester t, {required int count, bool loading = false}) =>
      t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HabitsListView(
            habits: List.generate(count, (i) => buildHabit(id: '$i', name: 'Hábito $i')),
            isLoading: loading,
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ));

  testWidgets('loading muestra CircularProgressIndicator', (t) async {
    await pump(t, count: 0, loading: true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lista vacía muestra mensaje', (t) async {
    await pump(t, count: 0);
    expect(find.text('Aún no tienes hábitos'), findsOneWidget);
  });

  testWidgets('muestra una tarjeta por hábito', (t) async {
    await pump(t, count: 3);
    expect(find.text('Hábito 0'), findsOneWidget);
    expect(find.text('Hábito 1'), findsOneWidget);
    expect(find.text('Hábito 2'), findsOneWidget);
  });
}
