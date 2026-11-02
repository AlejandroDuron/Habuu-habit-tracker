import 'package:flutter/material.dart';
import '../../../config/theme/tokens.dart';

/// FAB circular para añadir un nuevo hábito.
/// Reutilizable en cualquier pantalla que lo necesite.
class AddHabitFab extends StatelessWidget {
  const AddHabitFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: HabuuColors.primary50,
        elevation: 2,
        shape: const CircleBorder(),
        tooltip: 'Añadir hábito',
        child: const Icon(
          Icons.add,
          color: HabuuColors.primary500,
          size: 32,
        ),
      ),
    );
  }
}
