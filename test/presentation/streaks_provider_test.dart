import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/streak_data.dart';
import 'package:habuu/data/repositories/streak_repository.dart';
import 'package:habuu/presentation/providers/streaks_provider.dart';

import '../fakes/fake_streak_data_source.dart';

void main() {
  group('StreaksProvider', () {
    test('estado inicial es initial con racha 0', () {
      final p = StreaksProvider(StreakRepository(FakeStreakDataSource()));
      expect(p.status, StreaksStatus.initial);
      expect(p.currentStreak, 0);
      expect(p.isLoading, isFalse);
    });

    test('loadStreak carga datos y pasa a ready', () async {
      final p = StreaksProvider(
        StreakRepository(FakeStreakDataSource(
          data: StreakData(currentStreak: 5, streakDays: {}),
        )),
      );
      await p.loadStreak();
      expect(p.status, StreaksStatus.ready);
      expect(p.currentStreak, 5);
    });

    test('loadStreak pasa a error si el datasource falla', () async {
      final p = StreaksProvider(
        StreakRepository(FakeStreakDataSource(shouldFail: true)),
      );
      await p.loadStreak();
      expect(p.status, StreaksStatus.error);
      expect(p.errorMessage, isNotNull);
    });

    test('segunda llamada mientras carga no duplica peticiones', () async {
      final ds = FakeStreakDataSource(
        data: const StreakData.empty(),
        delay: const Duration(milliseconds: 50),
      );
      final p = StreaksProvider(StreakRepository(ds));
      final f1 = p.loadStreak();
      final f2 = p.loadStreak();
      await Future.wait([f1, f2]);
      expect(ds.getCalls, 1);
    });
  });
}
