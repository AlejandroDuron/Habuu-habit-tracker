import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
 
import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habits/habit_category_chips.dart';
import '../../widgets/habits/habit_color_picker.dart';
import '../../widgets/habits/habit_day_picker.dart';
import '../../widgets/habits/habit_icon_picker.dart';
import '../../widgets/habits/habit_segmented_control.dart';
import '../../widgets/habits/habit_switch_row.dart';
import '../../widgets/habits/habit_type_toggle.dart';
import 'habit_success_screen.dart';
 
class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({
    super.key,
    this.habit,
    this.onBack,
    this.onSaved,
  });

  final Habit? habit;
 
  /// Qué hacer con la flecha de regresar. Cuando la pantalla vive en la
  /// pestaña "+" del navbar no hay nada atrás en el Navigator, así que el
  /// shell nos dice qué hacer.
  /// Si es null, usamos Navigator.maybePop.
  final VoidCallback? onBack;
 
  /// Se llama después de crear un hábito y cerrar el mensaje de éxito
  final VoidCallback? onSaved;
 
  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}
 
class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
 
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  final _goalFocus = FocusNode();
 
  // Estado local del formulario
  late HabitType _type;
  late HabitCategory _category;
  late int _iconIndex;
  late int _colorValue;
  late HabitRepeat _repeat;
  late Set<int> _days;
  late bool _allDay;
  late HabitReminderTime _reminderTime;
  late bool _allowSkip;
  late bool _remindersEnabled;
 
  bool _isSaving = false;
 
  bool get _isEditing => widget.habit != null;
 
  @override
  void initState() {
    super.initState();
    // Los controladores se crean una sola vez aquí
    _nameController = TextEditingController();
    _goalController = TextEditingController();
    _loadValues(widget.habit);
  }

  void _loadValues(Habit? habit) {
    _nameController.text = habit?.name ?? '';
    _goalController.text = '${habit?.goalPerDay ?? 1}';
    _type = habit?.type ?? HabitType.frecuente;
    _category = habit?.category ?? HabitCategory.values.first;
    _iconIndex = habit?.iconIndex ?? 0;
    _colorValue = habit?.colorValue ?? habitColorOptions.first.toARGB32();
    _repeat = habit?.repeat ?? HabitRepeat.diariamente;
    _days = {...?habit?.days};
    _allDay = habit?.allDay ?? true;
    _reminderTime = habit?.reminderTime ?? HabitReminderTime.manana;
    _allowSkip = habit?.allowSkip ?? false;
    _remindersEnabled = habit?.remindersEnabled ?? true;
  }
 
  @override
  void dispose() {
    // Todo lo que se creó en initState se libera aquí
    _nameController.dispose();
    _goalController.dispose();
    _goalFocus.dispose();
    super.dispose();
  }

 
  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'Escribe el nombre del hábito';
    if (name.length < 3) return 'Escribe al menos 3 caracteres';
    if (name.length > 40) return 'Máximo 40 caracteres';
    return null;
  }
 
  String? _validateGoal(String? value) {
    // tryParse devuelve null si no es número. No usamos "?? 0" porque eso
    // escondería el error
    final goal = int.tryParse((value ?? '').trim());
    if (goal == null) return 'Escribe un número';
    if (goal < 1) return 'La meta tiene que ser al menos 1';
    if (goal > 99) return 'La meta máxima es 99 veces al día';
    return null;
  }
 
  String? _validateDays(Set<int>? days) {
    // Solo los hábitos frecuentes que se repiten por semana necesitan días
    final needsDays =
        _type == HabitType.frecuente && _repeat == HabitRepeat.semanalmente;
    if (needsDays && (days == null || days.isEmpty)) {
      return 'Elige al menos un día de la semana';
    }
    return null;
  }
 
  // Guardar
 
  Habit _buildHabit() {
    final isFrequent = _type == HabitType.frecuente;
 
    return Habit(
      // Si es nuevo, el id lo pone el data source al guardarlo.
      id: widget.habit?.id ?? '',
      name: _nameController.text.trim(),
      type: _type,
      category: _category,
      iconIndex: _iconIndex,
      colorValue: _colorValue,
      // Un hábito fugaz no se repite ni tiene días
      repeat: isFrequent ? _repeat : null,
      days: isFrequent ? _days : const {},
      allDay: _allDay,
      reminderTime: _reminderTime,
      goalPerDay: int.parse(_goalController.text.trim()),
      allowSkip: _allowSkip,
      remindersEnabled: _remindersEnabled,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
    );
  }
 
  Future<void> _save() async {
    // Primero validamos todo el formulario; si algo falla no se guarda
    if (!_formKey.currentState!.validate()) return;
 
    // Cerramos el teclado antes de navegar
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final provider = context.read<HabitsProvider>();
    final habit = _buildHabit();
    final ok = _isEditing
        ? await provider.updateHabit(habit)
        : await provider.addHabit(habit);
 
    // Después de un await la pantalla pudo haberse cerrado. Si ya no está
    // montada, no tocamos nada
    if (!mounted) return;
    setState(() => _isSaving = false);
 
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Algo salió mal'),
        ),
      );
      return;
    }
 
    if (_isEditing) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HabitSuccessScreen(
            message: 'Hábito actualizado correctamente',
          ),
        ),
      );
      return;
    }
 
    // Al crear usamos el Navigator raíz para que la pantalla de éxito tape
    // también el navbar
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const HabitSuccessScreen(
          message: 'Hábito creado correctamente',
        ),
      ),
    );
 
    if (!mounted) return;
    // Dejamos el formulario limpio para el siguiente hábito.
    // Primero reset() y después cargamos los valores por defecto; al revés, reset() nos
    // borraría el "1" de la meta
    _formKey.currentState?.reset();
    setState(() => _loadValues(null));
    widget.onSaved?.call();
  }
 
  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  // Interfaz
 
  @override
  Widget build(BuildContext context) {
    final isFrequent = _type == HabitType.frecuente;
 
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HabuuGradients.pond),
        child: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(35, 24, 35, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    title: _isEditing ? 'Editar Hábito' : 'Nuevo Hábito',
                    onBack: _goBack,
                  ),
                  const SizedBox(height: 33),
                  Center(
                    child: Image.asset(
                      'assets/images/frog_mushroom.png',
                      width: 77,
                      height: 74,
                      fit: BoxFit.contain,
                    ),
                  ),

                  if (!_isEditing) ...[
                    const SizedBox(height: 33),
                    HabitTypeToggle(
                      selected: _type,
                      onChanged: (type) => setState(() => _type = type),
                    ),
                  ],
 
                  const SizedBox(height: 33),
                  _Section(
                    label: _isEditing
                        ? 'Nuevo Nombre del Hábito'
                        : 'Nombre del Hábito',
                    gap: 8,
                    child: TextFormField(
                      controller: _nameController,
                      validator: _validateName,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _goalFocus.requestFocus(),
                      style: HabuuText.bodyLgRegular.copyWith(
                        color: HabuuTextColors.primaryBlack,
                      ),
                      decoration: _inputDecoration(hint: 'Ej. Tomar agua'),
                    ),
                  ),
 
                  const SizedBox(height: 33),
                  _Section(
                    label: 'Categoría',
                    gap: 16,
                    child: HabitCategoryChips(
                      selected: _category,
                      onChanged: (c) => setState(() => _category = c),
                    ),
                  ),
 
                  const SizedBox(height: 33),
                  _Section(
                    label: 'Iconos',
                    gap: 18,
                    child: HabitIconPicker(
                      selectedIndex: _iconIndex,
                      onChanged: (i) => setState(() => _iconIndex = i),
                    ),
                  ),
 
                  const SizedBox(height: 33),
                  _Section(
                    label: 'Color',
                    gap: 29,
                    child: HabitColorPicker(
                      selectedColorValue: _colorValue,
                      onChanged: (c) => setState(() => _colorValue = c),
                    ),
                  ),
 
                  // "Repetir" y "En este día" solo existen para los
                  // hábitos frecuentes
                  if (isFrequent) ...[
                    const SizedBox(height: 33),
                    _Section(
                      label: 'Repetir',
                      gap: 16,
                      child: HabitSegmentedControl<HabitRepeat>(
                        options: HabitRepeat.values,
                        selected: _repeat,
                        labelOf: (r) => r.label,
                        onChanged: (r) => setState(() => _repeat = r),
                      ),
                    ),
                    const SizedBox(height: 33),
                    // FormField nos deja validar algo que no es un campo de texto
                    FormField<Set<int>>(
                      initialValue: _days,
                      validator: _validateDays,
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HabitDayPicker(
                            selectedDays: _days,
                            onDaysChanged: (days) {
                              setState(() => _days = days);
                              field.didChange(days);
                            },
                            allDay: _allDay,
                            onAllDayChanged: (v) =>
                                setState(() => _allDay = v),
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                field.errorText!,
                                style: HabuuText.captionMdMedium.copyWith(
                                  color: HabuuTextColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
 
                  const SizedBox(height: 33),
                  _Section(
                    label: 'Recordar',
                    gap: 18,
                    child: HabitSegmentedControl<HabitReminderTime>(
                      options: HabitReminderTime.values,
                      selected: _reminderTime,
                      labelOf: (t) => t.label,
                      onChanged: (t) => setState(() => _reminderTime = t),
                    ),
                  ),
 
                  const SizedBox(height: 33),
                  _Section(
                    label: 'Meta',
                    gap: 9,
                    child: TextFormField(
                      controller: _goalController,
                      focusNode: _goalFocus,
                      validator: _validateGoal,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      // Solo deja escribir números
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      style: HabuuText.bodyLgRegular.copyWith(
                        color: HabuuTextColors.primaryBlack,
                      ),
                      decoration: _inputDecoration(
                        prefixIcon: const Icon(
                          Icons.edit_outlined,
                          color: HabuuIconColors.black,
                        ),
                        suffixText: 'vez o más al día',
                        padding: 16,
                      ),
                    ),
                  ),
 
                  const SizedBox(height: 33),
                  HabitSwitchRow(
                    label: 'Permitir omitir hábito',
                    value: _allowSkip,
                    onChanged: (v) => setState(() => _allowSkip = v),
                  ),
                  const SizedBox(height: 22),
                  HabitSwitchRow(
                    label: 'Activar Recordatorios',
                    value: _remindersEnabled,
                    onChanged: (v) => setState(() => _remindersEnabled = v),
                  ),
 
                  const SizedBox(height: 47),
                  Center(
                    child: _SaveButton(
                      label: _isEditing ? 'Guardar cambios' : 'Guardar',
                      width: _isEditing ? 224 : 190,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? prefixIcon,
    String? suffixText,
    double padding = 12,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(HabuuRadius.sm),
          borderSide: BorderSide(color: color, width: 1.5),
        );
 
    return InputDecoration(
      filled: true,
      fillColor: HabuuColors.success0,
      hintText: hint,
      hintStyle: HabuuText.bodyLgRegular.copyWith(
        color: HabuuTextColors.tertiaryGrey,
      ),
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      suffixStyle: HabuuText.bodyLgRegular.copyWith(
        color: HabuuTextColors.primaryBlack,
      ),
      contentPadding: EdgeInsets.all(padding),
      enabledBorder: border(HabuuColors.primary500),
      focusedBorder: border(HabuuColors.primary600),
      errorBorder: border(HabuuColors.error500),
      focusedErrorBorder: border(HabuuColors.error500),
      errorStyle: HabuuText.captionMdMedium.copyWith(
        color: HabuuTextColors.error,
      ),
    );
  }
}
 
/// Flecha de regresar + título centrado
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
        // Espacio del mismo ancho que la flecha para que el título quede
        // centrado de verdad
        const SizedBox(width: 48),
      ],
    );
  }
}
 
class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.gap,
    required this.child,
  });
 
  final String label;
  final double gap;
  final Widget child;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: HabuuText.subtitleSmMedium.copyWith(
            color: HabuuTextColors.primaryBlack,
          ),
        ),
        SizedBox(height: gap),
        child,
      ],
    );
  }
}
 
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.width,
    required this.isLoading,
    required this.onPressed,
  });
 
  final String label;
  final double width;
  final bool isLoading;
  final VoidCallback onPressed;
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: ElevatedButton(
        // Mientras guarda, el botón se desactiva para que no se cree el
        // mismo hábito dos veces por un doble toque
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: HabuuColors.primary500,
          foregroundColor: HabuuColors.white100,
          disabledBackgroundColor: HabuuColors.primary300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HabuuRadius.sm),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: HabuuColors.white100,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: HabuuText.buttonGiant.copyWith(
                    color: HabuuTextColors.primaryWhite,
                  ),
                ),
              ),
      ),
    );
  }
}