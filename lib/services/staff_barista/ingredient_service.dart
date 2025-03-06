import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../models/ingredient.dart';

class IngredientService {
  final String? baseUrl = dotenv.env['BARISTA_URL'];

  Future<List<Ingredient>> fetchIngredients() async {
    final url = Uri.parse('$baseUrl/ingredients');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Ingredient.fromJson(json)).toList();
      } else {
        throw Exception('Thất bại tải nguyên liệu');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  //Cập nhật số lượng
  Future<void> updateIngredientQuantity(int ingredientId, double newQuantity,
      int employeeId, String reason) async {
    final url = Uri.parse('$baseUrl/ingredients/$ingredientId/update-quantity');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'quantity': newQuantity,
          'employee_id': employeeId,
          'reason': reason,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Cập nhật số lượng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
