import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _display = DateFormat('MMM dd, yyyy');
  static final _short = DateFormat('MMM dd');

  static String display(DateTime date) => _display.format(date);
  static String short(DateTime date) => _short.format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return _short.format(date);
  }
}
