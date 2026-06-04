import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _usd = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _php = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  static String usd(double amount) => _usd.format(amount);
  static String php(double amount) => _php.format(amount);
  static String percent(double value) => '${value.toStringAsFixed(2)}%';

  /// Converts a fractional rate to a whole-number percent shown with four
  /// decimals (e.g. 0.01 -> "1.0000", 0.12 -> "12.0000").
  static String percentWhole(double value) =>
      (value * 100).roundToDouble().toStringAsFixed(4);
}
