import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/assets.dart';
import '../../utils/dates.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'habit_data_source.dart';


class SupabaseHabitDataSource implements HabitDataSource {
  SupabaseHabitDataSource(this._client);

  final SupabaseClient _client;

  // Caché de categorías del usuario
  final Map<String, String> _categoryCache = {};



  static final _iconKeys = HabitIconAssets.byKey.keys.toList();

  static String _iconKeyForIndex(int index) {
    if (index < 0 || index >= _iconKeys.length) {
      return HabitIconAssets.defaultKey;
    }
    return _iconKeys[index];
  }

  static int _indexForIconKey(String key) {
    final i = _iconKeys.indexOf(key);
    return i < 0 ? 0 : i;
  }

  //Colores


    static String _colorToHex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }


  static int _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return int.parse('FF$clean', radix: 16);
  }

  //Tipo de hábito
  static String _typeToDb(HabitType type) =>
      type == HabitType.frecuente ? 'recurring' : 'one_time';

  static HabitType _typeFromDb(String value) =>
      value == 'recurring' ? HabitType.frecuente : HabitType.fugaz;

  //Frecuencia

  /// Devuelve el fragmento de frecuencia para insertar en DB
  static Map<String, dynamic> _frequencyToDb(
    HabitRepeat? repeat,
    Set<int> days,
  ) {
    switch (repeat) {
      case HabitRepeat.diariamente:
        
        return {
          'frequency': 'weekly',
          'days_of_week': [1, 2, 3, 4, 5, 6, 7],
          'day_of_month': null,
        };
      case HabitRepeat.semanalmente:
        return {
          'frequency': 'weekly',
          'days_of_week': days.toList()..sort(),
          'day_of_month': null,
        };
      case HabitRepeat.mensualmente:
        return {
          'frequency': 'monthly',
          'days_of_week': null,
          'day_of_month': days.isNotEmpty ? days.first : 1,
        };
      case null:
      
        return {'frequency': null, 'days_of_week': null, 'day_of_month': null};
    }
  }

  static ({HabitRepeat? repeat, Set<int> days}) _frequencyFromDb(
    String? frequency,
    List<dynamic>? daysOfWeek,
    int? dayOfMonth,
  ) {
    if (frequency == null) return (repeat: null, days: const {});

    if (frequency == 'weekly') {
      final days = (daysOfWeek ?? []).map((d) => (d as num).toInt()).toSet();
      // Si tiene los 7 días es a diario
      if (days.length == 7) {
        return (repeat: HabitRepeat.diariamente, days: days);
      }
      return (repeat: HabitRepeat.semanalmente, days: days);
    }

    // monthly
    final day = dayOfMonth ?? 1;
    return (repeat: HabitRepeat.mensualmente, days: {day});
  }

  // Recordatorios
  /// Columnas que pedimos siempre, el hábito, su categoría y su recordatorio
  static const _select =
      '*, categories(category_name), reminders(reminder_time, activate_reminder)';

  static String _timeToDb(({int hour, int minute}) time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }


  static ({int hour, int minute}) _timeFromDb(String value) {
    final parts = value.split(':');
    return (hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static Map<String, dynamic>? _reminderRow(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is List && value.isNotEmpty) {
      return value.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> _saveReminder(String habitId, Habit habit) async {
    final time = habit.reminderTime;
    if (time == null) {
      await _client.from('reminders').delete().eq('habit_id', habitId);
      return;
    }
    // upsert = insertar o, si ya existe una fila con ese habit_id, actualizarla
    await _client.from('reminders').upsert({
      'habit_id': habitId,
      'reminder_time': _timeToDb(time),
      'activate_reminder': habit.remindersEnabled,
    }, onConflict: 'habit_id');
  }

  /// Vuelve a leer un hábito ya guardado, con su recordatorio incluido
  Future<Habit> _fetchHabit(String habitId) async {
    final row = await _client
        .from('habits')
        .select(_select)
        .eq('habit_id', habitId)
        .single();
    return _rowToHabit(row);
  }

  // categorias

  Future<String> _resolveCategoryId(Habit habit) async {
    final label = habit.categoryLabel;

    if (_categoryCache.containsKey(label)) return _categoryCache[label]!;

    final userId = _userId;

    // Busca la categoría existente del usuario
    final rows = await _client
        .from('categories')
        .select('category_id')
        .eq('user_id', userId)
        .eq('category_name', label)
        .limit(1);

    if (rows.isNotEmpty) {
      final id = rows.first['category_id'] as String;
      _categoryCache[label] = id;
      return id;
    }

    // Si no existe, la crea
    final inserted = await _client
        .from('categories')
        .insert({'category_name': label, 'user_id': userId})
        .select('category_id')
        .single();

    final id = inserted['category_id'] as String;
    _categoryCache[label] = id;
    return id;
  }

  /// Carga todas las categorías del usuario para poblar el caché
  Future<void> _loadCategories() async {
    if (_categoryCache.isNotEmpty) return;

    final userId = _userId;
    final rows = await _client
        .from('categories')
        .select('category_id, category_name')
        .eq('user_id', userId);

    for (final row in rows) {
      _categoryCache[row['category_name'] as String] =
          row['category_id'] as String;
    }
    }

    Habit _rowToHabit(Map<String, dynamic> row) {
    final freq = _frequencyFromDb(
      row['frequency'] as String?,
      row['days_of_week'] as List<dynamic>?,
      (row['day_of_month'] as num?)?.toInt(),
    );

    // Busca la categoría por nombre en el caché. Si no la encuentra, usa la primera del enum
    final categoryName = row['categories']?['category_name'] as String?;
    HabitCategory category = HabitCategory.values.first;
    if (categoryName != null) {
      try {
        category = HabitCategory.values.firstWhere(
          (c) => c.label == categoryName,
        );
      } catch (_) {
        // Si no es una categoría predefinida, usamos la primera del enum
      }
    }

    final colorHex = row['color'] as String?;
    final reminder = _reminderRow(row['reminders']);
    final reminderTime = reminder?['reminder_time'] as String?;

    return Habit(
      id: row['habit_id'] as String,
      name: row['habit_name'] as String,
      type: _typeFromDb(row['type'] as String),
      category: category,
      categoryLabel: categoryName ?? category.label,
      iconIndex: _indexForIconKey(row['icon_key'] as String),
      colorValue: colorHex != null
          ? _hexToColor(colorHex)
          : HabitCategory.values.first.hashCode,
      repeat: freq.repeat,
      days: freq.days,
      allDay: false,
      reminderTime: reminderTime != null ? _timeFromDb(reminderTime) : null,
      goalPerDay: (row['goal_per_day'] as num?)?.toInt() ?? 1,
      allowSkip: (row['allow_skip'] as bool?) ?? false,
      // Sin fila en reminders = sin recordatorio
      remindersEnabled: (reminder?['activate_reminder'] as bool?) ?? false,
      createdAt: DateTime.parse(row['created_date'] as String),
    );
  }

  //HabitDataSource

  @override
  Future<List<Habit>> getHabits() {
    return _request('No se pudieron cargar tus hábitos', () async {
      await _loadCategories();

      final rows = await _client
          .from('habits')
          .select(_select)
          .eq('user_id', _userId)
          .isFilter('deleted_at', null)
          .order('created_at');

      return rows.map((r) => _rowToHabit(r)).toList();
    });
  }

  @override
  Future<Habit> createHabit(Habit habit) {
    return _request('No se pudo crear el hábito', () async {
      final categoryId = await _resolveCategoryId(habit);

      final freqData = _frequencyToDb(habit.repeat, habit.days);

      final row = await _client
          .from('habits')
          .insert({
            'user_id': _userId,
            'category_id': categoryId,
            'icon_key': _iconKeyForIndex(habit.iconIndex),
            'habit_name': habit.name,
            'color': _colorToHex(habit.colorValue),
            'type': _typeToDb(habit.type),
            'allow_skip': habit.allowSkip,
            'goal_per_day': habit.goalPerDay,
            'created_date': isoDate(habit.createdAt),
            ...freqData,
          })
          .select('habit_id')
          .single();

      // El recordatorio va en otra tabla, así que lo guardamos aparte con
      // el id que Supabase le da al hábito
      final id = row['habit_id'] as String;
      await _saveReminder(id, habit);
      return _fetchHabit(id);
    });
  }

  @override
  Future<Habit> updateHabit(Habit habit) {
    return _request('No se pudieron guardar los cambios', () async {
      final categoryId = await _resolveCategoryId(habit);
      final freqData = _frequencyToDb(habit.repeat, habit.days);

      final rows = await _client
          .from('habits')
          .update({
            'category_id': categoryId,
            'icon_key': _iconKeyForIndex(habit.iconIndex),
            'habit_name': habit.name,
            'color': _colorToHex(habit.colorValue),
            'type': _typeToDb(habit.type),
            'allow_skip': habit.allowSkip,
            'goal_per_day': habit.goalPerDay,
            ...freqData,
          })
          .eq('habit_id', habit.id)
          .eq('user_id', _userId)
          .select('habit_id');

      if (rows.isEmpty) throw HabitNotFoundException(habit.id);
      await _saveReminder(habit.id, habit);
      return _fetchHabit(habit.id);
    });
  }

  @override
  Future<void> deleteHabit(String id) {
    return _request('No se pudo eliminar el hábito', () async {

      final rows = await _client
          .from('habits')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('habit_id', id)
          .eq('user_id', _userId)
          .select('habit_id');

      if (rows.isEmpty) throw HabitNotFoundException(id);
    });
  }

  // utilidades

  @override
  Future<Map<String, LogStatus>> getLogStatusesForDay(DateTime day) {
    return _request('No se pudo cargar el estado de tus hábitos', () async {
      final rows = await _client
          .from('habit_logs')
          .select('habit_id, status')
          .eq('log_date', isoDate(day));

      return {
        for (final row in rows)
          row['habit_id'] as String: LogStatus.values.byName(
            row['status'] as String,
          ),
      };
    });
  }

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada');
    return user.id;
  }

  Future<T> _request<T>(String errorMessage, Future<T> Function() query) async {
    try {
      return await query();
    } on HabitNotFoundException {
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('Supabase error ${e.code}: ${e.message}');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error (hábitos): $e');
      throw Exception(errorMessage);
    }
  }
  }