import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../widgets/incidental_row.dart';

class IncidentalTab extends StatelessWidget {
  final QuoteModel quote;

  const IncidentalTab({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    if (quote.incidentals.isEmpty) {
      return const EmptyStateWidget(
        message: 'No incidentals',
        icon: Icons.receipt_long_outlined,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(),
          _ColumnHeaders(),
          ...quote.incidentals.map(
            (i) => IncidentalRow(incidental: i, forex: quote.forex),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.iconButtonBg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.metricPadding,
      ),
      child: Text(
        AppStrings.sectionIncidentalDetails,
        style: AppTextStyles.incidentalSectionHeader,
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.incidentalTypeDesc,
            style: AppTextStyles.metricCellLabel,
          ),
          Text(
            AppStrings.incidentalAmount,
            style: AppTextStyles.metricCellLabel,
          ),
        ],
      ),
    );
  }
}
