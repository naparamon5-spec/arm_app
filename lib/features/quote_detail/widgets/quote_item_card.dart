import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/quote_item_model.dart';

class QuoteItemCard extends StatefulWidget {
  final QuoteItemModel item;
  final int index;

  const QuoteItemCard({super.key, required this.item, required this.index});

  @override
  State<QuoteItemCard> createState() => _QuoteItemCardState();
}

class _QuoteItemCardState extends State<QuoteItemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(item: item, expanded: _expanded, onToggle: () {
            setState(() => _expanded = !_expanded);
          }),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.divider),
            _FieldGrid(item: item),
            const Divider(height: 1, color: AppColors.divider),
            _Footer(item: item),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final QuoteItemModel item;
  final bool expanded;
  final VoidCallback onToggle;

  const _Header({
    required this.item,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _LineTypeBadge(lineType: item.lineType),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        item.partNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.description, style: AppTextStyles.heading3),
                ],
              ),
            ),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineTypeBadge extends StatelessWidget {
  final String lineType;
  const _LineTypeBadge({required this.lineType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        lineType,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _FieldGrid extends StatelessWidget {
  final QuoteItemModel item;
  const _FieldGrid({required this.item});

  @override
  Widget build(BuildContext context) {
    final fields = [
      (AppStrings.itemNumber, item.itemNumber),
      (AppStrings.itemSite, item.site),
      (AppStrings.itemQty, '${item.quantity}'),
      (AppStrings.itemListPrice, CurrencyFormatter.usd(item.listPrice)),
      (AppStrings.itemUnitPrice, CurrencyFormatter.usd(item.unitPrice)),
      (AppStrings.itemExtCost, CurrencyFormatter.usd(item.extendedCost)),
      (AppStrings.itemRebate, CurrencyFormatter.usd(item.rebate)),
      (AppStrings.itemSpu, '${item.spu}%'),
      (AppStrings.itemCostUsd, CurrencyFormatter.usd(item.costUsd)),
      (AppStrings.itemCostPhp, CurrencyFormatter.php(item.costPhp)),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final (label, value) = fields[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.metricLabel.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final QuoteItemModel item;
  const _Footer({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              item.standard,
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            item.partNumber,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
