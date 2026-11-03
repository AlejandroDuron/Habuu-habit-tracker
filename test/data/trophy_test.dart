import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';

void main() {
  group('Trophy', () {
    test('fromMap crea el trofeo con todos los campos', () {
      final t = Trophy.fromMap({
        'trophy_id': 'streak_7',
        'trophy_name': 'Racha de 7 días',
        'trophy_key': 'streak_7',
      });
      expect(t.id, 'streak_7');
      expect(t.name, 'Racha de 7 días');
      expect(t.key, 'streak_7');
    });

    test('fromMap acepta key null', () {
      final t = Trophy.fromMap(
          {'trophy_id': 'x', 'trophy_name': 'X', 'trophy_key': null});
      expect(t.key, isNull);
    });
  });

  group('EarnedTrophy', () {
    const base = Trophy(id: 'day_completed', name: 'Día', key: 'day_completed');

    test('fromMap parsea la fecha correctamente', () {
      final e = EarnedTrophy.fromMap({'earned_at': '2026-11-02T10:00:00.000'}, base);
      expect(e.earnedAt, DateTime(2026, 11, 2, 10));
    });

    test('fromMap lanza con fecha inválida', () {
      expect(
        () => EarnedTrophy.fromMap({'earned_at': 'no-es-fecha'}, base),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
