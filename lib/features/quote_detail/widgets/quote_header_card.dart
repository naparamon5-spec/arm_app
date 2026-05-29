import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/quote_model.dart';
import 'metric_tile.dart';

class QuoteHeaderCard extends StatelessWidget {
  final QuoteModel quote;

  const QuoteHeaderCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          _NavRow(),
          _QuoteNumberRow(quote: quote),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          _RouteRow(quote: quote),
          _MetricsCard(quote: quote),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ── ← back │ "QUOTE APPROVAL" centered │ balanced spacer
class _NavRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
            color: AppColors.textSecondary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Center(
            child: Text(
              AppStrings.quoteApproval,
              style: AppTextStyles.quoteHeaderLabel,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

// ── quote number centered
class _QuoteNumberRow extends StatelessWidget {
  final QuoteModel quote;
  const _QuoteNumberRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Center(
        child: Text(quote.quoteNumber, style: AppTextStyles.quoteHeaderNumber),
      ),
    );
  }
}

// ── ● red dot + route text (red) | date (grey) — plain white row
class _RouteRow extends StatelessWidget {
  final QuoteModel quote;
  const _RouteRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              quote.destination,
              style: AppTextStyles.quoteHeaderRoute,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            DateFormatter.display(quote.quoteDate),
            style: AppTextStyles.quoteHeaderDate,
          ),
        ],
      ),
    );
  }
}

// ── white background, horizontal 16px padding, 8px top gap from route row
// ── Row 1: 3 individual bordered cards — SELLING | BUY PRICE | INCIDENTAL
// ── 10px gap
// ── Row 2: 2 individual bordered cards — GP AMT | GP %
class _MetricsCard extends StatelessWidget {
  final QuoteModel quote;
  const _MetricsCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    final rate = quote.forex;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricSelling,
                    value: CurrencyFormatter.usd(quote.billingAmount),
                    subValue: CurrencyFormatter.php(quote.billingAmount * rate),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricBuyPrice,
                    value: CurrencyFormatter.usd(quote.buyPrice),
                    subValue: CurrencyFormatter.php(quote.buyPrice * rate),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricIncidental,
                    value: CurrencyFormatter.usd(quote.incidentalAmount),
                    subValue: CurrencyFormatter.php(quote.incidentalAmount * rate),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.metricPadding),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricGpAmt,
                    value: CurrencyFormatter.usd(quote.gpAmount),
                    subValue: CurrencyFormatter.php(quote.gpAmount * rate),
                    valueColor: quote.gpAmount >= 0
                        ? AppColors.textPrimary
                        : AppColors.negativeValue,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricGpPct,
                    value: CurrencyFormatter.percent(quote.gpPercentage),
                    valueColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          ),  // IntrinsicHeight
        ],
      ),
    );
  }
}

// Individual metric card — white, 1px border, rounded, no shadow
class _MetricCard extends StatelessWidget {
  final Widget child;
  const _MetricCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.metricPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}
