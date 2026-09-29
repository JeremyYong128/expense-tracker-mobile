import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const List<String> commonCurrencies = [
    'SGD',
    'USD',
    'EUR',
    'JPY',
    'MYR',
    'THB',
    'GBP',
    'AUD',
    'CAD',
  ];

  static const Map<String, String> customSymbols = {
    'USD': 'US\$',
    'MYR': 'RM',
    // Add any other custom overrides here
  };

  static String getSymbol(String currencyCode) {
    if (customSymbols.containsKey(currencyCode)) {
      return customSymbols[currencyCode]!;
    }
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  static String format(double amount, String currencyCode) {
    final customSymbol = customSymbols[currencyCode];
    if (customSymbol != null) {
      final format = NumberFormat.currency(
        name: currencyCode,
        symbol: customSymbol,
      );
      return format.format(amount);
    }

    // Automatically formats with the correct symbol and decimal places
    // E.g., USD -> $50.00, JPY -> ¥5,000
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.format(amount);
  }
}
