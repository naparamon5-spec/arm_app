import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../controllers/approvals_controller.dart';
import '../widgets/approval_card.dart';

class ApprovalsListScreen extends StatefulWidget {
  const ApprovalsListScreen({super.key});

  @override
  State<ApprovalsListScreen> createState() => _ApprovalsListScreenState();
}

class _ApprovalsListScreenState extends State<ApprovalsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApprovalsController>().loadApprovals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: const AppBarWidget(),
      body: Consumer<ApprovalsController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              _SearchBar(
                controller: _searchController,
                onChanged: (v) => context.read<ApprovalsController>().search(v),
                onClear: () => context.read<ApprovalsController>().clearSearch(),
              ),
              Expanded(child: _buildBody(context, controller)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApprovalsController controller) {
    if (controller.isLoading) {
      return _ShimmerList();
    }
    if (controller.errorMessage != null) {
      return AppErrorWidget(
        message: controller.errorMessage,
        onRetry: () => controller.loadApprovals(),
      );
    }
    return Column(
      children: [
        _SectionHeader(count: controller.filteredQuotes.length),
        Expanded(child: _QuoteList(controller: controller)),
      ],
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF9FAFB),
        child: const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _SkeletonCard(),
        ),
      ),
    );
  }
}

/// A grey placeholder card that mirrors the [ApprovalCard] layout so the
/// loading state reads as "a quote is coming here".
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote number block
          _Bar(width: 80, height: 8),
          SizedBox(height: 8),
          _Bar(width: 140, height: 16),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
          ),
          // Product & date row
          _SkeletonFieldRow(),
          SizedBox(height: 12),
          // Customer & BU group row
          _SkeletonFieldRow(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
          ),
          // Salesman pill row
          Row(
            children: [
              CircleAvatar(radius: 14, backgroundColor: Color(0xFFE5E7EB)),
              SizedBox(width: 8),
              _Bar(width: 120, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonFieldRow extends StatelessWidget {
  const _SkeletonFieldRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bar(width: 60, height: 8),
            SizedBox(height: 6),
            _Bar(width: 110, height: 12),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(width: 50, height: 8),
            SizedBox(height: 6),
            _Bar(width: 80, height: 12),
          ],
        ),
      ],
    );
  }
}

/// A single rounded grey bar used as a text placeholder.
class _Bar extends StatelessWidget {
  final double width;
  final double height;
  const _Bar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7F8),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xs),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyRegular,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: AppTextStyles.bodyRegular.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textMuted,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      size: 18, color: AppColors.textMuted),
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7F8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(AppStrings.pendingApprovals,
              style: AppTextStyles.labelBold
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _QuoteList extends StatelessWidget {
  final ApprovalsController controller;
  const _QuoteList({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.filteredQuotes.isEmpty) {
      return const EmptyStateWidget(
        message: AppStrings.emptyApprovals,
        subtitle: AppStrings.emptyApprovalsSubtitle,
        icon: Icons.assignment_outlined,
      );
    }

    final itemCount = controller.filteredQuotes.length + 1;

    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == controller.filteredQuotes.length) {
          if (controller.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            );
          }
          if (!controller.hasMoreData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'All approvals loaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final quote = controller.filteredQuotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ApprovalCard(
            quote: quote,
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.quoteDetail,
              arguments: quote,
            ),
          ),
        );
      },
    );
  }
}
