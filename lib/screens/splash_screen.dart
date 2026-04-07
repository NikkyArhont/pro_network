import 'package:flutter/material.dart';
import 'package:pro_network/services/app_start_service.dart';
import 'package:pro_network/screens/onboarding_screen.dart';
import 'package:pro_network/screens/auth_choice_screen.dart';
import 'package:pro_network/screens/home_screen.dart';
import 'package:pro_network/utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppStartService _service = AppStartService();

  @override
  void initState() {
    super.initState();
    _handleStart();
  }

  Future<void> _handleStart() async {
    // Add a small delay for splash experience
    await Future.delayed(const Duration(seconds: 2));
    
    final route = await _service.determineStartRoute();
    
    if (!mounted) return;

    Widget nextScreen;
    switch (route) {
      case StartRoute.onboarding:
        nextScreen = const OnboardingScreen();
        break;
      case StartRoute.authChoice:
        nextScreen = const AuthChoiceScreen();
        break;
      case StartRoute.home:
      default:
        nextScreen = const HomeScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Center(
        child: Image.asset(
          AppAssets.logo,
          width: 200,
        ),
      ),
    );
  }
}
