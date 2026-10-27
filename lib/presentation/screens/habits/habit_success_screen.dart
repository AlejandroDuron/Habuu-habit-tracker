import 'package:flutter/material.dart';
 
import '../../../config/theme/tokens.dart';
 
class HabitSuccessScreen extends StatelessWidget {
  const HabitSuccessScreen({super.key, required this.message});
 
  final String message;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HabuuGradients.pond),
        child: SafeArea(
          child: Center(
            // SingleChildScrollView por si el usuario tiene la letra muy
            // grande en accesibilidad y el texto no cabe
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/auth/frog happy.png',
                    width: 121,
                    height: 98,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: HabuuText.h3Bold.copyWith(
                      color: HabuuColors.black100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 263,
                    height: 60,
                    child: ElevatedButton(
                      // Regresa a la pantalla anterior
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HabuuColors.primary500,
                        foregroundColor: HabuuColors.white100,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(HabuuRadius.sm),
                        ),
                      ),
                      child: Text(
                        'Aceptar',
                        style: HabuuText.buttonGiant.copyWith(
                          color: HabuuTextColors.primaryWhite,
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
}