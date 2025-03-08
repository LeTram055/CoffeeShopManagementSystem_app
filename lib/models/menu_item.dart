import 'menu_ingredient.dart';

class MenuItem {
  final int itemId;
  final String name;
  final String imageUrl;
  final String? description;
  final double price;
  bool isAvailable;
  final int categoryId;
  final List<MenuIngredient> ingredients;

  MenuItem({
    required this.itemId,
    required this.name,
    required this.imageUrl,
    this.description,
    required this.price,
    required this.isAvailable,
    required this.categoryId,
    required this.ingredients,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      description: json['description'],
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      isAvailable: json['is_available'] == 1,
      categoryId: json['category_id'],
      ingredients: (json['ingredients'] != null && json['ingredients'] is List)
          ? (json['ingredients'] as List)
              .map((ingredientJson) => MenuIngredient.fromJson(ingredientJson))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'price': price,
      'is_available': isAvailable ? 1 : 0,
      'category_id': categoryId,
      'ingredients': ingredients.map((ing) => ing.toJson()).toList(),
    };
  }
}
