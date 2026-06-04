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
import '../widgets/quote_header_card.dart';
import 'pdf_viewer_screen.dart';

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

  /// Remarks collected up-front for negative-GP quotes, reused on approve.
  String? _approverRemarks;

  @override
  void initState() {
    super.initState();
    _controller = QuoteDetailController();
    _controller.loadQuote(widget.quote);
    _tabController = TabController(length: 4, vsync: this);
    // Negative-GP quotes require approver remarks — ask for them as soon as the
    // detail opens so they're ready when the manager approves.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptOnOpen());
  }

  Future<void> _maybePromptOnOpen() async {
    final quote = _controller.quote ?? widget.quote;
    if (!quote.requiresRemarksOnApprove) return;
    final remarks = await _promptRemarks();
    if (!mounted) return;
    if (remarks != null && remarks.isNotEmpty) {
      _approverRemarks = remarks;
    } else {
      // Remarks are mandatory for negative-GP quotes — if the approver backs
      // out instead of entering them, leave the detail screen. Drop keyboard
      // focus first and defer the pop a frame so the dialog's focus scope is
      // fully torn down before this route is removed (avoids the
      // _FocusInheritedScope "_dependents.isEmpty" assertion).
      FocusManager.instance.primaryFocus?.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _promptRemarks() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ApproverRemarksDialog(),
    );
  }

  void _openPdf(BuildContext context, QuoteModel quote, PrintOption option) {
    final (type, title) = switch (option) {
      PrintOption.php => (
          'print-php',
          'Quote #${quote.quoteNumber} (PHP)',
        ),
      PrintOption.dollar => (
          'print-usd',
          'Quote #${quote.quoteNumber} (USD)',
        ),
      PrintOption.costing => (
          'print-costing',
          'Costing Sheet #${quote.quoteNumber}',
        ),
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          quoteNumber: quote.quoteNumber,
          type: type,
          title: title,
        ),
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
        String? remarks = _approverRemarks;
        if (quote.requiresRemarksOnApprove &&
            (remarks == null || remarks.isEmpty)) {
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
          _approverRemarks = remarks;
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
                    onPrint: (option) => _openPdf(context, quote, option),
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

/// Mandatory "Approver remarks" dialog for negative-GP quotes. Owns its own
/// [TextEditingController] so it's disposed only after the route is fully gone
/// (avoids "used after being disposed" during the close animation).
/// Returns the trimmed remarks on Submit, or `null` when backed out.
class _ApproverRemarksDialog extends StatefulWidget {
  const _ApproverRemarksDialog();

  @override
  State<_ApproverRemarksDialog> createState() => _ApproverRemarksDialogState();
}

class _ApproverRemarksDialogState extends State<_ApproverRemarksDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: back icon + title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 22),
                    color: AppColors.textSecondary,
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Approver remarks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 0, 0),
                child: Text(
                  'This quote has a negative GP. Remarks are required '
                  'before you can approve it.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your remarks…',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? () =>
                            Navigator.pop(context, _controller.text.trim())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.4),
                      disabledForegroundColor: AppColors.textLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
