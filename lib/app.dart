import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';

class ArdentApp extends StatelessWidget {
  const ArdentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ardent Resource Management',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
