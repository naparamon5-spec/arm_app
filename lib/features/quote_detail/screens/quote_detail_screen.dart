import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/quote_detail_controller.dart';
import '../tabs/details_tab.dart';
import '../tabs/files_tab.dart';
import '../tabs/incidental_tab.dart';
import '../tabs/items_tab.dart';
import '../widgets/approve_bottom_bar.dart';
import '../widgets/quote_header_card.dart';

class QuoteDetailScreen extends StatefulWidget {
  final QuoteModel quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final QuoteDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuoteDetailController();
    _controller.loadQuote(widget.quote);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onApprove() {
    ConfirmationDialog.show(
      context: context,
      title: AppStrings.approveTitle,
      message: AppStrings.approveMessage,
      confirmLabel: AppStrings.confirm,
      cancelLabel: AppStrings.cancel,
      onConfirm: () {
        _controller.approveQuote(
          onSuccess: () {
            if (mounted) {
              context.findAncestorStateOfType<ScaffoldMessengerState>();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quote approved successfully!'),
                  backgroundColor: AppColors.approved,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<QuoteDetailController>(
        builder: (context, controller, _) {
          return LoadingOverlay(
            isLoading: controller.isLoading,
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                automaticallyImplyLeading: false,
                elevation: 0,
                title: const Text(
                  AppStrings.appBarHeading,
                  style: AppTextStyles.appBarTitle,
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        AppStrings.approvalsLabel,
                        style: AppTextStyles.appBarTitle,
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  QuoteHeaderCard(quote: widget.quote),
                  _TabBar(controller: _tabController, quote: widget.quote),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        DetailsTab(quote: widget.quote),
                        ItemsTab(quote: widget.quote),
                        IncidentalTab(quote: widget.quote),
                        FilesTab(quote: widget.quote),
                      ],
                    ),
                  ),
                  ApproveBottomBar(
                    onApprove: _onApprove,
                    onPrint: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  final QuoteModel quote;

  const _TabBar({required this.controller, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(fontSize: 13),
        tabs: [
          const Tab(text: AppStrings.tabDetails),
          Tab(text: '${AppStrings.tabItems} ${quote.items.length}'),
          const Tab(text: AppStrings.tabIncidental),
          Tab(text: '${AppStrings.tabFiles} ${quote.attachments.length}'),
        ],
      ),
    );
  }
}
