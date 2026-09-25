import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker_mobile/utils/logger.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://api.frankfurter.app';

  /// Converts [amount] from [fromCurrency] to [toCurrency] using live rates.
  /// If [fromCurrency] and [toCurrency] are the same, returns [amount].
  /// Returns null if the conversion fails (e.g., no internet, unsupported currency).
  static Future<double?> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final url = Uri.parse('$_baseUrl/latest?from=$fromCurrency&to=$toCurrency');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        if (rates.containsKey(toCurrency)) {
          final rate = (rates[toCurrency] as num).toDouble();
          return amount * rate;
        }
      } else {
        AppLogger.error(
          'Failed to fetch exchange rate: ${response.statusCode}',
          null,
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      AppLogger.error('ExchangeRateService exception', e, stack);
    }
    
    return null;
  }
}
