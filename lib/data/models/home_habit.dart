import '../../utils/dates.dart';

/// Si el hábito se repite o es de un solo día.
enum HomeHabitType {
  recurring('recurring'),
  oneTime('one_time');

  const HomeHabitType(this.dbValue);

  /// Valor del enum habit_type en la base de datos.
  final String dbValue;

  static HomeHabitType fromDb(String value) =>
      values.firstWhere((t) => t.dbValue == value);
}

/// Cada cuánto se repite un hábito recurrente.
enum HabitFrequency { weekly, monthly }

/// Un hábito tal como lo necesita el Home: solo lectura.
class HomeHabit {
  HomeHabit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.type,
    required this.createdDate,
    this.color,
    this.frequency,
    this.daysOfWeek = const {},
    this.dayOfMonth,
    this.goal,
    this.allowSkip = false,
  }) : assert(name.trim().isNotEmpty, 'El nombre no puede ir vacío'),
       assert(
         daysOfWeek.every((d) => d >= DateTime.monday && d <= DateTime.sunday),
         'Los días van del 1 (lunes) al 7 (domingo)',
       ),
       assert(
         dayOfMonth == null || (dayOfMonth >= 1 && dayOfMonth <= 31),
         'El día del mes va del 1 al 31',
       );

  final String id;
  final String name;
  final String iconKey;
  final String? color;
  final HomeHabitType type;
  final HabitFrequency? frequency;
  final Set<int> daysOfWeek;
  final int? dayOfMonth;
  final String? goal;
  final DateTime createdDate;

  /// Si el usuario puede omitir este hábito en lugar de completarlo.
  final bool allowSkip;

  factory HomeHabit.fromMap(Map<String, dynamic> map) {
    final frequency = map['frequency'] as String?;
    final days = (map['days_of_week'] as List<dynamic>?) ?? const [];

    return HomeHabit(
      id: map['habit_id'] as String,
      name: map['habit_name'] as String,
      iconKey: map['icon_key'] as String,
      color: map['color'] as String?,
      type: HomeHabitType.fromDb(map['type'] as String),
      frequency: frequency == null
          ? null
          : HabitFrequency.values.byName(frequency),
      daysOfWeek: days.map((d) => (d as num).toInt()).toSet(),
      dayOfMonth: (map['day_of_month'] as num?)?.toInt(),
      goal: map['goal'] as String?,
      createdDate: dateOnly(DateTime.parse(map['created_date'] as String)),
      allowSkip: (map['allow_skip'] as bool?) ?? false,
    );
  }
}
