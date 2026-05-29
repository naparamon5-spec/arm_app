import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class BrandedHeader extends StatelessWidget {
  const BrandedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LogoTile(),
        const SizedBox(height: AppSpacing.lg),
        _BrandTitle(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.enterpriseGateway,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _LogoTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'A',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final parts = AppStrings.companyName.split(' ');
    final prefix = parts.first;
    final suffix = parts.last;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$prefix ',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          TextSpan(
            text: suffix,
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
