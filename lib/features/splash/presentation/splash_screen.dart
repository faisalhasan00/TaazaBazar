import 'dart:async';
import 'package:flutter/material.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../onboarding/presentation/widgets/animated_welcome_view.dart';

/// Screen 1: Splash / Welcome Screen matching the reference design with entrance animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Smooth navigation after animated welcome display
    _navigationTimer = Timer(const Duration(milliseconds: 3600), () {
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE),
      body: AnimatedWelcomeView(
        onNext: _navigateToOnboarding,
        onSkip: _navigateToOnboarding,
      ),
    );
  }
}
