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
            // Left — black badge: part_number on top, item_number below
            _ProductBadge(
              productCode: item.productCode,
              partNumber: item.partNumber,
              itemNumber: item.itemNumber,
            ),
            // Center — quantity
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'QTY',
                      style: AppTextStyles.metricLabel.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right — unit price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UNIT PRICE',
                  style: AppTextStyles.metricLabel.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.usd(item.unitPrice),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
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

