import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
 
class HabitCategoryChips extends StatelessWidget {
  const HabitCategoryChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onAddNew,
  });
 
  final HabitCategory selected;
  final ValueChanged<HabitCategory> onChanged;
  /// Lo dejamos opcional porque crear categorías propias todavía no está
  /// en el modelo; así el chip aparece solo cuando exista esa función
  final VoidCallback? onAddNew;
 
  static const double height = 40;
 
  @override
  Widget build(BuildContext context) {
    const categories = HabitCategory.values;
    final showAddNew = onAddNew != null;
    final itemCount = categories.length + (showAddNew ? 1 : 0);
 
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // El último lugar es para agergar una nueva, si existiera
          if (index == categories.length) {
            return _CategoryChip(
              label: 'Agregar Nueva',
              isSelected: false,
              onTap: onAddNew!,
            );
          }
 
          final category = categories[index];
          return _CategoryChip(
            label: category.label,
            isSelected: category == selected,
            onTap: () => onChanged(category),
          );
        },
      ),
    );
  }
}
 
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
 
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HabuuRadius.lg);
 
    // En Figma ningún chip aparece seleccionado, así que para que el usuario
    // vea cuál eligió lo pintamos con el verde principal y texto blanco
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? HabuuColors.primary500 : HabuuColors.success0,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                label,
                style: HabuuText.buttonMedium.copyWith(
                  color: isSelected
                      ? HabuuTextColors.primaryWhite
                      : HabuuColors.primary700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}