import 'package:flutter/material.dart';
import '../../../../config/theme/tokens.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const String _helpText =
      'Mínimo 8 caracteres, con mayúsculas, números y símbolos';

  final _formKey = GlobalKey<FormState>();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    final v = value ?? '';
    if (v.length < 8 ||
        !v.contains(RegExp(r'[A-Z]')) ||
        !v.contains(RegExp(r'[0-9]')) ||
        !v.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return _helpText;
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _newController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: llamar a tu servicio para cambiar la contraseña
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HabuuGradients.skyToMint),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: HabuuColors.iconBlack,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Volver',
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/froggy_password.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text('Cambiar\ncontraseña', style: HabuuText.h4ExtraBold),
                  const SizedBox(height: 32),

                  _label('Nueva contraseña'),
                  const SizedBox(height: 8),
                  _passwordField(
                    controller: _newController,
                    hidden: _hideNew,
                    onToggle: () => setState(() => _hideNew = !_hideNew),
                    validator: _validateNew,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _helpText,
                    style: HabuuText.bodySmMedium.copyWith(
                      color: HabuuColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _label('Confirmar contraseña'),
                  const SizedBox(height: 8),
                  _passwordField(
                    controller: _confirmController,
                    hidden: _hideConfirm,
                    onToggle: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                    validator: _validateConfirm,
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: SizedBox(
                      width: 310,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HabuuColors.primary500,
                          foregroundColor: HabuuColors.white100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Guardar',
                          style: HabuuText.subtitleMdBold.copyWith(
                            color: HabuuColors.white100,
                          ),
                        ),
                      ),
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

  Widget _label(String text) {
    return Text(
      text,
      style: HabuuText.subtitleMdBold.copyWith(color: HabuuColors.iconBlack),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        );

    return TextFormField(
      controller: controller,
      obscureText: hidden,
      validator: validator,
      style: HabuuText.subtitleSmMedium,
      decoration: InputDecoration(
        filled: true,
        fillColor: HabuuColors.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: border(HabuuColors.primary200),
        focusedBorder: border(HabuuColors.primary500),
        errorBorder: border(Colors.red.shade400),
        focusedErrorBorder: border(Colors.red.shade400),
        errorMaxLines: 2,
        suffixIcon: IconButton(
          icon: Icon(
            hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: HabuuColors.grey500,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}