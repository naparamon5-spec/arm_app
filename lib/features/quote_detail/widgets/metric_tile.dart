import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color valueColor;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.metricCellLabel),
        const SizedBox(height: AppSpacing.line),
        Text(
          value,
          style: AppTextStyles.metricValue.copyWith(color: valueColor),
        ),
        if (subValue != null)
          Text(subValue!, style: AppTextStyles.metricCellSub),
      ],
    );
  }
}
