import 'package:flutter_test/flutter_test.dart';
import 'package:habuu/data/models/trophy.dart';
import 'package:habuu/data/repositories/trophy_repository.dart';
import 'package:habuu/presentation/providers/trophies_provider.dart';

import '../fakes/fake_trophy_data_source_full.dart';

void main() {
  group('TrophiesProvider', () {
    test('estado inicial es initial y listas vacías', () {
      final p = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull()));
      expect(p.status, TrophiesStatus.initial);
      expect(p.earned, isEmpty);
      expect(p.locked, isEmpty);
    });

    test('loadTrophies separa earned y locked', () async {
      final earned = buildEarnedTrophy(trophy: buildTrophy(id: 'day_completed'));
      final p = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull(
        allTrophies: [buildTrophy(id: 'day_completed'), buildTrophy(id: 'streak_7')],
        earnedTrophies: [earned],
      )));
      await p.loadTrophies();
      expect(p.earned, hasLength(1));
      expect(p.locked, hasLength(1));
      expect(p.earnedCount, 1);
    });

    test('loadTrophies pasa a error si falla', () async {
      final p = TrophiesProvider(
        TrophyRepository(FakeTrophyDataSourceFull(shouldFail: true)),
      );
      await p.loadTrophies();
      expect(p.status, TrophiesStatus.error);
      expect(p.errorMessage, isNotNull);
    });

    test('checkDayCompleted agrega a newlyEarned cuando gana trofeo', () async {
      final newTrophy = buildEarnedTrophy(trophy: buildTrophy(id: 'day_completed'));
      final p = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull(
        allTrophies: [buildTrophy(id: 'day_completed')],
        awardedTrophy: newTrophy,
      )));
      await p.loadTrophies();
      await p.checkDayCompleted(allDone: true);
      expect(p.newlyEarned, hasLength(1));
    });

    test('clearNewlyEarned vacía la lista', () async {
      final p = TrophiesProvider(TrophyRepository(FakeTrophyDataSourceFull(
        awardedTrophy: buildEarnedTrophy(trophy: buildTrophy(id: 'day_completed')),
      )));
      await p.loadTrophies();
      await p.checkDayCompleted(allDone: true);
      p.clearNewlyEarned();
      expect(p.newlyEarned, isEmpty);
    });
  });
}
