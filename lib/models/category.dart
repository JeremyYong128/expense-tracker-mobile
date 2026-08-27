class Category {
  final int? id;
  final String name;
  final String? colorHex;
  final String? iconString;
  final bool isActive;
  final bool isExpense;
  final bool isIncome;

  Category({
    this.id,
    required this.name,
    this.colorHex,
    this.iconString,
    this.isActive = true,
    this.isExpense = true,
    this.isIncome = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconString': iconString,
      'isActive': isActive ? 1 : 0,
      'isExpense': isExpense ? 1 : 0,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['colorHex'],
      iconString: map['iconString'],
      isActive: map['isActive'] == null ? true : map['isActive'] == 1,
      isExpense: map['isExpense'] == null ? true : map['isExpense'] == 1,
      isIncome: map['isIncome'] == null ? false : map['isIncome'] == 1,
    );
  }
}
