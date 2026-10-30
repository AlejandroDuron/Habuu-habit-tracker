abstract final class AuthAssets {
  static const frogMain = 'assets/images/auth/frog_main.png';
  static const frogConfused = 'assets/images/auth/frog_confused.png';
  static const frogPolice = 'assets/images/auth/frog_police.png';
  static const frogHappy = 'assets/images/auth/frog_happy.png';
  static const frogPassword = 'assets/images/auth/frog_police_password_green.png';

  static const apple = 'assets/icons/auth/apple.svg';
  static const microsoft = 'assets/icons/auth/microsoft.svg';
  static const google = 'assets/icons/auth/google.svg';
}

abstract final class HomeAssets {
  static const frogSmall = 'assets/images/home/frog_small.png';
  static const frogHero = 'assets/images/home/frog_hero.png';

  static const add = 'assets/icons/home/add.svg';
  static const done = 'assets/icons/home/done.svg';
  static const doneChallenge = 'assets/icons/home/done_reto.svg';

  static const loaderRun = 'assets/icons/home/loader_correr.svg';
  static const loaderWater = 'assets/icons/home/loader_agua.svg';
  static const loaderWalk = 'assets/icons/home/loader_caminar.svg';
  static const loaderPlants = 'assets/icons/home/loader_plantas.svg';
  static const loaderMeditate = 'assets/icons/home/loader_meditar.svg';

  /// Avatares de ejemplo: avatar_1.png, avatar_2.png...
  static String avatar(int number) => 'assets/images/home/avatar_$number.png';
}
