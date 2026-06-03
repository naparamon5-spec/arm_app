import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/attachment_model.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../widgets/file_attachment_tile.dart';

class FilesTab extends StatelessWidget {
  final QuoteModel quote;

  const FilesTab({super.key, required this.quote});

  /// Opens the attachment in an in-app browser view (renders PDFs/images
  /// without leaving the app), falling back to the system handler.
  Future<void> _openFile(BuildContext context, AttachmentModel attachment) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(attachment.url);
    if (uri == null || attachment.url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('File is not available to open.')),
      );
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (opened) return;
      // Some platforms can't host the in-app view — hand off to the OS.
      final external =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (external) return;
    } catch (_) {
      // Fall through to the error message below.
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open ${attachment.fileName}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quote.attachments.isEmpty) {
      return const EmptyStateWidget(
        message: AppStrings.emptyFiles,
        icon: Icons.attach_file_outlined,
      );
    }

    return ColoredBox(
      color: const Color(0xFFF4F7F8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilesHeader(count: quote.attachments.length),
            const SizedBox(height: AppSpacing.md),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: quote.attachments.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final attachment = quote.attachments[index];
                return FileAttachmentTile(
                  attachment: attachment,
                  onTap: () => _openFile(context, attachment),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _FilesHeader extends StatelessWidget {
  final int count;
  const _FilesHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'ATTACHMENTS ',
            style: AppTextStyles.labelBold,
          ),
          TextSpan(
            text: '($count)',
            style: AppTextStyles.labelBold.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
