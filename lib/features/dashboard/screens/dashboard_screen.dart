import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/mock/mock_data.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/controllers/main_tab_controller.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textLight),
            onPressed: () {},
          ),
        ],
      ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.xs),
          const Text(
            AppStrings.dashboardSubtitle,
            style: AppTextStyles.dashboardSubtitleText,
          ),
          const SizedBox(height: AppSpacing.xl),
          ApprovalSummaryCard(
            count: controller.pendingCount,
            onTap: () => context.read<MainTabController>().switchTo(1),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Text(
            AppStrings.recentPendingApprovals,
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.recentQuotes.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final quote = controller.recentQuotes[index];
              return RecentApprovalTile(
                quoteNumber: quote.quoteNumber,
                description: '${quote.product} — ${quote.customer}',
                timeAgo: DateFormatter.timeAgo(quote.quoteDate),
                onTap: () => Navigator.of(context).pushNamed(
                  AppRouter.quoteDetail,
                  arguments: quote,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
