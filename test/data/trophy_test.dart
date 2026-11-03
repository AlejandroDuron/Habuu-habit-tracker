// Tests unitarios de los modelos Trophy y EarnedTrophy.

import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';

void main() {
  group('Trophy', () {
    test('fromMap crea un Trophy con todos los campos', () {
      final trophy = Trophy.fromMap({
        'trophy_id': 'streak_7',
        'trophy_name': 'Racha de 7 días',
        'trophy_key': 'streak_7',
      });

      expect(trophy.id, 'streak_7');
      expect(trophy.name, 'Racha de 7 días');
      expect(trophy.key, 'streak_7');
    });

    test('fromMap acepta trophy_key null', () {
      final trophy = Trophy.fromMap({
        'trophy_id': 'mystery',
        'trophy_name': 'Misterioso',
        'trophy_key': null,
      });

      expect(trophy.key, isNull);
    });

    test('constructor directo preserva los valores', () {
      const trophy = Trophy(
        id: 'day_completed',
        name: 'Día completado',
        key: 'day_completed',
      );

      expect(trophy.id, 'day_completed');
      expect(trophy.name, 'Día completado');
      expect(trophy.key, 'day_completed');
    });
  });

  group('EarnedTrophy', () {
    const baseTrophy = Trophy(
      id: 'new_habits',
      name: 'Nuevos hábitos',
      key: 'new_habits',
    );

    test('fromMap crea un EarnedTrophy con la fecha correcta', () {
      final earned = EarnedTrophy.fromMap(
        {'earned_at': '2026-11-02T10:00:00.000'},
        baseTrophy,
      );

      expect(earned.trophy.id, 'new_habits');
      expect(earned.earnedAt, DateTime(2026, 11, 2, 10));
    });

    test('constructor directo preserva trophy y fecha', () {
      final earned = EarnedTrophy(
        trophy: baseTrophy,
        earnedAt: DateTime(2026, 1, 15),
      );

      expect(earned.trophy, baseTrophy);
      expect(earned.earnedAt, DateTime(2026, 1, 15));
    });

    test('fromMap lanza si earned_at no es una fecha válida', () {
      expect(
        () => EarnedTrophy.fromMap({'earned_at': 'no-es-fecha'}, baseTrophy),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
