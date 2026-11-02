import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../../data/models/habit.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habits/habit_category_chips.dart';
import '../../widgets/habits/habit_color_picker.dart';
import '../../widgets/habits/habit_day_picker.dart';
import '../../widgets/habits/habit_icon_picker.dart';
import '../../widgets/habits/habit_month_day_picker.dart';
import '../../widgets/habits/habit_segmented_control.dart';
import '../../widgets/habits/habit_switch_row.dart';
import '../../widgets/habits/habit_time_picker.dart';
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
  final VoidCallback? onBack;
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
  late TimeOfDay? _reminderTime;
  late bool _allowSkip;
  late bool _remindersEnabled;

  /// Label de la categoría seleccionada (predefinida o personalizada).
  /// Se usa para comparar con los chips que ahora trabajan con strings.
  String _categoryLabel = '';

  /// Categorías personalizadas creadas por el usuario en esta sesión.
  final List<String> _customCategories = [];

  bool _isSaving = false;

  bool get _isEditing => widget.habit != null;

  // ── Expresiones regulares (con soporte Unicode: tildes, ñ, etc.) ──────────

  /// Letras, números, espacios y signos básicos de puntuación.
  static final RegExp _nameAllowedChars =
      RegExp(r"^[\p{L}\p{N} .,'’\-()!?¡¿&]+$", unicode: true);

  /// Letras, números y espacios (para categorías).
  static final RegExp _categoryAllowedChars =
      RegExp(r'^[\p{L}\p{N} ]+$', unicode: true);

  static final RegExp _hasLetter = RegExp(r'\p{L}', unicode: true);
  static final RegExp _onlyDigits = RegExp(r'^\d+$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _goalController = TextEditingController();
    _loadValues(widget.habit);
  }

  void _loadValues(Habit? habit) {
    _nameController.text = habit?.name ?? '';
    _goalController.text = '${habit?.goalPerDay ?? 1}';
    _type = habit?.type ?? HabitType.frecuente;
    _category = habit?.category ?? HabitCategory.values.first;
    _categoryLabel = habit?.categoryLabel ?? _category.label;
    _iconIndex = habit?.iconIndex ?? 0;
    _colorValue = habit?.colorValue ?? habitColorOptions.first.toARGB32();
    _repeat = habit?.repeat ?? HabitRepeat.diariamente;
    _days = {...?habit?.days};
    _allDay = habit?.allDay ?? true;
    // Convierte el record del modelo a TimeOfDay.
    final rt = habit?.reminderTime;
    _reminderTime =
        rt != null ? TimeOfDay(hour: rt.hour, minute: rt.minute) : null;
    _allowSkip = habit?.allowSkip ?? false;
    _remindersEnabled = habit?.remindersEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _goalFocus.dispose();
    super.dispose();
  }

  // ── Validaciones ──────────────────────────────────────────────────────────

  /// Quita espacios al inicio/fin y colapsa espacios repetidos.
  String _normalize(String? value) =>
      (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');

  String? _validateName(String? value) {
    final name = _normalize(value);
    if (name.isEmpty) return 'Escribe el nombre del hábito';
    if (name.length < 3) return 'Escribe al menos 3 caracteres';
    if (name.length > 40) return 'Máximo 40 caracteres';
    if (!_hasLetter.hasMatch(name)) {
      return 'El nombre debe incluir al menos una letra';
    }
    if (!_nameAllowedChars.hasMatch(name)) {
      return 'Usa solo letras, números y signos básicos';
    }
    return null;
  }

  String? _validateGoal(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Escribe la meta diaria';
    if (!_onlyDigits.hasMatch(text)) return 'Solo se permiten números enteros';
    final goal = int.tryParse(text);
    if (goal == null) return 'Escribe un número válido';
    if (goal < 1) return 'La meta tiene que ser al menos 1';
    if (goal > 99) return 'La meta máxima es 99 veces al día';
    return null;
  }

  /// Días de la semana (solo aplica a hábitos frecuentes semanales).
  String? _validateDays(Set<int>? days) {
    final needsDays =
        _type == HabitType.frecuente && _repeat == HabitRepeat.semanalmente;
    if (needsDays && (days == null || days.isEmpty)) {
      return 'Elige al menos un día de la semana';
    }
    return null;
  }

  /// Día del mes (solo aplica a hábitos frecuentes mensuales).
  String? _validateMonthDay() {
    final needsDay =
        _type == HabitType.frecuente && _repeat == HabitRepeat.mensualmente;
    if (!needsDay) return null;
    if (_days.isEmpty) return 'Selecciona un día del mes';
    final day = _days.first;
    if (day < 1 || day > 31) return 'El día del mes debe ser entre 1 y 31';
    return null;
  }

  /// La hora es obligatoria cuando los recordatorios están activados.
  String? _validateReminderTime() {
    if (!_remindersEnabled) return null;
    final time = _reminderTime;
    if (time == null) return 'Elige la hora del recordatorio';
    if (time.hour < 0 || time.hour > 23 || time.minute < 0 || time.minute > 59) {
      return 'La hora no es válida';
    }
    return null;
  }

  String? _validateCategory() {
    if (_categoryLabel.trim().isEmpty) return 'Elige una categoría';
    return null;
  }

  /// Red de seguridad final antes de guardar.
  String? _validateSchedule() {
    if (_type == HabitType.fugaz) return null;

    switch (_repeat) {
      case HabitRepeat.diariamente:
        return null;
      case HabitRepeat.semanalmente:
        return _validateDays(_days);
      case HabitRepeat.mensualmente:
        return _validateMonthDay();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Categoría personalizada ────────────────────────────────────────────────

  bool _categoryExists(String name) {
    final lower = name.toLowerCase();
    return HabitCategory.values.any((c) => c.label.toLowerCase() == lower) ||
        _customCategories.any((c) => c.toLowerCase() == lower);
  }

  Future<void> _showAddCategoryDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(
        normalize: _normalize,
        allowedChars: _categoryAllowedChars,
        hasLetter: _hasLetter,
        isDuplicate: _categoryExists,
      ),
    );

    if (name == null || name.isEmpty || !mounted) return;

    setState(() {
      _customCategories.add(name);
      // Selecciona la nueva categoría automáticamente.
      _categoryLabel = name;
    });
  }

  // ── Guardar ───────────────────────────────────────────────────────────────

  Habit _buildHabit() {
    // Resuelve el enum de categoría: si el label coincide con uno predefinido,
    // usa ese; si es personalizado, usa el primero como fallback estructural.
    // El nombre real siempre se pasa en categoryLabel para que el datasource
    // lo use al insertar en Supabase.
    final category = HabitCategory.values.firstWhere(
      (c) => c.label == _categoryLabel,
      orElse: () => HabitCategory.values.first,
    );

    return Habit(
      id: widget.habit?.id ?? '',
      name: _normalize(_nameController.text),
      type: _type,
      category: category,
      categoryLabel: _categoryLabel,
      iconIndex: _iconIndex,
      colorValue: _colorValue,
      repeat: _type == HabitType.frecuente ? _repeat : null,
      days: _type == HabitType.frecuente ? _days : const {},
      allDay: _allDay,
      reminderTime: _reminderTime != null
          ? (hour: _reminderTime!.hour, minute: _reminderTime!.minute)
          : null,
      goalPerDay: int.parse(_goalController.text.trim()),
      allowSkip: _allowSkip,
      remindersEnabled: _remindersEnabled,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    // 1) Campos del Form (nombre, meta, días, día del mes, hora).
    if (!_formKey.currentState!.validate()) {
      _showSnack('Revisa los campos marcados en rojo');
      return;
    }

    // 2) Validaciones que no viven en un FormField.
    final extraError = _validateCategory() ?? _validateSchedule();
    if (extraError != null) {
      _showSnack(extraError);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final provider = context.read<HabitsProvider>();
    final habit = _buildHabit();
    final ok = _isEditing
        ? await provider.updateHabit(habit)
        : await provider.addHabit(habit);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!ok) {
      _showSnack(provider.errorMessage ?? 'Algo salió mal');
      return;
    }

    // Tanto para crear como para editar: reemplaza el formulario con la
    // pantalla de éxito. Al pulsar "Aceptar" se regresa a la lista.
    // La sincronización con el Home es automática: HabitsProvider.onHabitChanged
    // dispara HomeProvider.load() sin que esta pantalla lo sepa.
    await Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HabitSuccessScreen(
          message: _isEditing
              ? 'Hábito actualizado correctamente'
              : 'Hábito creado correctamente',
        ),
      ),
    );
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  // ── Interfaz ──────────────────────────────────────────────────────────────

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
                      HomeAssets.frogSmall,
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
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(40),
                      ],
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
                      selectedLabel: _categoryLabel,
                      customCategories: _customCategories,
                      onChanged: (label) => setState(() {
                        _categoryLabel = label;
                        // Si es predefinida, actualiza _category también.
                        final predefined =
                            HabitCategory.values.where((c) => c.label == label);
                        if (predefined.isNotEmpty) {
                          _category = predefined.first;
                        }
                      }),
                      onAddNew: _showAddCategoryDialog,
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

                  // "Repetir" y selector de días solo existen para hábitos frecuentes.
                  if (isFrequent) ...[
                    const SizedBox(height: 33),
                    _Section(
                      label: 'Repetir',
                      gap: 16,
                      child: HabitSegmentedControl<HabitRepeat>(
                        options: HabitRepeat.values,
                        selected: _repeat,
                        labelOf: (r) => r.label,
                        onChanged: (r) => setState(() {
                          _repeat = r;
                          _days = {};
                        }),
                      ),
                    ),

                    // Solo muestra el selector de días si NO es diario.
                    if (_repeat != HabitRepeat.diariamente) ...[
                      const SizedBox(height: 33),
                      if (_repeat == HabitRepeat.semanalmente)
                        FormField<Set<int>>(
                          key: const ValueKey('weekly-days-field'),
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
                                _ErrorText(field.errorText!),
                            ],
                          ),
                        )
                      else if (_repeat == HabitRepeat.mensualmente)
                        FormField<int>(
                          key: const ValueKey('monthly-day-field'),
                          initialValue: _days.isNotEmpty ? _days.first : null,
                          validator: (_) => _validateMonthDay(),
                          builder: (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Elige el día del mes',
                                style: HabuuText.subtitleSmMedium.copyWith(
                                  color: HabuuTextColors.primaryBlack,
                                ),
                              ),
                              const SizedBox(height: 18),
                              HabitMonthDayPicker(
                                selectedDay:
                                    _days.isNotEmpty ? _days.first : null,
                                onChanged: (day) {
                                  setState(() {
                                    _days = day != null ? {day} : {};
                                  });
                                  field.didChange(day);
                                },
                              ),
                              if (field.hasError)
                                _ErrorText(field.errorText!),
                            ],
                          ),
                        ),
                    ],
                  ],

                  const SizedBox(height: 33),
                  _Section(
                    label: 'Recordar',
                    gap: 18,
                    // La key cambia con el switch para limpiar el error
                    // cuando se desactivan los recordatorios.
                    child: FormField<TimeOfDay>(
                      key: ValueKey('reminder-time-$_remindersEnabled'),
                      initialValue: _reminderTime,
                      validator: (_) => _validateReminderTime(),
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HabitTimePicker(
                            selectedTime: _reminderTime,
                            onChanged: (time) {
                              setState(() => _reminderTime = time);
                              field.didChange(time);
                            },
                          ),
                          if (field.hasError) _ErrorText(field.errorText!),
                        ],
                      ),
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

/// Diálogo para crear una categoría personalizada.
/// Es un StatefulWidget propio para que el controller y el Form se creen y
/// se liberen junto con el diálogo (evita usar un controller ya disposed
/// durante la animación de cierre).
class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    required this.normalize,
    required this.allowedChars,
    required this.hasLetter,
    required this.isDuplicate,
  });

  final String Function(String?) normalize;
  final RegExp allowedChars;
  final RegExp hasLetter;
  final bool Function(String name) isDuplicate;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final name = widget.normalize(value);
    if (name.isEmpty) return 'Escribe el nombre de la categoría';
    if (name.length < 2) return 'Escribe al menos 2 caracteres';
    if (name.length > 20) return 'Máximo 20 caracteres';
    if (!widget.hasLetter.hasMatch(name)) {
      return 'Debe incluir al menos una letra';
    }
    if (!widget.allowedChars.hasMatch(name)) {
      return 'Usa solo letras, números y espacios';
    }
    if (widget.isDuplicate(name)) return 'Esa categoría ya existe';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, widget.normalize(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(HabuuRadius.sm),
          borderSide: BorderSide(color: color, width: 1.5),
        );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Nueva categoría'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          controller: _controller,
          validator: _validate,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          maxLength: 20,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'Ej. Ejercicio',
            enabledBorder: border(HabuuColors.primary500),
            focusedBorder: border(HabuuColors.primary500),
            errorBorder: border(HabuuColors.error500),
            focusedErrorBorder: border(HabuuColors.error500),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HabuuColors.primary500),
          onPressed: _submit,
          child: const Text('Agregar'),
        ),
      ],
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

/// Texto de error para campos personalizados (FormField) que no muestran
/// el error por sí solos como lo hace TextFormField.
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: HabuuText.captionMdMedium.copyWith(
          color: HabuuTextColors.error,
        ),
      ),
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