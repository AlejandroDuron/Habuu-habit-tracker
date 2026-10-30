import '../../../config/assets.dart';
import '../../models/home/calendar_day.dart';
import '../../models/home/habit_card_data.dart';

/// Datos de ejemplo del Home.
/// Cuando haya backend, esto se reemplaza por un provider
/// y los widgets no cambian porque reciben los mismos modelos.
abstract final class HomeMockData {
  static const days = [
    CalendarDay(day: '22'),
    CalendarDay(day: '23'),
    CalendarDay(day: '24'),
    CalendarDay(day: '25'),
    CalendarDay(day: '26', hasFrog: true, isToday: true),
    CalendarDay(day: '27'),
    CalendarDay(day: '28'),
    CalendarDay(day: '29'),
    CalendarDay(day: '30'),
  ];

  static const challenges = [
    HabitCardData(
      title: 'Correr',
      progressLabel: '500/2000 M',
      loaderIcon: HomeAssets.loaderRun,
      doneIcon: HomeAssets.doneChallenge,
      avatars: 2,
      extraFriends: 3,
      progressFraction: 72 / 296,
    ),
  ];

  static const habits = [
    HabitCardData(
      title: 'Tomar Agua',
      progressLabel: '500/2000 ML',
      loaderIcon: HomeAssets.loaderWater,
      avatars: 2,
      extraFriends: 3,
    ),
    HabitCardData(
      title: 'Caminar',
      progressLabel: '9000/10000 PASOS',
      loaderIcon: HomeAssets.loaderWalk,
      avatars: 2,
    ),
    HabitCardData(
      title: 'Regar Plantas',
      progressLabel: '2/5 VECES',
      loaderIcon: HomeAssets.loaderPlants,
    ),
    HabitCardData(
      title: 'Meditar',
      progressLabel: '26/30 MIN',
      loaderIcon: HomeAssets.loaderMeditate,
      avatars: 1,
    ),
  ];
}
