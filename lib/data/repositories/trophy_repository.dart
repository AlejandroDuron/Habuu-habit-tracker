import '../datasources/trophy_data_source.dart';
import '../models/trophy.dart';

class TrophyRepository {
  TrophyRepository(this._dataSource);

  final TrophyDataSource _dataSource;

  /// Trae todos los trofeos y los separa entre ganados y pendientes.
  Future<({List<EarnedTrophy> earned, List<Trophy> locked})> getTrophies() async {
    final results = await Future.wait([
      _dataSource.getAllTrophies(),
      _dataSource.getEarnedTrophies(),
    ]);

    final all = results[0] as List<Trophy>;
    final earned = results[1] as List<EarnedTrophy>;

    final earnedIds = earned.map((e) => e.trophy.id).toSet();
    final locked = all.where((t) => !earnedIds.contains(t.id)).toList();

    return (earned: earned, locked: locked);
  }
}
