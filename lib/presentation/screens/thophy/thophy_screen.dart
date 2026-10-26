import 'package:flutter/material.dart';
import '../../widgets/thophies/trophy_card.dart'; 
import '../../../config/theme/tokens.dart';

class _Trophy {
  const _Trophy(this.title, this.imagePath);
  final String title;
  final String imagePath;
}

class TrophiesScreen extends StatelessWidget {
  const TrophiesScreen({super.key});

  static const Color _textDark = HabuuColors.success800;

  // TODO: reemplazar por datos reales
  static const _earned = [
    _Trophy('Día completado', 'assets/images/frog_mushroom.png'),
  ];

  static const _locked = [
    _Trophy('7 días de racha', 'assets/images/frog_mushroom.png'),
    _Trophy('Hábitos nuevos', 'assets/images/frog_mushroom.png'),
    _Trophy('14+ rachas', 'assets/images/frog_mushroom.png'),
    _Trophy('Disciplina', 'assets/images/frog_mushroom.png'),
    _Trophy('1+ mes con Habuu', 'assets/images/frog_mushroom.png'),
    _Trophy('300 rachas', 'assets/images/frog_mushroom.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HabuuGradients.mintToSky),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _textDark, size: 22),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Volver',
                ),
                const SizedBox(height: 8),
                _SectionTitle('Trofeos ganados'),
                const SizedBox(height: 16),
                _TrophyGrid(trophies: _earned),
                const SizedBox(height: 32),
                _SectionTitle('Trofeos por ganar'),
                const SizedBox(height: 16),
                _TrophyGrid(trophies: _locked, locked: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: HabuuText.h5ExtraBold.copyWith(
        fontSize: 22,
        color: HabuuColors.success800,
      ),
    );
  }
}

/// Cuadrícula de 3 columnas con alturas flexibles (los títulos pueden
/// ocupar una o dos líneas).
class _TrophyGrid extends StatelessWidget {
  const _TrophyGrid({required this.trophies, this.locked = false});

  final List<_Trophy> trophies;
  final bool locked;

  static const int _columns = 3;
  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: 16,
          children: [
            for (final t in trophies)
              SizedBox(
                width: itemWidth,
                child: TrophyCard(
                  title: t.title,
                  imagePath: t.imagePath,
                  size: itemWidth,
                  locked: locked,
                ),
              ),
          ],
        );
      },
    );
  }
}