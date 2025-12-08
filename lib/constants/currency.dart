import 'package:intl/intl.dart';

class AppCurrency {
  // Use textual currency code with trailing space to avoid font issues with peso symbol.
  static const String symbol = 'PHP ';
  static final Map<int, NumberFormat> _cachedFormatters = {};

  static NumberFormat _getFormatter(int decimals) {
    return _cachedFormatters.putIfAbsent(
      decimals,
      () => NumberFormat.currency(
        locale: 'en_PH',
        symbol: symbol.trim(),
        decimalDigits: decimals,
      ),
    );
  }

  static String format(num amount, {int decimals = 2}) {
    final formatter = _getFormatter(decimals);
    // Ensure a space after code (NumberFormat strips trailing space in symbol definition).
    final formatted = formatter.format(amount);
    return formatted.startsWith('PHP') ? 'PHP ${formatted.substring(3)}' : formatted;
  }
}
