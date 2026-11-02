import 'package:flutter/foundation.dart';

import '../../services/photo_compressor.dart';
import '../../utils/habit_schedule.dart';
import '../datasources/evidence_data_source.dart';
import '../datasources/home_data_source.dart';
import '../models/habit_log.dart';
import '../models/home_habit.dart';
import '../models/today_habit.dart';

class HomeRepository {
  // Depende de los contratos, no de Supabase: así se pueden usar los Fake.
  // [compressPhoto] se puede cambiar para no comprimir de verdad al probar.
  HomeRepository(
    this._dataSource,
    this._evidence, {
    Future<Uint8List> Function(Uint8List photo)? compressPhoto,
  }) : _compressPhoto = compressPhoto ?? compressEvidencePhoto;

  final HomeDataSource _dataSource;
  final EvidenceDataSource _evidence;
  final Future<Uint8List> Function(Uint8List photo) _compressPhoto;

  /// Hábitos que tocan en [day], cada uno con su registro de ese día.
  Future<List<TodayHabit>> getHabitsFor(DateTime day) async {
    // Las dos consultas no dependen una de la otra: van al mismo tiempo.
    // Future.wait deja pasar el error original si alguna falla.
    final results = await Future.wait([
      _dataSource.getActiveHabits(),
      _dataSource.getLogsOn(day),
    ]);
    final habits = results[0] as List<HomeHabit>;
    final logs = results[1] as List<HabitLog>;

    final logByHabit = {for (final log in logs) log.habitId: log};

    return [
      for (final habit in habits)
        if (isScheduledOn(habit, day))
          TodayHabit(habit: habit, log: logByHabit[habit.id]),
    ];
  }

  /// Marca un hábito como cumplido en [day], sin foto.
  Future<HabitLog> markDone(String habitId, DateTime day) {
    return _dataSource.saveLog(
      habitId: habitId,
      day: day,
      status: LogStatus.done,
    );
  }

  /// Marca un hábito como cumplido en [day] y guarda [photo] como evidencia.
  /// La foto se comprime antes de subirla.
  Future<HabitLog> markDoneWithPhoto(
    String habitId,
    DateTime day,
    Uint8List photo,
  ) async {
    final compressed = await _compressPhoto(photo);
    final path = await _evidence.upload(
      habitId: habitId,
      day: day,
      bytes: compressed,
    );

    try {
      return await _dataSource.saveLog(
        habitId: habitId,
        day: day,
        status: LogStatus.done,
        evidencePath: path,
      );
    } catch (_) {
      // Sin registro, la foto quedaría suelta en el almacenamiento.
      await _deleteQuietly(path);
      rethrow;
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await _evidence.delete(path);
    } catch (e) {
      debugPrint('No se pudo borrar una foto sin registro: $e');
    }
  }

  /// Froggy despierta en cuanto se cumple al menos un hábito.
  /// Los omitidos no cuentan.
  static bool isFrogAwake(List<TodayHabit> habits) =>
      habits.any((h) => h.isDone);
}
