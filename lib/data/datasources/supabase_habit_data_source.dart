import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/assets.dart';
import '../../utils/dates.dart';
import '../models/habit.dart';
import 'habit_data_source.dart';

/// Implementación real de [HabitDataSource] usando Supabase.
///
/// Mapeo de campos:
/// - `iconIndex` (local, 0-based) ↔ `icon_key` (DB, texto)  usando las claves de [HabitIconAssets].
/// - `category` (local, enum en español) ↔ `category_id` (DB, UUID).
///   Las categorías del usuario se resuelven la primera vez y se cachean.
/// - `colorValue` (local, ARGB int) ↔ `color` (DB, hex string "#RRGGBB").
/// - `type` (frecuente/fugaz) ↔ `type` (recurring/one_time).
/// - `repeat` (diariamente/semanalmente/mensualmente) ↔ `frequency` (weekly/monthly) + `days_of_week` / `day_of_month`.
class SupabaseHabitDataSource implements HabitDataSource {
  SupabaseHabitDataSource(this._client);

  final SupabaseClient _client;

  // Caché de categorías del usuario: nombre en español → category_id.
  final Map<String, String> _categoryCache = {};

  // ── Claves de iconos (misma lista que HabitIconAssets.byKey)  ─────────────

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

  // ── Mapeo de colores  ──────────────────────────────────────────────────────

  /// int ARGB (0xFFRRGGBB) → "#RRGGBB".
  static String _colorToHex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// "#RRGGBB" → int ARGB (0xFFRRGGBB).
  static int _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return int.parse('FF$clean', radix: 16);
  }

  // ── Mapeo de tipo  ─────────────────────────────────────────────────────────

  static String _typeToDb(HabitType type) =>
      type == HabitType.frecuente ? 'recurring' : 'one_time';

  static HabitType _typeFromDb(String value) =>
      value == 'recurring' ? HabitType.frecuente : HabitType.fugaz;

  // ── Mapeo de frecuencia  ───────────────────────────────────────────────────

  /// Devuelve el fragmento de frecuencia para insertar en DB.
  static Map<String, dynamic> _frequencyToDb(HabitRepeat? repeat, Set<int> days) {
    switch (repeat) {
      case HabitRepeat.diariamente:
        // Diario = semanal con los 7 días.
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
        // Hábito fugaz (one_time): sin frecuencia.
        return {
          'frequency': null,
          'days_of_week': null,
          'day_of_month': null,
        };
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
      // Si tiene los 7 días → diario.
      if (days.length == 7) return (repeat: HabitRepeat.diariamente, days: days);
      return (repeat: HabitRepeat.semanalmente, days: days);
    }

    // monthly
    final day = dayOfMonth ?? 1;
    return (repeat: HabitRepeat.mensualmente, days: {day});
  }

  // ── Categorías  ───────────────────────────────────────────────────────────

  /// Nombre del enum HabitCategory en la DB (en inglés → usamos el nombre Dart).
  static String _categoryLabel(HabitCategory cat) => cat.label;

  /// Obtiene o crea el category_id para [category] del usuario actual.
  Future<String> _resolveCategoryId(HabitCategory category) async {
    final label = _categoryLabel(category);

    if (_categoryCache.containsKey(label)) return _categoryCache[label]!;

    final userId = _userId;

    // Busca la categoría existente del usuario.
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

    // Si no existe, la crea.
    final inserted = await _client
        .from('categories')
        .insert({'category_name': label, 'user_id': userId})
        .select('category_id')
        .single();

    final id = inserted['category_id'] as String;
    _categoryCache[label] = id;
    return id;
  }

  /// Carga todas las categorías del usuario para poblar el caché.
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

  // ── Conversión completa  ──────────────────────────────────────────────────

  Habit _rowToHabit(Map<String, dynamic> row) {
    final freq = _frequencyFromDb(
      row['frequency'] as String?,
      row['days_of_week'] as List<dynamic>?,
      (row['day_of_month'] as num?)?.toInt(),
    );

    // Busca la categoría por nombre en el caché. Si no la encuentra, usa la primera.
    final categoryName = row['categories']?['category_name'] as String?;
    HabitCategory category = HabitCategory.values.first;
    if (categoryName != null) {
      try {
        category = HabitCategory.values.firstWhere(
          (c) => c.label == categoryName,
        );
      } catch (_) {
        // Categoría desconocida: usar la primera por defecto.
      }
    }

    final colorHex = row['color'] as String?;

    return Habit(
      id: row['habit_id'] as String,
      name: row['habit_name'] as String,
      type: _typeFromDb(row['type'] as String),
      category: category,
      iconIndex: _indexForIconKey(row['icon_key'] as String),
      colorValue: colorHex != null
          ? _hexToColor(colorHex)
          : HabitCategory.values.first.hashCode,
      repeat: freq.repeat,
      days: freq.days,
      allDay: false,
      reminderTime: HabitReminderTime.manana,
      goalPerDay: 1,
      allowSkip: (row['allow_skip'] as bool?) ?? false,
      remindersEnabled: true,
      createdAt: DateTime.parse(row['created_date'] as String),
    );
  }

  // ── Implementación de HabitDataSource  ───────────────────────────────────

  @override
  Future<List<Habit>> getHabits() {
    return _request('No se pudieron cargar tus hábitos', () async {
      await _loadCategories();

      final rows = await _client
          .from('habits')
          .select('*, categories(category_name)')
          .eq('user_id', _userId)
          .isFilter('deleted_at', null)
          .order('created_at');

      return rows.map((r) => _rowToHabit(r)).toList();
    });
  }

  @override
  Future<Habit> createHabit(Habit habit) {
    return _request('No se pudo crear el hábito', () async {
      final categoryId = await _resolveCategoryId(habit.category);

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
            'created_date': isoDate(habit.createdAt),
            ...freqData,
          })
          .select('*, categories(category_name)')
          .single();

      return _rowToHabit(row);
    });
  }

  @override
  Future<Habit> updateHabit(Habit habit) {
    return _request('No se pudieron guardar los cambios', () async {
      final categoryId = await _resolveCategoryId(habit.category);
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
            ...freqData,
          })
          .eq('habit_id', habit.id)
          .eq('user_id', _userId)
          .select('*, categories(category_name)');

      if (rows.isEmpty) throw HabitNotFoundException(habit.id);
      return _rowToHabit(rows.first);
    });
  }

  @override
  Future<void> deleteHabit(String id) {
    return _request('No se pudo eliminar el hábito', () async {
      // Soft-delete: marcamos deleted_at.
      final rows = await _client
          .from('habits')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('habit_id', id)
          .eq('user_id', _userId)
          .select('habit_id');

      if (rows.isEmpty) throw HabitNotFoundException(id);
    });
  }

  // ── Utilidades  ───────────────────────────────────────────────────────────

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada');
    return user.id;
  }

  Future<T> _request<T>(
    String errorMessage,
    Future<T> Function() query,
  ) async {
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
