import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/approvals/controllers/approvals_controller.dart';
import 'shared/controllers/main_tab_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => ApprovalsController()),
        ChangeNotifierProvider(create: (_) => MainTabController()),
      ],
      child: const ArdentApp(),
    ),
  );
}
