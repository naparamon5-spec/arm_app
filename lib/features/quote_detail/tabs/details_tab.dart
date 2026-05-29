import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/quote_model.dart';
import '../widgets/detail_row.dart';
import '../widgets/section_card.dart';

class DetailsTab extends StatelessWidget {
  final QuoteModel quote;

  const DetailsTab({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          SectionCard(
            title: AppStrings.sectionQuoteDetails,
            children: [
              DetailRowGrid(rows: [
                DetailRow(label: AppStrings.labelQuoteNumber, value: quote.quoteNumber),
                DetailRow(label: AppStrings.labelProduct, value: quote.product),
                DetailRow(label: AppStrings.labelQuoteType, value: quote.quoteType),
                DetailRow(
                  label: AppStrings.labelQuoteDate,
                  value: DateFormatter.display(quote.quoteDate),
                ),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: AppStrings.sectionCustomerEndUsers,
            children: [
              DetailRowGrid(rows: [
                DetailRow(label: AppStrings.labelCustomer, value: quote.customer),
                DetailRow(label: AppStrings.labelContactPerson, value: quote.contactPerson),
                DetailRow(label: AppStrings.labelTerm, value: quote.term),
                DetailRow(label: AppStrings.labelEndUser, value: quote.endUser),
              ]),
              const SizedBox(height: AppSpacing.lg),
              DetailRow(
                label: AppStrings.labelSuContactPerson,
                value: quote.suContactPerson,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: AppStrings.sectionSalesmanPo,
            children: [
              DetailRowGrid(rows: [
                DetailRow(label: AppStrings.labelSalesman, value: quote.salesmanName),
                DetailRow(label: AppStrings.labelBdm, value: quote.bdName),
                DetailRow(label: AppStrings.labelPoNumber, value: quote.poNumber),
                DetailRow(
                  label: AppStrings.labelPoDate,
                  value: DateFormatter.display(quote.poDate),
                ),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: AppStrings.sectionOthers,
            children: [
              DetailRowGrid(rows: [
                DetailRow(
                  label: AppStrings.labelForex,
                  value: '₱${quote.forex.toStringAsFixed(2)}',
                ),
                DetailRow(
                  label: AppStrings.labelAllowedUp,
                  value: CurrencyFormatter.percent(quote.allowedUpPercent),
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              DetailRow(
                label: AppStrings.labelReason,
                value: quote.reason,
                italic: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
