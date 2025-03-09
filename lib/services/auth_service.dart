import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String? baseUrl = dotenv.env['AUTH_URL'];

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'error': true,
        'message': jsonDecode(response.body)['message'] ?? 'Lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>?> changePassword(
      String username, String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/change-password');
    final response = await http.post(
      url,
      body: {
        'username': username,
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'error': true,
        'message': jsonDecode(response.body)['message'] ?? 'Lỗi không xác định',
      };
    }
  }
}
