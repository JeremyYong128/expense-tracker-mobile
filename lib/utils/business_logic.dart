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

  static DateTime calculateNextDueDate(
    DateTime date,
    int interval,
    String period,
  ) {
    switch (period.toLowerCase()) {
      case 'day(s)':
        return date.add(Duration(days: interval));
      case 'week(s)':
        return date.add(Duration(days: interval * 7));
      case 'month(s)':
        int nextMonth = date.month + interval;
        int nextYear = date.year;
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        int nextDay = date.day;
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        if (nextDay > daysInNextMonth) {
          nextDay = daysInNextMonth;
        }
        return DateTime(nextYear, nextMonth, nextDay, date.hour, date.minute);
      case 'year(s)':
        int nextYear = date.year + interval;
        int nextDay = date.day;
        final daysInNextMonth = DateTime(nextYear, date.month + 1, 0).day;
        if (nextDay > daysInNextMonth) {
          nextDay = daysInNextMonth;
        }
        return DateTime(nextYear, date.month, nextDay, date.hour, date.minute);
      default:
        return date.add(Duration(days: interval));
    }
  }
}
