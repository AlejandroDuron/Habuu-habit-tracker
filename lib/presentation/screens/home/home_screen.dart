import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme/tokens.dart';
import '../../widgets/shared/navbar.dart';

/// Pantalla Home de Habuu.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _days = [
    (day: '22', hasFrog: false, isToday: false),
    (day: '23', hasFrog: false, isToday: false),
    (day: '24', hasFrog: false, isToday: false),
    (day: '25', hasFrog: false, isToday: false),
    (day: '26', hasFrog: true, isToday: true),
    (day: '27', hasFrog: false, isToday: false),
    (day: '28', hasFrog: false, isToday: false),
    (day: '29', hasFrog: false, isToday: false),
    (day: '30', hasFrog: false, isToday: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const HabuuNavbar(selected: HabuuTab.home),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HabuuColors.primary50, HabuuColors.success200],
            stops: [0.21635, 1.0],
          ),
        ),
        // El contenido termina antes de la navbar y no se ve detrás de ella.
        child: Padding(
          padding: EdgeInsets.only(
            bottom: HabuuNavbar.bodyBottomInsetOf(context),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(35, 76, 35, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 23),
                _calendarPreview(),
                const SizedBox(height: 23),
                _sectionHeader('Retos'),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 9),
                  child: _HabitCard(
                    title: 'Correr',
                    progress: '500/2000 M',
                    loader: 'loader_correr',
                    doneIcon: 'done_reto',
                    avatars: 2,
                    extraFriends: 3,
                    progressFraction: 72 / 296,
                  ),
                ),
                const SizedBox(height: 10),
                _sectionHeader('Hábitos'),
                const SizedBox(height: 4),
                const _HabitCard(
                  title: 'Tomar Agua',
                  progress: '500/2000 ML',
                  loader: 'loader_agua',
                  avatars: 2,
                  extraFriends: 3,
                ),
                const SizedBox(height: 16),
                const _HabitCard(
                  title: 'Caminar',
                  progress: '9000/10000 PASOS',
                  loader: 'loader_caminar',
                  avatars: 2,
                ),
                const SizedBox(height: 16),
                const _HabitCard(
                  title: 'Regar Plantas',
                  progress: '2/5 VECES',
                  loader: 'loader_plantas',
                ),
                const SizedBox(height: 16),
                const _HabitCard(
                  title: 'Meditar',
                  progress: '26/30 MIN',
                  loader: 'loader_meditar',
                  avatars: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Text(
          'Bienvenido de nuevo',
          textAlign: TextAlign.center,
          style: HabuuText.h5ExtraBold.copyWith(color: HabuuColors.success800),
        ),
        const SizedBox(height: 7),
        Text(
          'Hora de regresar al estanque',
          textAlign: TextAlign.center,
          style: HabuuText.subtitleMdBold.copyWith(
            color: HabuuColors.success800,
          ),
        ),
      ],
    );
  }

  Widget _calendarPreview() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: HabuuColors.white40,
        border: Border.all(color: HabuuColors.primary200),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Hoy',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                height: 32 / 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Los días que no caben se cortan en el borde del contenedor.
          // El padding vertical deja espacio para la sombra de cada día.
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemCount: _days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _DayChip(
                day: _days[i].day,
                hasFrog: _days[i].hasFrog,
                isToday: _days[i].isToday,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _HeroSection(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Expanded(child: Text(title, style: HabuuText.subtitleSmMedium)),
        Text(
          'Mostrar',
          style: HabuuText.captionMdMedium.copyWith(
            color: HabuuColors.primary600,
          ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.hasFrog,
    required this.isToday,
  });

  final String day;
  final bool hasFrog;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isToday ? HabuuColors.success300 : HabuuColors.success0,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(2, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
              color: isToday ? Colors.white : Colors.black,
            ),
          ),
          if (hasFrog)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Image.asset(
                'assets/images/home/frog_small.png',
                width: 30,
                height: 27,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}

/// Ilustración de la rana en el estanque, con el fondo radial del diseño.
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 264,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const RadialGradient(
                  radius: 0.83,
                  colors: [
                    HabuuColors.info300,
                    Color(0xFFB1C7D5),
                    Color(0xFF8DC5D7),
                    HabuuColors.success300,
                  ],
                  stops: [0, 0.16827, 0.2524, 0.33654],
                ),
              ),
            ),
          ),
          // La imagen sobresale 9px a la izquierda y 11px a la derecha,
          // igual que en Figma (356×271 sobre un contenedor de 336×264).
          Positioned(
            left: -9,
            right: -11,
            top: 0,
            height: 271,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, c) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: c.maxWidth * -0.0465,
                      top: c.maxHeight * -0.0004,
                      width: c.maxWidth * 1.093,
                      height: c.maxHeight * 1.0763,
                      child: Image.asset(
                        'assets/images/home/frog_hero.png',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.title,
    required this.progress,
    required this.loader,
    this.doneIcon = 'done',
    this.avatars = 0,
    this.extraFriends = 0,
    this.progressFraction,
  });

  final String title;
  final String progress;
  final String loader;
  final String doneIcon;
  final int avatars;
  final int extraFriends;

  /// Si no es null, se dibuja la barra de progreso (tarjetas de reto).
  final double? progressFraction;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      // Las tarjetas de reto miden 79px: 11px extra abajo para la barra.
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        progressFraction != null ? 27 : 16,
      ),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [habuuCardShadow],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/home/$loader.svg',
            width: 36,
            height: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 36,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HabuuText.bodySmSemibold),
                  Text(
                    progress,
                    style: HabuuText.captionSmMedium.copyWith(
                      color: HabuuColors.black60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (avatars > 0 || extraFriends > 0) ...[
            _Friends(avatars: avatars, extra: extraFriends),
            const SizedBox(width: 12),
          ],
          SvgPicture.asset(
            'assets/icons/home/$doneIcon.svg',
            width: 36,
            height: 36,
          ),
          const SizedBox(width: 12),
          const _AddIcon(),
        ],
      ),
    );

    if (progressFraction == null) return card;

    return Stack(
      children: [
        card,
        Positioned(
          left: 31,
          right: 37,
          bottom: 10,
          height: 4,
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: HabuuColors.black10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: c.maxWidth * progressFraction!,
                  decoration: BoxDecoration(
                    color: HabuuColors.green700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Avatares superpuestos.
class _Friends extends StatelessWidget {
  const _Friends({required this.avatars, required this.extra});

  final int avatars;
  final int extra;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < avatars; i++)
        Image.asset(
          'assets/images/home/avatar_${i + 1}.png',
          width: 28,
          height: 28,
        ),
      if (extra > 0)
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HabuuColors.purple50,
            shape: BoxShape.circle,
            border: Border.all(color: HabuuColors.white100),
          ),
          child: Text(
            '+$extra',
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              height: 16 / 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: HabuuColors.success700,
            ),
          ),
        ),
    ];

    return SizedBox(
      width: 28 + (items.length - 1) * 20,
      height: 28,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(left: i * 20.0, child: items[i]),
        ],
      ),
    );
  }
}

class _AddIcon extends StatelessWidget {
  const _AddIcon();

  @override
  Widget build(BuildContext context) {
    // El SVG mide 19.5×19.75 y en Figma se desborda del slot de 18×18.
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -0.75,
            top: -1.75,
            child: SvgPicture.asset(
              'assets/icons/home/add.svg',
              width: 19.5,
              height: 19.75,
            ),
          ),
        ],
      ),
    );
  }
}
