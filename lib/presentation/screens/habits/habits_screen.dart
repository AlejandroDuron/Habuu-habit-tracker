import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habits/habit_icon_picker.dart';
import '../../widgets/habits/habit_type_toggle.dart';
import 'habit_form_screen.dart';
 
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key, this.onBack});
 
  final VoidCallback? onBack;
 
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}
 
class _HabitsScreenState extends State<HabitsScreen> {
  // Lo único que es de esta pantalla es qué filtro está elegido.
  // Los hábitos en sí viven en el provider.
  HabitType _filter = HabitType.frecuente;
 
  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }
 
  void _openEdit(Habit habit) {
    // Abrimos "Editar Hábito" en el Navigator raíz para que tape el navbar,
    // igual que la pantalla de éxito. Al darle "Aceptar" se regresa aquí
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
    );
  }
 
  Future<bool> _confirmDelete(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: Text('Se borrará "${habit.name}" de tus hábitos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: HabuuTextColors.error,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
 
    if (confirmed != true || !mounted) return false;
 
    final provider = context.read<HabitsProvider>();
    final ok = await provider.deleteHabit(habit.id);
    if (!mounted) return ok;
 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Hábito borrado' : provider.errorMessage ?? 'Algo salió mal',
        ),
      ),
    );
    return ok;
  }
 
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    final habits = _filter == HabitType.frecuente
        ? provider.frequentHabits
        : provider.fleetingHabits;
 
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HabuuGradients.pond),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35, 24, 35, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(title: 'Tus Hábitos', onBack: _goBack),
                const SizedBox(height: 49),
                // Aquí el toggle no cambia el tipo de un hábito, solo
                // filtra qué lista se muestra
                HabitTypeToggle(
                  selected: _filter,
                  onChanged: (type) => setState(() => _filter = type),
                ),
                const SizedBox(height: 42),
                // Expanded porque la lista tiene que saber cuánto espacio
                // le queda debajo del toggle para poder hacer scroll
                Expanded(
                  child: _buildList(provider, habits),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildList(HabitsProvider provider, List<Habit> habits) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: HabuuColors.primary500),
      );
    }
 
    if (habits.isEmpty) {
      return _EmptyState(type: _filter);
    }
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: habits.length,
      onReorderItem: (oldIndex, newIndex) {
        context.read<HabitsProvider>().reorderHabits(
              _filter,
              oldIndex,
              newIndex,
            );
      },
      itemBuilder: (context, index) {
        final habit = habits[index];
        // Cada elemento necesita una key única para que flutter sepa cuál
        // se movió. Usamos el id del hábito, que nunca se repite
        return Dismissible(
          key: ValueKey(habit.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(habit),
          background: const _DeleteBackground(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _HabitListCard(
              habit: habit,
              index: index,
              onTap: () => _openEdit(habit),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
 
  final String title;
  final VoidCallback onBack;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Volver',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: HabuuIconColors.black,
            size: 22,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: HabuuText.h5ExtraBold.copyWith(
              color: HabuuTextColors.title,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _HabitListCard extends StatelessWidget {
  const _HabitListCard({
    required this.habit,
    required this.index,
    required this.onTap,
  });
 
  final Habit habit;
 
  /// Posición en la lista; la necesita el listener de arrastre
  final int index;
  final VoidCallback onTap;
 
  String get _subtitle {
    final times = habit.goalPerDay == 1 ? 'VEZ' : 'VECES';
    return '${habit.goalPerDay} $times AL DÍA · ${habit.category.label.toUpperCase()}';
  }
 
  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: HabuuColors.white100,
          borderRadius: BorderRadius.circular(HabuuRadius.sm),
          boxShadow: const [habuuCardShadow],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HabuuRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.25),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(
                    habitIconFor(habit.iconIndex),
                    size: 18,
                    color: HabuuIconColors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HabuuText.bodySmSemibold.copyWith(
                          color: HabuuColors.black100,
                        ),
                      ),
                      Text(
                        _subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HabuuText.captionSmMedium.copyWith(
                          color: HabuuColors.black40,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                ReorderableDragStartListener(
                  index: index,
                  child: Semantics(
                    label: 'Mover ${habit.name}',
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 18,
                        color: HabuuIconColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
/// Fondo rojo con basurero que se ve al deslizar una tarjeta
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Mismo espacio de abajo que la tarjeta, para que el rojo no se
      // meta en la separación
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: HabuuColors.error500,
          borderRadius: BorderRadius.circular(HabuuRadius.sm),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: HabuuIconColors.white,
        ),
      ),
    );
  }
}
 
/// Lo que se ve cuando todavía no hay hábitos de ese tipo
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type});
 
  final HabitType type;
 
  @override
  Widget build(BuildContext context) {
    final kind = type == HabitType.frecuente ? 'frecuentes' : 'fugaces';
    // SingleChildScrollView por si no cabe con letra grande
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/images/frog_mushroom.png',
            width: 77,
            height: 74,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes hábitos $kind',
            textAlign: TextAlign.center,
            style: HabuuText.bodyLgRegular.copyWith(
              color: HabuuTextColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }
}