class Validators {
  /// Checks if a field is empty.
  static String? required(String? value, [String message = 'This field is required.']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Checks if a field is a valid number.
  static String? number(String? value, [String message = 'Please enter a valid number.']) {
    final reqError = required(value, message);
    if (reqError != null) return reqError;

    if (double.tryParse(value!) == null) {
      return message;
    }
    return null;
  }

  /// Checks if a field is a number greater than zero.
  static String? greaterThanZero(String? value, [String message = 'Please enter an amount greater than 0.']) {
    final numError = number(value, message);
    if (numError != null) return numError;

    final parsed = double.parse(value!);
    if (parsed <= 0) {
      return message;
    }
    return null;
  }
}
