import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/approvals/screens/approvals_list_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../controllers/main_tab_controller.dart';
import 'app_bottom_nav.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainTabController>(
      builder: (context, tabController, _) {
        return Scaffold(
          body: IndexedStack(
            index: tabController.index,
            children: const [
              DashboardScreen(),
              ApprovalsListScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: tabController.index,
            onTap: tabController.switchTo,
          ),
        );
      },
    );
  }
}
