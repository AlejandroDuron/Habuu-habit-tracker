import '../../../config/assets.dart';

/// Lo que necesita una HabitCard para dibujarse.
/// Sirve tanto para hábitos como para retos.
class HabitCardData {
  const HabitCardData({
    required this.title,
    required this.progressLabel,
    required this.loaderIcon,
    this.doneIcon = HomeAssets.done,
    this.avatars = 0,
    this.extraFriends = 0,
    this.progressFraction,
  }) : assert(
         progressFraction == null ||
             (progressFraction >= 0 && progressFraction <= 1),
         'El progreso va de 0 a 1',
       );

  final String title;

  /// Texto debajo del título, por ejemplo "500/2000 ML".
  final String progressLabel;

  final String loaderIcon;
  final String doneIcon;

  /// Cuántos avatares de amigos se muestran.
  final int avatars;

  /// Amigos que no caben, se muestran como "+N".
  final int extraFriends;

  /// Si no es null, se dibuja la barra de progreso (tarjetas de reto).
  final double? progressFraction;

  bool get hasFriends => avatars > 0 || extraFriends > 0;
  bool get hasProgressBar => progressFraction != null;
}
