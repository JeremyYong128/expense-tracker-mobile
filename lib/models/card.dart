class Card {
  final int? id;
  final String name;
  final String rewardType;
  final double rewardRate;
  final String colorHex;
  final bool isActive;
  final int sortOrder;

  Card({
    this.id,
    required this.name,
    required this.rewardType,
    required this.rewardRate,
    required this.colorHex,
    this.isActive = true,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rewardType': rewardType,
      'rewardRate': rewardRate,
      'colorHex': colorHex,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  Card copyWith({
    int? id,
    String? name,
    String? rewardType,
    double? rewardRate,
    String? colorHex,
    bool? isActive,
    int? sortOrder,
  }) {
    return Card(
      id: id ?? this.id,
      name: name ?? this.name,
      rewardType: rewardType ?? this.rewardType,
      rewardRate: rewardRate ?? this.rewardRate,
      colorHex: colorHex ?? this.colorHex,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      name: map['name'],
      rewardType: map['rewardType'],
      rewardRate: map['rewardRate'],
      colorHex: map['colorHex'] ?? '#9E9E9E',
      isActive: map['isActive'] ?? true,
    );
  }
}
