import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/quote_model.dart';
import 'salesman_info_row.dart';

class ApprovalCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onTap;

  const ApprovalCard({super.key, required this.quote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuoteNumberRow(quote: quote),
            const SizedBox(height: AppSpacing.sm),
            _ProductDateRow(quote: quote),
            const SizedBox(height: AppSpacing.xs),
            _CustomerBuRow(quote: quote),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),
            _BottomRow(quote: quote),
          ],
        ),
      ),
    );
  }
}

class _QuoteNumberRow extends StatelessWidget {
  final QuoteModel quote;
  const _QuoteNumberRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Text(quote.quoteNumber, style: AppTextStyles.heading3);
  }
}

class _ProductDateRow extends StatelessWidget {
  final QuoteModel quote;
  const _ProductDateRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FieldColumn(label: 'Product', value: quote.product),
        _FieldColumn(
          label: 'Date',
          value: DateFormatter.display(quote.quoteDate),
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }
}

class _CustomerBuRow extends StatelessWidget {
  final QuoteModel quote;
  const _CustomerBuRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _FieldColumn(label: 'Customer', value: quote.customer),
        ),
        const SizedBox(width: AppSpacing.lg),
        _FieldColumn(
          label: 'BU Group',
          value: quote.bdName,
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }
}

class _FieldColumn extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _FieldColumn({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: AppTextStyles.metricLabel.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BottomRow extends StatelessWidget {
  final QuoteModel quote;
  const _BottomRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SalesmanInfoRow(salesmanName: quote.salesmanName),
              if (quote.salesmanNote != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '"${quote.salesmanNote}"',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: AppColors.textMuted,
          size: 20,
        ),
      ],
    );
  }
}
