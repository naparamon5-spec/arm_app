import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/incidental_model.dart';

class IncidentalRow extends StatelessWidget {
  final IncidentalModel incidental;
  final double forex;

  const IncidentalRow({
    super.key,
    required this.incidental,
    required this.forex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incidental.type, style: AppTextStyles.incidentalTypeName),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  incidental.description,
                  style: AppTextStyles.incidentalDescription,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.usd(incidental.amount),
                style: AppTextStyles.incidentalAmount,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                CurrencyFormatter.php(incidental.amount * forex),
                style: AppTextStyles.incidentalAmountSub,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
