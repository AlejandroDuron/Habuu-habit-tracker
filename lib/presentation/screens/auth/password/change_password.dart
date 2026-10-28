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
  static const String _hint = '****************';

  final _formKey = GlobalKey<FormState>();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

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
    // TODO: llamar a supabase para cambiar la contraseña
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
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
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
                      color: HabuuIconColors.black,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Volver',
                  ),
                  Image.asset(
                    'assets/images/auth/frog police password green.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text('Cambiar\ncontraseña', style: HabuuText.h5ExtraBold),
                  const SizedBox(height: 40),

                  _label('Nueva contraseña'),
                  const SizedBox(height: 8),
                  _passwordField(
                    controller: _newController,
                    validator: _validateNew,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _helpText,
                    style: HabuuText.bodySmMedium.copyWith(
                      color: HabuuTextColors.secondaryGrey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _label('Confirmar contraseña'),
                  const SizedBox(height: 8),
                  _passwordField(
                    controller: _confirmController,
                    validator: _validateConfirm,
                  ),
                  const SizedBox(height: 28),

                  Center(
                    child: SizedBox(
                      width: 240,
                      height: 54,
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
      style: HabuuText.subtitleMdBold.copyWith(color: HabuuIconColors.black),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        );

    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator,
      style: HabuuText.bodySmMedium,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: HabuuColors.grey0,
        hintText: _hint,
        hintStyle: HabuuText.captionMdMedium.copyWith(
          color: HabuuColors.grey400,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: border(HabuuColors.primary200),
        focusedBorder: border(HabuuColors.primary500),
        errorBorder: border(Colors.red.shade400),
        focusedErrorBorder: border(Colors.red.shade400),
        errorMaxLines: 2,
      ),
    );
  }
}