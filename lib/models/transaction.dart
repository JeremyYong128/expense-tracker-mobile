class Transaction {
  final int? id;
  final double amount;
  final String title;
  final DateTime date;
  final int categoryId;
  final String? note;
  final bool isIncome;
  final int? recurringId;

  Transaction({
    this.id,
    required this.amount,
    required this.title,
    required this.date,
    required this.categoryId,
    this.note,
    this.isIncome = false,
    this.recurringId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'title': title,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'note': note,
      'isIncome': isIncome ? 1 : 0,
      'recurringId': recurringId,
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? title,
    DateTime? date,
    int? categoryId,
    String? note,
    bool? isIncome,
    int? recurringId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      recurringId: recurringId ?? this.recurringId,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      note: map['note'],
      isIncome: map['isIncome'] == 1,
      recurringId: map['recurringId'],
    );
  }
}
