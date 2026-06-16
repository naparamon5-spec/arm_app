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
    Future.delayed(const Duration(milliseconds: 8000), () {
      if (!mounted) return;
      final loggedIn = AppDependencies.instance.sessionService.isLoggedIn;
      Navigator.of(context).pushReplacementNamed(
        loggedIn ? AppRouter.dashboard : AppRouter.login,
      );
    });
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
