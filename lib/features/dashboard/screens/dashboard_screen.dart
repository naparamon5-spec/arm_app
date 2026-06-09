import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
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
    final firstName = controller.welcomeName;

    return SingleChildScrollView(
      // Let the dashboard content scroll so it never overflows on shorter
      // devices. The "ARDENT RESOURCE MANAGEMENT" header lives in the Scaffold
      // app bar (outside this body) and stays fixed.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
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
          if (controller.recentQuotes.isEmpty)
            const Text(
              'No recent quotes pending approval.',
              style: AppTextStyles.bodySmall,
            )
          else
            ...controller.recentQuotes.map(
              (quote) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: RecentApprovalTile(
                  quoteNumber: quote.quoteNumber,
                  description: '${quote.product} — ${quote.customer}',
                  timeAgo: DateFormatter.timeAgo(quote.quoteDate),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRouter.quoteDetail,
                    arguments: quote,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
