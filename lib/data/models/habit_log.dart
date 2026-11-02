import '../../utils/dates.dart';

/// Cómo terminó un hábito en un día.
enum LogStatus { done, skipped }

/// Registro de un hábito en un día: si se cumplió y su foto de evidencia.
class HabitLog {
  HabitLog({
    required this.id,
    required this.habitId,
    required DateTime logDate,
    required this.status,
    this.evidencePath,
  }) : logDate = dateOnly(logDate);

  final String id;
  final String habitId;
  final DateTime logDate;
  final LogStatus status;

  /// Ruta de la foto en el almacenamiento. Es null si se omitió.
  final String? evidencePath;

  bool get isDone => status == LogStatus.done;

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['habit_log_id'] as String,
      habitId: map['habit_id'] as String,
      logDate: DateTime.parse(map['log_date'] as String),
      status: LogStatus.values.byName(map['status'] as String),
      evidencePath: map['evidence_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habit_log_id': id,
      'habit_id': habitId,
      'log_date': isoDate(logDate),
      'status': status.name,
      'evidence_path': evidencePath,
    };
  }
}
