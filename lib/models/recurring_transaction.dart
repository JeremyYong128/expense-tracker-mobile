class RecurringTransaction {
  final int? id;
  final double amount;
  final String title;
  final int categoryId;
  final String? note;
  final bool isIncome;
  final int interval;
  final String period;
  final DateTime startDate;
  final DateTime nextDueDate;
  final int? creditCardId;

  RecurringTransaction({
    this.id,
    required this.amount,
    required this.title,
    required this.categoryId,
    this.note,
    this.isIncome = false,
    required this.interval,
    required this.period,
    required this.startDate,
    required this.nextDueDate,
    this.creditCardId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'title': title,
      'categoryId': categoryId,
      'note': note,
      'isIncome': isIncome ? 1 : 0,
      'interval': interval,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'creditCardId': creditCardId,
    };
  }

  RecurringTransaction copyWith({
    int? id,
    double? amount,
    String? title,
    int? categoryId,
    String? note,
    bool? isIncome,
    int? interval,
    String? period,
    DateTime? startDate,
    DateTime? nextDueDate,
    int? creditCardId,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      interval: interval ?? this.interval,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      creditCardId: creditCardId ?? this.creditCardId,
    );
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'],
      amount: map['amount'],
      title: map['title'],
      categoryId: map['categoryId'],
      note: map['note'],
      isIncome: map['isIncome'] == 1,
      interval: map['interval'],
      period: map['period'],
      startDate: DateTime.parse(map['startDate']),
      nextDueDate: DateTime.parse(map['nextDueDate']),
      creditCardId: map['creditCardId'],
    );
  }
}
