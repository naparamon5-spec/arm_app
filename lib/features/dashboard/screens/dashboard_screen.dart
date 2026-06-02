import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _Body extends StatefulWidget {
  final DashboardController controller;

  const _Body({required this.controller});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final TextEditingController _quoteSearchController;

  @override
  void initState() {
    super.initState();
    _quoteSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _quoteSearchController.dispose();
    super.dispose();
  }

  void _onSearchQuote() {
    final input = _quoteSearchController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quote number')),
      );
      return;
    }
    final matches = MockData.pendingQuotes.where(
      (q) => q.quoteNumber.replaceAll('#', '').contains(input),
    );
    if (matches.isNotEmpty) {
      Navigator.of(context).pushNamed(
        AppRouter.quoteDetail,
        arguments: matches.first,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote #$input not found'),
          backgroundColor: const Color(0xFF1C2333),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = MockData.currentUser.fullName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.xxxl),
          // FOR APPROVAL card — no margin, parent Padding handles edges
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: label only
                Text(
                  'FOR APPROVAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Row 2: QT# + inline TextField
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'QT#',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _quoteSearchController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          TextInputFormatter.withFunction(
                            (oldVal, newVal) => newVal.copyWith(
                              text: newVal.text.toUpperCase(),
                            ),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: '',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _onSearchQuote(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _onSearchQuote,
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Row 3: subtitle
                Text(
                  'Tap to review quote details and proceed with approval.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 70),

          const Text(
            AppStrings.recentPendingApprovals,
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.lg),
          RecentApprovalTile(
            quoteNumber: widget.controller.recentQuotes[0].quoteNumber,
            description: '${widget.controller.recentQuotes[0].product} — ${widget.controller.recentQuotes[0].customer}',
            timeAgo: DateFormatter.timeAgo(widget.controller.recentQuotes[0].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: widget.controller.recentQuotes[0],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: widget.controller.recentQuotes[1].quoteNumber,
            description: '${widget.controller.recentQuotes[1].product} — ${widget.controller.recentQuotes[1].customer}',
            timeAgo: DateFormatter.timeAgo(widget.controller.recentQuotes[1].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: widget.controller.recentQuotes[1],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: widget.controller.recentQuotes[2].quoteNumber,
            description: '${widget.controller.recentQuotes[2].product} — ${widget.controller.recentQuotes[2].customer}',
            timeAgo: DateFormatter.timeAgo(widget.controller.recentQuotes[2].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: widget.controller.recentQuotes[2],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: widget.controller.recentQuotes[3].quoteNumber,
            description: '${widget.controller.recentQuotes[3].product} — ${widget.controller.recentQuotes[3].customer}',
            timeAgo: DateFormatter.timeAgo(widget.controller.recentQuotes[3].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: widget.controller.recentQuotes[3],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RecentApprovalTile(
            quoteNumber: widget.controller.recentQuotes[4].quoteNumber,
            description: '${widget.controller.recentQuotes[4].product} — ${widget.controller.recentQuotes[4].customer}',
            timeAgo: DateFormatter.timeAgo(widget.controller.recentQuotes[4].quoteDate),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: widget.controller.recentQuotes[4],
            ),
          ),
        ],
      ),
    );
  }
}
