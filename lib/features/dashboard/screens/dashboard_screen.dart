import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/mock/mock_data.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/approval_summary_card.dart';
import '../widgets/recent_approval_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: const AppBarWidget(),
      body: Consumer<DashboardController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }
          if (controller.errorMessage != null) {
            return AppErrorWidget(
              message: controller.errorMessage,
              onRetry: () => controller.loadDashboard(),
            );
          }
          return _Body(controller: controller);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final DashboardController controller;

  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    final firstName = MockData.currentUser.fullName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: AppStrings.welcomePrefix,
                  style: AppTextStyles.dashboardWelcome,
                ),
                TextSpan(
                  text: firstName,
                  style: AppTextStyles.dashboardWelcome.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            AppStrings.dashboardSubtitle,
            style: AppTextStyles.dashboardSubtitleText,
          ),
          const SizedBox(height: AppSpacing.lg),
          const ApprovalSummaryCard(),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            AppStrings.recentPendingApprovals,
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.lg),
          RecentApprovalTile(
            quoteNumber: controller.recentQuotes[0].quoteNumber,
            description: '${controller.recentQuotes[0].product} — ${controller.recentQuotes[0].customer}',
            timeAgo: DateFormatter.timeAgo(controller.recentQuotes[0].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: controller.recentQuotes[0],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: controller.recentQuotes[1].quoteNumber,
            description: '${controller.recentQuotes[1].product} — ${controller.recentQuotes[1].customer}',
            timeAgo: DateFormatter.timeAgo(controller.recentQuotes[1].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: controller.recentQuotes[1],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: controller.recentQuotes[2].quoteNumber,
            description: '${controller.recentQuotes[2].product} — ${controller.recentQuotes[2].customer}',
            timeAgo: DateFormatter.timeAgo(controller.recentQuotes[2].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: controller.recentQuotes[2],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: controller.recentQuotes[3].quoteNumber,
            description: '${controller.recentQuotes[3].product} — ${controller.recentQuotes[3].customer}',
            timeAgo: DateFormatter.timeAgo(controller.recentQuotes[3].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: controller.recentQuotes[3],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: controller.recentQuotes[4].quoteNumber,
            description: '${controller.recentQuotes[4].product} — ${controller.recentQuotes[4].customer}',
            timeAgo: DateFormatter.timeAgo(controller.recentQuotes[4].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: controller.recentQuotes[4],
            ),
          ),
        ],
      ),
    );
  }
}
