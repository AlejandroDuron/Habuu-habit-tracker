import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/widgets/habits_list/period_segment.dart';

void main() {
  Future<void> pump(WidgetTester t, {int selected = 0, ValueChanged<int>? onChanged}) =>
      t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PeriodSegment(
            labels: const ['Hoy', 'Semana', 'Todo'],
            selected: selected,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ));

  testWidgets('renderiza las tres etiquetas', (t) async {
    await pump(t);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Todo'), findsOneWidget);
  });

  testWidgets('tocar una etiqueta llama a onChanged con su índice', (t) async {
    int? tapped;
    await pump(t, onChanged: (i) => tapped = i);
    await t.tap(find.text('Semana'));
    await t.pump();
    expect(tapped, 1);
  });

  testWidgets('tocar el segmento activo llama a onChanged igual', (t) async {
    int? tapped;
    await pump(t, selected: 0, onChanged: (i) => tapped = i);
    await t.tap(find.text('Hoy'));
    await t.pump();
    expect(tapped, 0);
  });
}
