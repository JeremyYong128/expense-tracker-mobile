class Validators {
  /// Checks if a field is empty.
  static String? required(
    String? value, [
    String message = 'This field is required.',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Checks if a field is a valid number.
  static String? number(String? value, [String message = 'Invalid number.']) {
    final reqError = required(value, message);
    if (reqError != null) return reqError;

    if (double.tryParse(value!) == null) {
      return message;
    }
    return null;
  }

  /// Checks if a field is a number greater than zero.
  static String? greaterThanZero(
    String? value, [
    String message = 'Amount must be greater than 0.',
  ]) {
    final numError = number(value, message);
    if (numError != null) return numError;

    final parsed = double.parse(value!);
    if (parsed <= 0) {
      return message;
    }
    return null;
  }

  /// Checks if an amount is valid (> 0 and max 2 decimal places).
  static String? amount(String? value) {
    final gtZero = greaterThanZero(value);
    if (gtZero != null) return gtZero;

    final parts = value!.trim().split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return 'Invalid amount.';
    }
    return null;
  }

  /// Checks if a reward amount is valid (>= 0 and max 2 decimal places).
  static String? rewardAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value);
    final parts = value.trim().split('.');

    if (parsed == null ||
        parsed < 0 ||
        (parts.length == 2 && parts[1].length > 2)) {
      return 'Invalid amount.';
    }

    return null;
  }
}
