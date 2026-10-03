class Transaction {
  final int? id;
  final double amount;
  final String title;
  final DateTime date;
  final int categoryId;
  final String? note;
  final bool isIncome;
  final int? recurringId;
  final int? cardId;
  final double? rewardAmount;
  final String currencyCode;
  final double baseCurrencyAmount;
  final bool isPending;
  final double billingAmount;
  final String billingCurrencyCode;

  Transaction({
    this.id,
    required this.amount,
    required this.title,
    required this.date,
    required this.categoryId,
    this.note,
    this.isIncome = false,
    this.recurringId,
    this.cardId,
    this.rewardAmount,
    this.currencyCode = 'SGD',
    required this.baseCurrencyAmount,
    this.isPending = false,
    required this.billingAmount,
    required this.billingCurrencyCode,
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
      'cardId': cardId,
      'rewardAmount': rewardAmount,
      'currencyCode': currencyCode,
      'baseCurrencyAmount': baseCurrencyAmount,
      'isPending': isPending ? 1 : 0,
      'billingAmount': billingAmount,
      'billingCurrencyCode': billingCurrencyCode,
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
    int? cardId,
    double? rewardAmount,
    String? currencyCode,
    double? baseCurrencyAmount,
    bool? isPending,
    double? billingAmount,
    String? billingCurrencyCode,
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
      cardId: cardId ?? this.cardId,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      baseCurrencyAmount: baseCurrencyAmount ?? this.baseCurrencyAmount,
      isPending: isPending ?? this.isPending,
      billingAmount: billingAmount ?? this.billingAmount,
      billingCurrencyCode: billingCurrencyCode ?? this.billingCurrencyCode,
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
      cardId: map['cardId'],
      rewardAmount: map['rewardAmount'],
      currencyCode: map['currencyCode'] ?? 'SGD',
      baseCurrencyAmount: map['baseCurrencyAmount'] ?? map['amount'],
      isPending: map['isPending'] == 1 || map['isPending'] == true,
      billingAmount: map['billingAmount'] ?? map['amount'],
      billingCurrencyCode: map['billingCurrencyCode'] ?? map['currencyCode'] ?? 'SGD',
    );
  }
}
