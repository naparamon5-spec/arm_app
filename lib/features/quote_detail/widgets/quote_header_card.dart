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
          _NavHeader(quote: quote),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          _RouteRow(quote: quote),
          _SubjectRow(quote: quote),
          _MetricsCard(quote: quote),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ── ← back │ "QUOTE APPROVAL" + quote number stacked centered │ spacer
class _NavHeader extends StatelessWidget {
  final QuoteModel quote;
  const _NavHeader({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.textSecondary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.quoteApproval,
                    style: AppTextStyles.quoteHeaderLabel,
                  ),
                  const SizedBox(height: 2),
                  Text(quote.quoteNumber,
                      style: AppTextStyles.quoteHeaderNumber),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── pill tag (dot + destination) | date outside pill
class _RouteRow extends StatelessWidget {
  final QuoteModel quote;
  const _RouteRow({required this.quote});

  static const TextStyle _pillTextStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFFD32F2F),
  );

  /// Product and customer joined by a centered dot. Drops either side
  /// (and the dot) when empty.
  String _productCustomerLabel() {
    return [
      quote.product.toUpperCase(),
      quote.customer,
    ].where((s) => s.trim().isNotEmpty).join('  •  ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.60,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _productCustomerLabel(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _pillTextStyle,
            ),
          ),
          const Spacer(),
          Text(
            DateFormatter.display(quote.quoteDate),
            style: AppTextStyles.quoteHeaderDate,
          ),
        ],
      ),
    );
  }
}

// ── Subject line, shown above the metrics so it's easy to check at a glance.
// Hidden when the quote has no subject.
class _SubjectRow extends StatelessWidget {
  final QuoteModel quote;
  const _SubjectRow({required this.quote});

  @override
  Widget build(BuildContext context) {
    if (quote.subject.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.labelSubject.toUpperCase()}: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              quote.subject.trim(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
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

  /// Whether the quote's native currency is PHP (`currency_id` = "Php").
  /// When true the PHP value is shown on top and USD below; otherwise USD
  /// stays on top with PHP below.
  bool get _isPhp => quote.currencyId.toUpperCase().contains('PHP');

  /// Primary (top) value for a USD-denominated [amount].
  String _primary(double amount) => _isPhp
      ? CurrencyFormatter.php(amount * quote.forex)
      : CurrencyFormatter.usd(amount);

  /// Secondary (bottom) value for a USD-denominated [amount].
  String _sub(double amount) => _isPhp
      ? CurrencyFormatter.usd(amount)
      : CurrencyFormatter.php(amount * quote.forex);

  @override
  Widget build(BuildContext context) {
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
                    value: _primary(quote.billingAmount),
                    subValue: _sub(quote.billingAmount),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricBuyPrice,
                    value: _primary(quote.buyPrice),
                    subValue: _sub(quote.buyPrice),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  child: MetricTile(
                    label: AppStrings.metricIncidental,
                    value: _primary(quote.incidentalAmount),
                    subValue: _sub(quote.incidentalAmount),
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
                      value: _primary(quote.gpAmount),
                      subValue: _sub(quote.gpAmount),
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
          ), // IntrinsicHeight
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}
