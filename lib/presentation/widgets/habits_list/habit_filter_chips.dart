import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../providers/habits_provider.dart';

/// Una sola fila: Todo · Frecuente · Fugaz · Omitidos | categorías...
/// Tipo y categoría se pueden combinar. Tocar un chip activo lo desactiva.
class HabitFilterChips extends StatelessWidget {
  const HabitFilterChips({
    super.key,
    required this.chipFilter,
    required this.categoryFilter,
    required this.categories,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onReset,
  });

  final HabitChipFilter chipFilter;
  final String? categoryFilter;
  final List<String> categories; // sin "Todo"
  final ValueChanged<HabitChipFilter> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onReset;

  static const _types = [
    ('Frecuente', HabitChipFilter.frequent),
    ('Fugaz', HabitChipFilter.fleeting),
  ];

  @override
  Widget build(BuildContext context) {
    final noFilters =
        chipFilter == HabitChipFilter.all && categoryFilter == null;

    final items = <Widget>[
      _Chip(label: 'Todo', selected: noFilters, onTap: onReset),
      for (final (label, filter) in _types)
        _Chip(
          label: label,
          selected: chipFilter == filter,
          onTap: () => onTypeChanged(
            chipFilter == filter ? HabitChipFilter.all : filter,
          ),
        ),
      if (categories.isNotEmpty)
        Center(
          child: Container(
            width: 1,
            height: 18,
            color: HabuuColors.primary500.withValues(alpha: 0.3),
          ),
        ),
      for (final cat in categories)
        _Chip(
          label: cat,
          selected: categoryFilter == cat,
          onTap: () => onCategoryChanged(categoryFilter == cat ? null : cat),
        ),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? HabuuColors.primary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: HabuuText.bodySmSemibold.copyWith(
            color: selected ? HabuuColors.white100 : HabuuColors.primary500,
          ),
        ),
      ),
    );
  }
}