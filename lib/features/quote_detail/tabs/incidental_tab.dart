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

    return ColoredBox(
      color: const Color(0xFFF4F7F8),
      child: SingleChildScrollView(
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F7F8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        AppStrings.sectionIncidentalDetails,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.incidentalTypeDesc,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          Text(
            AppStrings.incidentalAmount,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
