import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/assets.dart';
import '../../../data/models/user_profile.dart';
import '../../../utils/validators.dart';
import '../auth/auth_button.dart';
import 'profile_date_field.dart';
import 'profile_dropdown_field.dart';
import 'profile_text_field.dart';

/// Datos editables del perfil. No guarda nada: entrega el perfil editado
/// en [onSave] y quien lo usa decide qué hacer.
class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.profile,
    required this.onSave,
    this.isSaving = false,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;
  final bool isSaving;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.profile.fullName,
  );
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );
  late final _phoneController = TextEditingController(
    text: widget.profile.phone ?? '',
  );
  final _phoneFocus = FocusNode();
  late Gender? _gender = widget.profile.gender;
  late DateTime? _birthday = widget.profile.birthday;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  UserProfile get _edited {
    final phone = _phoneController.text.trim();
    return UserProfile(
      id: widget.profile.id,
      email: widget.profile.email,
      fullName: _nameController.text.trim(),
      phone: phone.isEmpty ? null : phone,
      gender: _gender,
      birthday: _birthday,
    );
  }

  bool get _hasChanges => _edited != widget.profile;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onSave(_edited);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Cada cambio vuelve a revisar si hay algo que guardar.
      onChanged: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          ProfileTextField(
            label: 'Nombre Completo',
            controller: _nameController,
            hint: 'Tu nombre',
            validator: Validators.fullName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            inputFormatters: [
              LengthLimitingTextInputFormatter(Validators.fullNameMaxLength),
            ],
            onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
          ),
          ProfileTextField(
            label: 'Email',
            controller: _emailController,
            leadingIcon: ProfileAssets.mail,
            readOnly: true,
          ),
          ProfileTextField(
            label: 'Teléfono',
            controller: _phoneController,
            focusNode: _phoneFocus,
            hint: '+503 7123 4567',
            leadingIcon: ProfileAssets.phone,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ -]')),
              LengthLimitingTextInputFormatter(Validators.phoneMaxLength),
            ],
          ),
          ProfileDropdownField<Gender>(
            label: 'Género',
            options: Gender.values,
            labelOf: (gender) => gender.label,
            value: _gender,
            onChanged: (gender) => setState(() => _gender = gender),
          ),
          ProfileDateField(
            label: 'Cumpleaños',
            value: _birthday,
            firstDate: Validators.oldestBirthday,
            lastDate: today,
            pickerTitle: 'Elige tu fecha de nacimiento',
            validator: (date) => Validators.birthday(date, today: today),
            onChanged: (date) => setState(() => _birthday = date),
          ),
          AuthButton(
            label: 'Guardar cambios',
            onPressed: _hasChanges ? _submit : null,
            isLoading: widget.isSaving,
          ),
        ],
      ),
    );
  }
}
