enum HabitType {
  frecuente('Habito Frecuente'),
  fugaz('Habito fugaz');
 
  const HabitType(this.label);
  final String label;
}

enum HabitCategory {
  mascota('Mascota'),
  salud('Salud'),
  hogar('Hogar'),
  universidad('Universidad');
 
  const HabitCategory(this.label);
 
  final String label;
}
 
/// Cada cuánto se repite un hábito
enum HabitRepeat {
  diariamente('Diariamente'),
  semanalmente('Semanalmente'),
  mensualmente('Mensualmente');
 
  const HabitRepeat(this.label);
 
  final String label;
}
 
/// En qué parte del día se le recuerda al usuario
enum HabitReminderTime {
  manana('Mañana'),
  tarde('Tarde'),
  noche('Noche');
 
  const HabitReminderTime(this.label);
 
  final String label;
}
 
class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.iconIndex,
    required this.colorValue,
    required this.reminderTime,
    required this.goalPerDay,
    required this.createdAt,
    this.repeat,
    this.days = const {},
    this.allDay = false,
    this.allowSkip = false,
    this.remindersEnabled = true,
  })  : assert(name.trim().isNotEmpty, 'El nombre no puede ir vacío'),
        assert(goalPerDay > 0, 'La meta tiene que ser al menos 1'),
        assert(iconIndex >= 0, 'El índice del ícono no puede ser negativo'),
        assert(
          days.every((d) => d >= DateTime.monday && d <= DateTime.sunday),
          'Los días van del 1 (lunes) al 7 (domingo), como DateTime.weekday',
        ),
        // Un hábito fugaz no se repite
        assert(
          type == HabitType.frecuente || repeat == null,
          'Un hábito fugaz no lleva repetición',
        );
 
  /// ID Lo genera el data source al crear el hábito.
  final String id;
 
  final String name;
  final HabitType type;
  final HabitCategory category;
 
  /// Posición del ícono elegido en la fila de icons
  /// Guardamos el número y no el ícono porque el ícono es cosa de la UI
  final int iconIndex;
  final int colorValue;
 
  /// Solo los hábitos frecuentes tienen repetición; en los fugaces es null
  final HabitRepeat? repeat;
 
  /// Días seleccionados en "en este día", con los números de DateTime.weekday.
  ///Es un Set porque un día no se repite.
  final Set<int> days;
  final bool allDay;
 
  final HabitReminderTime reminderTime;
 
  /// Cuántas veces al día hay que cumplirlo
  final int goalPerDay;
  final bool allowSkip;
  final bool remindersEnabled;
 
  final DateTime createdAt;
 
  bool get isFrequent => type == HabitType.frecuente;
 
  /// Texto que se muestra en el campo "Meta", por ejemplo "1 Vez o más al día".
  String get goalLabel =>
      goalPerDay == 1 ? '1 Vez o más al día' : '$goalPerDay veces al día';
 
  /// Como repeat puede ser null a propósito, usamos
  /// clearRepeat para poder borrarlo; con ?? no se podría.
  Habit copyWith({
    String? id,
    String? name,
    HabitType? type,
    HabitCategory? category,
    int? iconIndex,
    int? colorValue,
    HabitRepeat? repeat,
    bool clearRepeat = false,
    Set<int>? days,
    bool? allDay,
    HabitReminderTime? reminderTime,
    int? goalPerDay,
    bool? allowSkip,
    bool? remindersEnabled,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      iconIndex: iconIndex ?? this.iconIndex,
      colorValue: colorValue ?? this.colorValue,
      repeat: clearRepeat ? null : (repeat ?? this.repeat),
      days: days ?? this.days,
      allDay: allDay ?? this.allDay,
      reminderTime: reminderTime ?? this.reminderTime,
      goalPerDay: goalPerDay ?? this.goalPerDay,
      allowSkip: allowSkip ?? this.allowSkip,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
 
  /// Convierte el hábito a un Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'iconIndex': iconIndex,
      'colorValue': colorValue,
      'repeat': repeat?.name,
      'days': days.toList()..sort(),
      'allDay': allDay,
      'reminderTime': reminderTime.name,
      'goalPerDay': goalPerDay,
      'allowSkip': allowSkip,
      'remindersEnabled': remindersEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory Habit.fromMap(Map<String, Object?> map) {
    final repeatName = map['repeat'] as String?;
    final rawDays = (map['days'] as List<Object?>?) ?? const [];
 
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      type: HabitType.values.byName(map['type'] as String),
      category: HabitCategory.values.byName(map['category'] as String),
      iconIndex: (map['iconIndex'] as num).toInt(),
      colorValue: (map['colorValue'] as num).toInt(),
      repeat: repeatName == null ? null : HabitRepeat.values.byName(repeatName),
      days: rawDays.map((d) => (d as num).toInt()).toSet(),
      allDay: map['allDay'] as bool? ?? false,
      reminderTime:
          HabitReminderTime.values.byName(map['reminderTime'] as String),
      goalPerDay: (map['goalPerDay'] as num).toInt(),
      allowSkip: map['allowSkip'] as bool? ?? false,
      remindersEnabled: map['remindersEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}