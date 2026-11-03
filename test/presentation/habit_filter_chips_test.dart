import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/presentation/providers/habits_provider.dart';
import 'package:habuu/presentation/widgets/habits_list/habit_filter_chips.dart';

void main() {
  Future<void> pump(
    WidgetTester t, {
    HabitChipFilter chip = HabitChipFilter.all,
    String? category,
    List<String> categories = const [],
    ValueChanged<HabitChipFilter>? onType,
    ValueChanged<String?>? onCat,
    VoidCallback? onReset,
  }) =>
      t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HabitFilterChips(
            chipFilter: chip,
            categoryFilter: category,
            categories: categories,
            onTypeChanged: onType ?? (_) {},
            onCategoryChanged: onCat ?? (_) {},
            onReset: onReset ?? () {},
          ),
        ),
      ));

  testWidgets('siempre muestra "Todo", "Frecuente", "Fugaz", "Omitidos"', (t) async {
    await pump(t);
    for (final label in ['Todo', 'Frecuente', 'Fugaz', 'Omitidos']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('muestra categorías dinámicas', (t) async {
    await pump(t, categories: ['Salud', 'Hogar']);
    expect(find.text('Salud'), findsOneWidget);
    expect(find.text('Hogar'), findsOneWidget);
  });

  testWidgets('tocar "Todo" llama a onReset', (t) async {
    var reset = false;
    await pump(t, onReset: () => reset = true);
    await t.tap(find.text('Todo'));
    await t.pump();
    expect(reset, isTrue);
  });

  testWidgets('tocar chip de tipo llama a onTypeChanged', (t) async {
    HabitChipFilter? got;
    await pump(t, onType: (f) => got = f);
    await t.tap(find.text('Frecuente'));
    await t.pump();
    expect(got, HabitChipFilter.frequent);
  });

  testWidgets('tocar categoría llama a onCategoryChanged', (t) async {
    String? got;
    await pump(t, categories: ['Salud'], onCat: (c) => got = c);
    await t.tap(find.text('Salud'));
    await t.pump();
    expect(got, 'Salud');
  });

  testWidgets('tocar categoría activa la desactiva (null)', (t) async {
    String? got = 'sentinel';
    await pump(t, category: 'Salud', categories: ['Salud'], onCat: (c) => got = c);
    await t.tap(find.text('Salud'));
    await t.pump();
    expect(got, isNull);
  });
}
