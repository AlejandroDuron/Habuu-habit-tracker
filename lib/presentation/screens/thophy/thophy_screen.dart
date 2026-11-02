import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/models/trophy.dart';
import '../../providers/trophies_provider.dart';
import '../../widgets/thophies/trophy_card.dart';

/// Mapeo de trophy_key → ruta del asset de imagen.
String _imageForKey(String? key) {
  const map = {
    'day_completed': 'assets/images/calendar/day_completed.png',
    'streak_7': 'assets/images/calendar/streak_7.png',
    'new_habits': 'assets/images/calendar/new_habits.png',
    'streak_14': 'assets/images/calendar/streak_14.png',
    'discipline': 'assets/images/calendar/discipline.png',
    'one_month': 'assets/images/calendar/one_month.png',
    'streak_300': 'assets/images/calendar/streak_300.png',
  };
  return map[key] ?? 'assets/images/calendar/day_completed.png';
}

class TrophiesScreen extends StatefulWidget {
  const TrophiesScreen({super.key});

  @override
  State<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends State<TrophiesScreen> {
  static const Color _textDark = HabuuColors.success800;

  @override
  void initState() {
    super.initState();
    // Carga los trofeos al abrir la pantalla si aún no se han cargado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrophiesProvider>().loadTrophies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrophiesProvider>();

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

                if (provider.isLoading) ...[
                  const SizedBox(height: 80),
                  const Center(
                    child: CircularProgressIndicator(
                      color: HabuuColors.success700,
                    ),
                  ),
                ] else if (provider.status == TrophiesStatus.error) ...[
                  const SizedBox(height: 80),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          provider.errorMessage ?? 'Algo salió mal',
                          style: HabuuText.bodySmMedium.copyWith(
                            color: _textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<TrophiesProvider>().loadTrophies(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HabuuColors.success700,
                            foregroundColor: HabuuColors.white100,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _SectionTitle('Trofeos ganados'),
                  const SizedBox(height: 16),
                  if (provider.earned.isEmpty)
                    Text(
                      'Aún no has ganado trofeos. ¡Sigue así!',
                      style: HabuuText.bodySmMedium.copyWith(
                        color: _textDark.withValues(alpha: 0.7),
                      ),
                    )
                  else
                    _TrophyGrid(
                      trophies: provider.earned
                          .map((e) => (e.trophy, false))
                          .toList(),
                    ),
                  const SizedBox(height: 32),
                  _SectionTitle('Trofeos por ganar'),
                  const SizedBox(height: 16),
                  if (provider.locked.isEmpty)
                    Text(
                      '¡Ya ganaste todos los trofeos!',
                      style: HabuuText.bodySmMedium.copyWith(
                        color: _textDark.withValues(alpha: 0.7),
                      ),
                    )
                  else
                    _TrophyGrid(
                      trophies: provider.locked
                          .map((t) => (t, true))
                          .toList(),
                    ),
                ],
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

/// Cuadrícula de 3 columnas. Recibe tuplas (Trophy, locked).
class _TrophyGrid extends StatelessWidget {
  const _TrophyGrid({required this.trophies});

  final List<(Trophy, bool)> trophies;

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
            for (final (trophy, locked) in trophies)
              SizedBox(
                width: itemWidth,
                child: TrophyCard(
                  title: trophy.name,
                  imagePath: _imageForKey(trophy.key),
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
