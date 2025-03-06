import 'package:flutter/material.dart';
import '../../models/ingredient.dart';
import '../../services/staff_barista/ingredient_service.dart';

class IngredientManager with ChangeNotifier {
  final IngredientService _service = IngredientService();
  List<Ingredient> _ingredients = [];
  List<Ingredient> _filteredIngredients = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Ingredient> get ingredients => _filteredIngredients;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadIngredients() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final ingredients = await _service.fetchIngredients();
      _ingredients = ingredients;
      _filteredIngredients = List.from(_ingredients);
    } catch (e) {
      _errorMessage = 'Thất bại tải nguyên liệu';
      _ingredients = []; // Đảm bảo không để danh sách bị null
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchIngredient(String query) {
    if (query.isEmpty) {
      _filteredIngredients = List.from(_ingredients);
    } else {
      _filteredIngredients = _ingredients
          .where((ingredient) =>
              ingredient.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  //Cập nhật số lượng
  Future<void> updateQuantity(int ingredientId, double newQuantity,
      int employeeId, String reason) async {
    try {
      await _service.updateIngredientQuantity(
          ingredientId, newQuantity, employeeId, reason);

      final index =
          _ingredients.indexWhere((ing) => ing.ingredientId == ingredientId);
      if (index != -1) {
        _ingredients[index] =
            _ingredients[index].copyWith(quantity: newQuantity);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Cập nhật thất bại';
      notifyListeners();
    }
  }
}
