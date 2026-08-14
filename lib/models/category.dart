class Category {
  final int? id;
  final String name;
  final String? colorHex;
  final String? iconString;

  Category({
    this.id,
    required this.name,
    this.colorHex,
    this.iconString,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconString': iconString,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['colorHex'],
      iconString: map['iconString'],
    );
  }
}
