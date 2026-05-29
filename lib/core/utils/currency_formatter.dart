import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _usd = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _php = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  static String usd(double amount) => _usd.format(amount);
  static String php(double amount) => _php.format(amount);
  static String percent(double value) => '${value.toStringAsFixed(2)}%';
}
