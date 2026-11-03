import 'package:flutter/material.dart';
import 'package:habuu/presentation/screens/landing/onboarding_screen.dart';

void main() {
  runApp(const OnboardingPreviewApp());
}

class OnboardingPreviewApp extends StatelessWidget {
  const OnboardingPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(
        onFinish: () => debugPrint('Onboarding finalizado'),
      ),
    );
  }
}
