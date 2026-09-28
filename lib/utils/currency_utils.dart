import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const List<String> commonCurrencies = [
    'SGD', 'USD', 'EUR', 'JPY', 'MYR', 'THB', 'GBP', 'AUD', 'CAD'
  ];

  static String format(double amount, String currencyCode) {
    // Automatically formats with the correct symbol and decimal places
    // E.g., USD -> $50.00, JPY -> ¥5,000
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.format(amount);
  }
}
