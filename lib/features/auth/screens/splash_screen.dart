import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../shared/navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), _decideNextRoute);
  }

  Future<void> _decideNextRoute() async {
    if (!mounted) return;
    final deps = AppDependencies.instance;
    final loggedIn = deps.sessionService.isLoggedIn;

    // No saved session — go straight to the login screen.
    if (!loggedIn) {
      _go(AppRouter.login);
      return;
    }

    // Saved session present. If the user enabled biometric login, gate entry
    // behind a Face ID / Touch ID / fingerprint / passcode check. On failure or
    // cancel we fall back to the login screen (the session stays saved, and the
    // login screen offers an "unlock" retry plus the password path).
    final biometric = deps.biometricService;
    final enabled = await biometric.isEnabled();
    if (enabled && await biometric.canAuthenticate()) {
      final ok = await biometric.authenticate(
        reason: 'Unlock ARM to continue',
      );
      if (!mounted) return;
      _go(ok ? AppRouter.dashboard : AppRouter.login);
      return;
    }

    _go(AppRouter.dashboard);
  }

  void _go(String route) {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = max(220.0, screenWidth * 0.55);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/ARM.png',
              width: logoWidth,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: const Text(
              'DEVELOPED BY ARDENT MIS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
