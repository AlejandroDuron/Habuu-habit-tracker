import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
 
class HabitCategoryChips extends StatelessWidget {
  const HabitCategoryChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.customCategories = const [],
    this.onAddNew,
  });
 
  final HabitCategory selected;

  /// Categorías personalizadas creadas por el usuario (nombres).
  /// Se muestran después de las predefinidas y se seleccionan por su label.
  final List<String> customCategories;

  final ValueChanged<String> onChanged;

  /// Se llama cuando el usuario toca "Agregar Nueva".
  /// La pantalla es responsable de mostrar el diálogo y registrar la categoría.
  final VoidCallback? onAddNew;
 
  static const double height = 40;
 
  @override
  Widget build(BuildContext context) {
    final predefined = HabitCategory.values;
    final showAddNew = onAddNew != null;
    final itemCount =
        predefined.length + customCategories.length + (showAddNew ? 1 : 0);
 
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // El último lugar es para agregar una nueva categoría.
          if (index == predefined.length + customCategories.length) {
            return _CategoryChip(
              label: '＋ Agregar',
              isSelected: false,
              onTap: onAddNew!,
            );
          }
 
          // Primero las categorías predefinidas.
          if (index < predefined.length) {
            final category = predefined[index];
            return _CategoryChip(
              label: category.label,
              isSelected: category.label == _selectedLabel,
              onTap: () => onChanged(category.label),
            );
          }
 
          // Luego las personalizadas.
          final customLabel = customCategories[index - predefined.length];
          return _CategoryChip(
            label: customLabel,
            isSelected: customLabel == _selectedLabel,
            onTap: () => onChanged(customLabel),
          );
        },
      ),
    );
  }

  /// El label de la categoría seleccionada, comparando por label en string.
  String get _selectedLabel => selected.label;
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