import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/habit.dart';
import 'reminder_plan.dart';

/// Lo único que el provider necesita saber de los recordatorios
abstract interface class HabitReminderScheduler {
  /// Programa los avisos de un hábito según su hora y días elegidos. Si ya había avisos, los borra primero
  Future<void> scheduleFor(Habit habit);

  /// Quita todos los avisos de un hábito, por ejemplo al borrarlo
  Future<void> cancelFor(String habitId);
}

class LocalNotificationService implements HabitReminderScheduler {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'habit_reminders',
      'Recordatorios de hábitos',
      channelDescription: 'Avisos para cumplir tus hábitos a la hora elegida',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Se llama una vez en main(), antes de runApp
  Future<void> init() async {
    if (_ready) return;

    tz.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (e) {

      debugPrint('No se pudo leer la zona horaria: $e');
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        // El ícono de la notificación en Android es el de la app
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // En iOS el permiso lo pedimos aparte con requestPermission().
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Muestra el diálogo del sistema "¿Permitir notificaciones?".
  /// En Android 13+ y en iOS es obligatorio, en versiones viejas no hace nada
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> scheduleFor(Habit habit) async {
    if (!_ready) return;

    // Primero borramos los avisos viejos, porque si el usuario cambió la hora o
    // los días, no queremos que sigan sonando los de antes
    await cancelFor(habit.id);

    final plan = planReminders(habit, now: DateTime.now());
    for (final reminder in plan) {
      final date = reminder.firstDate;
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: '🐸 ${habit.name}',
        body: 'Meta de hoy: ${habit.goalLabel.toLowerCase()}',
        scheduledDate: tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          date.hour,
          date.minute,
        ),
        notificationDetails: _details,

        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: switch (reminder.repeat) {
          ReminderRepeat.once => null,
          ReminderRepeat.daily => DateTimeComponents.time,
          ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
          ReminderRepeat.monthly => DateTimeComponents.dayOfMonthAndTime,
        },
      );
    }
  }

  @override
  Future<void> cancelFor(String habitId) async {
    if (!_ready) return;
    final base = reminderBaseId(habitId);
    for (var i = 0; i < maxRemindersPerHabit; i++) {
      await _plugin.cancel(id: base + i);
    }
  }
}