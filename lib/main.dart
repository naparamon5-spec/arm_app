import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/app_dependencies.dart';
import 'features/approvals/controllers/approvals_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'services/post_update_reset.dart';
import 'shared/controllers/main_tab_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDependencies.instance.initialize();

  // Post-update sign-out: if the installed app version changed since the last
  // launch, wipe the stored session so the user signs in again on the fresh
  // build. Fails open — never blocks launch.
  await PostUpdateReset.runIfVersionChanged();

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
