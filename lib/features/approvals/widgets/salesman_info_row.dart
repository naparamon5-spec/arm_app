import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class SalesmanInfoRow extends StatelessWidget {
  final String salesmanName;

  const SalesmanInfoRow({super.key, required this.salesmanName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 16,
            color: AppColors.surface,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Sales: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: salesmanName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
