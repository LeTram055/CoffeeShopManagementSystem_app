class Ingredient {
  final int ingredientId;
  final String name;
  final double quantity;
  final String unit;
  final double minQuantity;
  final DateTime lastUpdated;

  Ingredient({
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minQuantity,
    required this.lastUpdated,
  });

  Ingredient copyWith({
    int? ingredientId,
    String? name,
    double? quantity,
    String? unit,
    double? minQuantity,
    DateTime? lastUpdated,
  }) {
    return Ingredient(
      ingredientId: ingredientId ?? this.ingredientId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minQuantity: minQuantity ?? this.minQuantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientId: json['ingredient_id'],
      name: json['name'],
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toDouble()
          : double.tryParse(json['quantity'].toString()) ?? 0.0,
      minQuantity: (json['min_quantity'] is num)
          ? (json['qmin_quantity'] as num).toDouble()
          : double.tryParse(json['min_quantity'].toString()) ?? 0.0,
      unit: json['unit'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'min_quantity': minQuantity,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
