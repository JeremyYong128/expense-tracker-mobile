class CreditCard {
  final int? id;
  final String name;
  final String rewardType;
  final double rewardRate;
  final bool isActive;

  CreditCard({
    this.id,
    required this.name,
    required this.rewardType,
    required this.rewardRate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rewardType': rewardType,
      'rewardRate': rewardRate,
      'isActive': isActive,
    };
  }

  CreditCard copyWith({
    int? id,
    String? name,
    String? rewardType,
    double? rewardRate,
    bool? isActive,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      rewardType: rewardType ?? this.rewardType,
      rewardRate: rewardRate ?? this.rewardRate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      name: map['name'],
      rewardType: map['rewardType'],
      rewardRate: map['rewardRate'],
      isActive: map['isActive'] ?? true,
    );
  }
}
