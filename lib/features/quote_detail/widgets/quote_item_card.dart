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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
              item: item,
              expanded: _expanded,
              onToggle: () {
                setState(() => _expanded = !_expanded);
              }),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.divider),
            _FieldGrid(item: item),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left — product code / item number. Fixed share so the QTY and
            // UNIT PRICE columns stay aligned across rows even when the product
            // code is long.
            Expanded(
              flex: 5,
              child: _ProductBadge(
                productCode: item.productCode,
                partNumber: item.partNumber,
                itemNumber: item.itemNumber,
              ),
            ),
            // Center — quantity
            Expanded(
              flex: 2,
              child: _Metric(
                label: 'QTY',
                value: '${item.quantity}',
                alignment: CrossAxisAlignment.center,
              ),
            ),
            // Right — unit price
            Expanded(
              flex: 3,
              child: _Metric(
                label: 'UNIT PRICE',
                value: CurrencyFormatter.usd(item.unitPrice),
                alignment: CrossAxisAlignment.end,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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

/// A small label-over-value column (QTY / UNIT PRICE) with a configurable
/// horizontal alignment so columns line up consistently across rows.
class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  const _Metric({
    required this.label,
    required this.value,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign =
        alignment == CrossAxisAlignment.end ? TextAlign.end : TextAlign.center;
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: AppTextStyles.metricLabel.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: textAlign,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProductBadge extends StatelessWidget {
  final String productCode;
  final String partNumber;
  final String itemNumber;

  const _ProductBadge({
    required this.productCode,
    required this.partNumber,
    required this.itemNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (productCode.isNotEmpty) ...[
            const Text(
              'PRODUCT CODE',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              productCode,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (itemNumber.isNotEmpty) ...[
            const Text(
              'ITEM NUMBER',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              itemNumber,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
    );
  }
}

class _FieldGrid extends StatelessWidget {
  final QuoteItemModel item;
  const _FieldGrid({required this.item});

  @override
  Widget build(BuildContext context) {
    final fields = [
      (AppStrings.itemSite, item.site),
      (AppStrings.itemListGlp, CurrencyFormatter.usd(item.listGlp)),
      (AppStrings.itemExtPrice, CurrencyFormatter.usd(item.extendedPrice)),
      (AppStrings.itemFreight, CurrencyFormatter.usd(item.freight)),
      (AppStrings.itemVat, CurrencyFormatter.usd(item.vat)),
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

