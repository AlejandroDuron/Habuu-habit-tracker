import 'package:flutter/foundation.dart';

import '../../services/photo_compressor.dart';
import '../../utils/habit_schedule.dart';
import '../datasources/daily_summary_data_source.dart';
import '../datasources/evidence_data_source.dart';
import '../datasources/habit_photo_verifier.dart';
import '../datasources/home_data_source.dart';
import '../models/habit_log.dart';
import '../models/home_habit.dart';
import '../models/today_habit.dart';
import '../models/verification_result.dart';

/// Error al intentar omitir un hábito que no lo permite.
class SkipNotAllowedException implements Exception {
  const SkipNotAllowedException(this.habitName);
  final String habitName;

  @override
  String toString() => '"$habitName" no permite ser omitido';
}

class HomeRepository {
  HomeRepository(
    this._dataSource,
    this._evidence,
    this._dailySummary, {
    required this._verifier,
    Future<Uint8List> Function(Uint8List photo)? compressPhoto,
  }) : _compressPhoto = compressPhoto ?? compressEvidencePhoto;

  final HomeDataSource _dataSource;
  final EvidenceDataSource _evidence;
  final DailySummaryDataSource _dailySummary;
  final HabitPhotoVerifier _verifier;
  final Future<Uint8List> Function(Uint8List photo) _compressPhoto;

  /// Hábitos que tocan en [day], cada uno con su registro de ese día.
  Future<List<TodayHabit>> getHabitsFor(DateTime day) async {
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
  Future<HabitLog> markDone(String habitId, DateTime day) async {
    return _dataSource.saveLog(
      habitId: habitId,
      day: day,
      status: LogStatus.done,
    );
  }

  /// Marca un hábito como cumplido en [day] y guarda [photo] como evidencia.
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
      await _deleteQuietly(path);
      rethrow;
    }
  }

  /// Comprime y sube la foto, pero todavía no marca el hábito.
  /// Devuelve la ruta donde quedó.
  Future<String> uploadEvidence(
    String habitId,
    DateTime day,
    Uint8List photo,
  ) async {
    final compressed = await _compressPhoto(photo);
    return _evidence.upload(habitId: habitId, day: day, bytes: compressed);
  }

  /// Revisa si la foto en [path] tiene que ver con [habit].
  ///
  /// Si se agota el tiempo se intenta una vez más sin avisar: la primera
  /// verificación después de un rato sin usarla tarda mucho más, y la
  /// segunda casi siempre responde rápido.
  Future<VerificationResult> verifyEvidence(
    String path,
    HomeHabit habit,
  ) async {
    try {
      return await _verifier.verify(photoPath: path, habit: habit);
    } on VerificationException catch (e) {
      if (e.failure != VerificationFailure.timeout) rethrow;
      debugPrint('La verificación tardó demasiado, se intenta otra vez');
      return _verifier.verify(photoPath: path, habit: habit);
    }
  }

  /// Marca el hábito como cumplido con una foto que ya está subida.
  Future<HabitLog> markDoneWithEvidence(
    String habitId,
    DateTime day,
    String path,
  ) {
    return _dataSource.saveLog(
      habitId: habitId,
      day: day,
      status: LogStatus.done,
      evidencePath: path,
    );
  }

  /// Baja una foto de evidencia ya guardada.
  Future<Uint8List> downloadEvidence(String path) => _evidence.download(path);

  /// Borra una foto que se subió pero no se usó en ningún registro.
  Future<void> discardEvidence(String path) => _deleteQuietly(path);

  /// Marca un hábito como omitido en [day].
  ///
  /// Lanza [SkipNotAllowedException] si el hábito no permite ser omitido.
  /// La validación ocurre en el cliente antes de ir a Supabase.
  Future<HabitLog> markSkipped(TodayHabit todayHabit, DateTime day) async {
    if (!todayHabit.habit.allowSkip) {
      throw SkipNotAllowedException(todayHabit.habit.name);
    }
    return _dataSource.saveLog(
      habitId: todayHabit.habit.id,
      day: day,
      status: LogStatus.skipped,
    );
  }

  /// Verifica localmente (sin queries extra) si todos los hábitos del día
  /// ya están completados y, si es así, registra el día en [daily_summaries].
  ///
  /// Llamar con la lista ya actualizada tras aplicar el nuevo log.
  /// Los omitidos (skipped) no cuentan — si el usuario solo omite hábitos,
  /// el día NO se marca como completado.
  void checkAndMarkDayComplete(DateTime day, List<TodayHabit> habits) {
    if (habits.isEmpty) return;
    if (!habits.every((h) => h.isDone)) return;

    _dailySummary.markDayComplete(day).catchError((e) {
      debugPrint('No se pudo actualizar el resumen diario: $e');
    });
  }

  /// Invalida el día [day] en [daily_summaries] poniéndolo como incompleto.
  ///
  /// Llamar cuando se añade un hábito nuevo a un día que ya estaba marcado
  /// como completado, para que la racha no cuente ese día prematuramente.
  void markDayIncomplete(DateTime day) {
    _dailySummary.markDayIncomplete(day).catchError((e) {
      debugPrint('No se pudo invalidar el resumen diario: $e');
    });
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await _evidence.delete(path);
    } catch (e) {
      debugPrint('No se pudo borrar una foto sin registro: $e');
    }
  }

  /// Froggy despierta en cuanto se cumple al menos un hábito.
  static bool isFrogAwake(List<TodayHabit> habits) =>
      habits.any((h) => h.isDone);
}
