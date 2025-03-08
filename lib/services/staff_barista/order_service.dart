import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/order.dart';

class OrderService {
  final String? baseUrl = dotenv.env['BARISTA_URL'];

  Future<List<Order>> fetchOrders() async {
    final url = Uri.parse('$baseUrl/orders');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((order) => Order.fromJson(order)).toList();
        }
      } else {
        throw Exception('Thất bại tải đơn hàng');
      }
    } catch (e) {
      throw Exception('Lỗi tải đơn hàng: $e');
    }
    throw Exception('Thất bại tải đơn hàng');
  }

  Future<void> completeOrder(int orderId, int employeeId) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/complete');

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'employee_id': employeeId}),
      );
    } catch (e) {
      print('Lỗi khi gửi request: $e');
    }
  }
}
