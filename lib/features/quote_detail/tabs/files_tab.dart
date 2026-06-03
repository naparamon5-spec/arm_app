import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/attachment_model.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../screens/file_viewer_screen.dart';
import '../widgets/file_attachment_tile.dart';

class FilesTab extends StatelessWidget {
  final QuoteModel quote;

  const FilesTab({super.key, required this.quote});

  /// Opens the attachment in a full-screen, in-app viewer that downloads the
  /// bytes through the authenticated API client and renders PDFs/images.
  void _openFile(BuildContext context, AttachmentModel attachment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FileViewerScreen(attachment: attachment),
      ),
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
