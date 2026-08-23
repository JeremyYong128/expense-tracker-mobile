class CreditCard {
  final int? id;
  final String name;
  final String rewardType;
  final double rewardRate;

  CreditCard({
    this.id,
    required this.name,
    required this.rewardType,
    required this.rewardRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rewardType': rewardType,
      'rewardRate': rewardRate,
    };
  }

  CreditCard copyWith({
    int? id,
    String? name,
    String? rewardType,
    double? rewardRate,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      rewardType: rewardType ?? this.rewardType,
      rewardRate: rewardRate ?? this.rewardRate,
    );
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      name: map['name'],
      rewardType: map['rewardType'],
      rewardRate: map['rewardRate'],
    );
  }
}
