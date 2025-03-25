import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/table.dart';
import '../../models/customer.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../models/promotion.dart';
import '../../models/payment.dart';

class OrderServeService {
  final String? baseUrl = dotenv.env['SERVE_URL'];

  Future<List<Table>> fetchTables() async {
    final url = Uri.parse('$baseUrl/tables');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("data") && responseData["data"] is List) {
          List<dynamic> data = responseData["data"];
          return data.map((json) => Table.fromJson(json)).toList();
        } else {
          throw Exception('Dữ liệu không hợp lệ');
        }
      } else {
        throw Exception('Thất bại tải dữ liệu bàn');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<List<Customer>> fetchCustomers() async {
    final url = Uri.parse('$baseUrl/customers');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("data") && responseData["data"] is List) {
          List<dynamic> data = responseData["data"];
          return data.map((json) => Customer.fromJson(json)).toList();
        } else {
          throw Exception('Dữ liệu khách hàng không hợp lệ');
        }
      } else {
        throw Exception('Thất bại khi tải danh sách khách hàng');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<Customer?> addCustomer(String name, String? phoneNumber) async {
    final url = Uri.parse('$baseUrl/customers');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'name': name, 'phone_number': phoneNumber}),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Customer.fromJson(responseData['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw errorData['message'] ?? 'Không thể thêm khách hàng';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<MenuItem>> fetchMenu() async {
    final url = Uri.parse('$baseUrl/menu');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("data") && responseData["data"] is List) {
          List<dynamic> data = responseData["data"];
          return data.map((json) => MenuItem.fromJson(json)).toList();
        } else {
          throw Exception('Dữ liệu khách hàng không hợp lệ');
        }
      } else {
        throw Exception('Thất bại khi tải danh sách khách hàng');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<void> createOrder(Order order) async {
    final url = Uri.parse('$baseUrl/orders/create');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Cập nhật số lượng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<Order?> fetchOrderByTableId(int tableId) async {
    final url = Uri.parse('$baseUrl/orders/$tableId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return Order.fromJson(responseData['data']);
        }
      } else {
        throw Exception('Không thể tải đơn hàng');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
    return null;
  }

  Future<void> updateOrder(Order order) async {
    final url = Uri.parse('$baseUrl/orders/update');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Cập nhật số lượng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<void> cancelOrder(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/cancel/$orderId');
    try {
      final response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception('Hủy đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<void> completeOrder(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/complete/$orderId');
    try {
      final response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception('Hoàn thành đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<List<Promotion>> fetchPromotions(int orderId) async {
    final url = Uri.parse('$baseUrl/promotions/$orderId');
    try {
      final response = await http.get(url);
      print('Response: ${response.body}');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("data") && responseData["data"] is List) {
          List<dynamic> data = responseData["data"];
          return data.map((json) => Promotion.fromJson(json)).toList();
        } else {
          throw Exception('Dữ liệu không hợp lệ');
        }
      } else {
        throw Exception('Thất bại tải dữ liệu khuyến mãi');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<void> savePayment(Payment payment) async {
    final url = Uri.parse('$baseUrl/payment/create');

    print(jsonEncode(payment.toJson()));

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payment.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Cập nhật số lượng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
