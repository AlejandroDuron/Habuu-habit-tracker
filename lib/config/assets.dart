abstract final class AuthAssets {
  static const frogMain = 'assets/images/auth/frog_main.png';
  static const frogConfused = 'assets/images/auth/frog_confused.png';
  static const frogPolice = 'assets/images/auth/frog_police.png';
  static const frogHappy = 'assets/images/auth/frog_happy.png';
  static const frogPassword =
      'assets/images/auth/frog_police_password_green.png';

  static const apple = 'assets/icons/auth/apple.svg';
  static const microsoft = 'assets/icons/auth/microsoft.svg';
  static const google = 'assets/icons/auth/google.svg';
}

abstract final class HomeAssets {
  static const frogSmall = 'assets/images/home/frog_small.png';
  static const pond = 'assets/images/home/estanque.png';

  /// Froggy despierta es la misma de la pantalla de rachas.
  static const frogAwake = 'assets/images/calendar/streak_14.png';
  static const frogSleeping = 'assets/icons/pet_frog/froggy_sleeping.png';
  static const frogResting = 'assets/images/calendar/habuu_resting.png';

  static const add = 'assets/icons/home/add.svg';
  static const done = 'assets/icons/home/done.svg';
}

/// Íconos que se pueden elegir para un hábito.
/// La clave es lo que se guarda en la columna icon_key.
abstract final class HabitIconAssets {
  static const run = 'assets/icons/habits/run.svg';
  static const water = 'assets/icons/habits/water.svg';
  static const walk = 'assets/icons/habits/walk.svg';
  static const plants = 'assets/icons/habits/plants.svg';
  static const meditate = 'assets/icons/habits/meditate.svg';

  static const defaultKey = 'water';

  static const byKey = {
    'run': run,
    'water': water,
    'walk': walk,
    'plants': plants,
    'meditate': meditate,
  };

  /// Devuelve el ícono de esa clave, o el de por defecto si no existe.
  static String forKey(String? key) => byKey[key] ?? byKey[defaultKey]!;
}
