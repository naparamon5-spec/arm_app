import 'package:flutter/material.dart';

import 'core/di/app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';

class ArdentApp extends StatelessWidget {
  const ArdentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = AppDependencies.instance.sessionService.isLoggedIn
        ? AppRouter.dashboard
        : AppRouter.login;

    return MaterialApp(
      title: 'Ardent Resource Management',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
