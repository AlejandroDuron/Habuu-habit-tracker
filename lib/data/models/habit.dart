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
    this.goal,
    this.repeat,
    this.days = const {},
    this.allDay = false,
    this.allowSkip = false,
    this.remindersEnabled = true,
    String? categoryLabel,
  }) : categoryLabel = categoryLabel ?? category.label,
       assert(name.trim().isNotEmpty, 'El nombre no puede ir vacío'),
       assert(goalPerDay > 0, 'La meta tiene que ser al menos 1'),
       assert(iconIndex >= 0, 'El índice del ícono no puede ser negativo'),
       assert(
         days.every((d) => d >= 1 && d <= 31),
         'Los días deben estar en el rango 1–31',
       ),
       assert(
         type == HabitType.frecuente || repeat == null,
         'Un hábito fugaz no lleva repetición',
       );

  final String id;
  final String name;
  final HabitType type;
  final HabitCategory category;

  /// Nombre real de la categoría. Para las predefinidas coincide con
  /// [category.label]; para las personalizadas guarda el texto ingresado
  /// por el usuario (que no está en el enum [HabitCategory]).
  final String categoryLabel;

  /// Posición del ícono elegido en la fila de icons.
  final int iconIndex;
  final int colorValue;

  /// Solo los hábitos frecuentes tienen repetición; en los fugaces es null.
  final HabitRepeat? repeat;

  /// - Semanal: números de DateTime.weekday (1=lunes … 7=domingo).
  /// - Mensual: un único día del mes (1–31).
  final Set<int> days;
  final bool allDay;

  /// Hora específica del recordatorio. Null si los recordatorios están desactivados.
  final ({int hour, int minute})? reminderTime;

  /// Descripción libre de la meta del hábito (ej. "30 minutos", "5 km").
  final String? goal;

  /// Cuántas veces al día hay que cumplirlo (siempre 1 cuando se usa [goal]).
  final int goalPerDay;
  final bool allowSkip;
  final bool remindersEnabled;

  final DateTime createdAt;

  bool get isFrequent => type == HabitType.frecuente;

  /// Texto para mostrar en tarjetas. Prioriza [goal] si está definido.
  String get goalLabel {
    if (goal != null && goal!.trim().isNotEmpty) return goal!.trim();
    return goalPerDay == 1 ? '1 Vez o más al día' : '$goalPerDay veces al día';
  }

  Habit copyWith({
    String? id,
    String? name,
    HabitType? type,
    HabitCategory? category,
    String? categoryLabel,
    int? iconIndex,
    int? colorValue,
    HabitRepeat? repeat,
    bool clearRepeat = false,
    Set<int>? days,
    bool? allDay,
    ({int hour, int minute})? reminderTime,
    bool clearReminderTime = false,
    String? goal,
    bool clearGoal = false,
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
      categoryLabel: categoryLabel ?? this.categoryLabel,
      iconIndex: iconIndex ?? this.iconIndex,
      colorValue: colorValue ?? this.colorValue,
      repeat: clearRepeat ? null : (repeat ?? this.repeat),
      days: days ?? this.days,
      allDay: allDay ?? this.allDay,
      reminderTime: clearReminderTime
          ? null
          : (reminderTime ?? this.reminderTime),
      goal: clearGoal ? null : (goal ?? this.goal),
      goalPerDay: goalPerDay ?? this.goalPerDay,
      allowSkip: allowSkip ?? this.allowSkip,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'categoryLabel': categoryLabel,
      'iconIndex': iconIndex,
      'colorValue': colorValue,
      'repeat': repeat?.name,
      'days': days.toList()..sort(),
      'allDay': allDay,
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
      'goal': goal,
      'goalPerDay': goalPerDay,
      'allowSkip': allowSkip,
      'remindersEnabled': remindersEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    final repeatName = map['repeat'] as String?;
    final rawDays = (map['days'] as List<Object?>?) ?? const [];
    final reminderHour = (map['reminderHour'] as num?)?.toInt();
    final reminderMinute = (map['reminderMinute'] as num?)?.toInt();

    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      type: HabitType.values.byName(map['type'] as String),
      category: HabitCategory.values.byName(map['category'] as String),
      categoryLabel: map['categoryLabel'] as String?,
      iconIndex: (map['iconIndex'] as num).toInt(),
      colorValue: (map['colorValue'] as num).toInt(),
      repeat: repeatName == null ? null : HabitRepeat.values.byName(repeatName),
      days: rawDays.map((d) => (d as num).toInt()).toSet(),
      allDay: map['allDay'] as bool? ?? false,
      reminderTime: (reminderHour != null && reminderMinute != null)
          ? (hour: reminderHour, minute: reminderMinute)
          : null,
      goal: map['goal'] as String?,
      goalPerDay: (map['goalPerDay'] as num).toInt(),
      allowSkip: map['allowSkip'] as bool? ?? false,
      remindersEnabled: map['remindersEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
