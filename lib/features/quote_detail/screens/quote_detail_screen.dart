import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/quote_detail_controller.dart';
import '../tabs/details_tab.dart';
import '../tabs/files_tab.dart';
import '../tabs/incidental_tab.dart';
import '../tabs/items_tab.dart';
import '../widgets/approve_bottom_bar.dart';
import '../widgets/print_preview_sheet.dart';
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

  Future<String?> _promptRemarks() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approver remarks'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Required for negative GP quotes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _onApprove() {
    final quote = _controller.quote ?? widget.quote;

    ConfirmationDialog.show(
      context: context,
      title: AppStrings.approveTitle,
      message: AppStrings.approveMessage,
      confirmLabel: AppStrings.confirm,
      cancelLabel: AppStrings.cancel,
      onConfirm: () async {
        String? remarks;
        if (quote.requiresRemarksOnApprove) {
          remarks = await _promptRemarks();
          if (remarks == null || remarks.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Approver's remarks are required"),
                ),
              );
            }
            return;
          }
        }

        _controller.approveQuote(
          remarks: remarks,
          onSuccess: () {
            if (mounted) {
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

        if (mounted && _controller.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_controller.errorMessage!)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<QuoteDetailController>(
        builder: (context, controller, _) {
          final quote = controller.quote ?? widget.quote;

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
                  QuoteHeaderCard(quote: quote),
                  _TabBar(controller: _tabController, quote: quote),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        DetailsTab(quote: quote),
                        ItemsTab(quote: quote),
                        IncidentalTab(quote: quote),
                        FilesTab(quote: quote),
                      ],
                    ),
                  ),
                  ApproveBottomBar(
                    onApprove: _onApprove,
                    onPrint: (option) =>
                        PrintPreviewSheet.show(context, quote, option: option),
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
          const Tab(
            child: Text(
              'Details',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
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
          const Tab(
            child: Text(
              'Incidental',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
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
