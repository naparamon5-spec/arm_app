import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'print_options_dialog.dart';

enum PrintOption { php, dollar, costing }

class ApproveBottomBar extends StatelessWidget {
  final VoidCallback onApprove;
  final ValueChanged<PrintOption> onPrint;

  const ApproveBottomBar({
    super.key,
    required this.onApprove,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.check,
                  color: AppColors.textLight,
                  size: 18,
                ),
                label: const Text(
                  AppStrings.approve,
                  style: AppTextStyles.buttonLabel,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () async {
              final option = await PrintOptionsDialog.show(context);
              if (option != null) onPrint(option);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // Light primary tint with a matching border so the button
                // stands out against the near-white card background.
                color: const Color(0xFFFBEAED),
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                border: Border.all(color: const Color(0x33C6324C)),
              ),
              child: const Icon(
                Icons.print_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
