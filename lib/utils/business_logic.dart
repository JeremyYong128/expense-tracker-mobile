class BusinessLogic {
  /// Calculates the percentage change between a current value and a previous value.
  /// Returns null if both values are 0.
  static double? calculatePercentageChange(double currentValue, double previousValue) {
    if (previousValue != 0) {
      return ((currentValue - previousValue) / previousValue.abs()) * 100;
    } else if (currentValue != 0) {
      return currentValue > 0 ? 100.0 : -100.0;
    }
    return null;
  }
  /// Calculates the absolute difference between a current value and a previous value.
  static double calculateAbsoluteDifference(double currentValue, double previousValue) {
    return currentValue - previousValue;
  }
}
