import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/quote_item_card.dart';

class ItemsTab extends StatelessWidget {
  final QuoteModel quote;

  const ItemsTab({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    if (quote.items.isEmpty) {
      return const EmptyStateWidget(
        message: AppStrings.emptyItems,
        icon: Icons.inventory_2_outlined,
      );
    }

    return ColoredBox(
      color: const Color(0xFFF4F7F8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemsHeader(count: quote.items.length),
            const SizedBox(height: AppSpacing.md),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: quote.items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => QuoteItemCard(
                item: quote.items[index],
                index: index,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  final int count;
  const _ItemsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'QUOTE ITEMS ',
            style: AppTextStyles.labelBold,
          ),
          TextSpan(
            text: '($count)',
            style: AppTextStyles.labelBold.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
