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
                backgroundColor: const Color(0xFF1C2333),
                automaticallyImplyLeading: false,
                elevation: 0,
                toolbarHeight: 64,
                title: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'ARDENT ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'RESOURCE MANAGEMENT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD32F2F),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        'APPROVAL',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: SizedBox(
                    height: 2,
                    child: ColoredBox(color: Color(0xFFD32F2F)),
                  ),
                ),
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
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: const Color(0xFFD32F2F),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFFD32F2F),
        indicatorWeight: 2.5,
        tabs: [
          Tab(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Items ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextSpan(
                    text: '${quote.items.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Incidental',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Files ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextSpan(
                    text: '${quote.attachments.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
