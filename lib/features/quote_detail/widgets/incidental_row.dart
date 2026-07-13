import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/incidental_model.dart';

class IncidentalRow extends StatelessWidget {
  final IncidentalModel incidental;
  final double forex;

  /// Quote currency (`currency_id`, e.g. "Php"). Drives which currency is shown
  /// on top so the row matches the header card's metrics.
  final String currencyId;

  const IncidentalRow({
    super.key,
    required this.incidental,
    required this.forex,
    this.currencyId = '',
  });

  /// Whether the quote's native currency is PHP. When true the PHP value is
  /// shown on top and USD below; otherwise USD stays on top with PHP below.
  bool get _isPhp => currencyId.toUpperCase().contains('PHP');

  /// USD amount (from the API's `amount_dol`).
  double get _usd => incidental.amount;

  /// PHP amount — the API's own `amount` when available, otherwise derived from
  /// the USD value × forex (e.g. for mock data).
  double get _php => incidental.amountPhp ?? incidental.amount * forex;

  /// Primary (top) value — native currency first.
  String get _primary =>
      _isPhp ? CurrencyFormatter.php(_php) : CurrencyFormatter.usd(_usd);

  /// Secondary (bottom) value — the other currency.
  String get _sub =>
      _isPhp ? CurrencyFormatter.usd(_usd) : CurrencyFormatter.php(_php);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incidental.type, style: AppTextStyles.incidentalTypeName),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  incidental.description,
                  style: AppTextStyles.incidentalDescription,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _primary,
                style: AppTextStyles.incidentalAmount,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _sub,
                style: AppTextStyles.incidentalAmountSub,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
