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

  // Future<Map<String, dynamic>> getProfile(String username) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/profile'),
  //     headers: {
  //       'Authorization': 'Bearer $username',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load profile');
  //   }
  // }

  Future<List<dynamic>> getWorkSchedules(String username,
      {int? month, int? year}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/work-schedules?username=$username&month=$month&year=$year'),
    );
    return response.statusCode == 200
        ? jsonDecode(response.body)
        : throw Exception('Lỗi tải lịch làm việc');
  }

  Future<List<dynamic>> getBonusesPenalties(String username,
      {int? month, int? year}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/bonuses-penalties?username=$username&month=$month&year=$year'),
    );
    return response.statusCode == 200
        ? jsonDecode(response.body)
        : throw Exception('Lỗi tải thưởng/phạt');
  }

  Future<List<dynamic>> getSalaries(String username,
      {int? month, int? year}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/salaries?username=$username&month=$month&year=$year'),
    );
    return response.statusCode == 200
        ? jsonDecode(response.body)
        : throw Exception('Lỗi tải lương');
  }
}
