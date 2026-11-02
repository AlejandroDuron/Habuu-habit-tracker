import '../datasources/streak_data_source.dart';
import '../models/streak_data.dart';

class StreakRepository {
  StreakRepository(this._dataSource);

  final StreakDataSource _dataSource;

  Future<StreakData> getStreak() => _dataSource.getStreak();
}
