import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  final bool italic;
  final Color? valueColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.fullWidth = false,
    this.italic = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.metricLabel.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyRegular.copyWith(
            fontWeight: FontWeight.w500,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class DetailRowGrid extends StatelessWidget {
  final List<DetailRow> rows;

  const DetailRowGrid({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final pairs = <Widget>[];
    for (var i = 0; i < rows.length; i += 2) {
      final left = rows[i];
      final right = i + 1 < rows.length ? rows[i + 1] : null;
      pairs.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: right ?? const SizedBox()),
          ],
        ),
      );
      if (i + 2 < rows.length) {
        pairs.add(const SizedBox(height: AppSpacing.lg));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pairs,
    );
  }
}
