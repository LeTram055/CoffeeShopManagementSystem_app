import 'ingredient.dart';

class MenuIngredient {
  final int itemId;
  final int ingredientId;
  final double quantityPerUnit;
  final Ingredient ingredient;

  MenuIngredient({
    required this.itemId,
    required this.ingredientId,
    required this.quantityPerUnit,
    required this.ingredient,
  });

  factory MenuIngredient.fromJson(Map<String, dynamic> json) {
    return MenuIngredient(
      itemId: json['item_id'],
      ingredientId: json['ingredient_id'],
      quantityPerUnit: (json['quantity_per_unit'] is num)
          ? (json['quantity_per_unit'] as num).toDouble()
          : double.tryParse(json['quantity_per_unit'].toString()) ?? 0.0,
      ingredient: Ingredient.fromJson(json['ingredient']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'ingredient_id': ingredientId,
      'quantity_per_unit': quantityPerUnit,
      'ingredient': ingredient.toJson(),
    };
  }
}
