import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';

import '../../models/payment.dart';

class PaymentService {
  final String? baseUrl = dotenv.env['SERVE_URL'];

  // Lấy danh sách đơn đã thanh toán
  Future<List<Payment>> fetchPaidOrders(
      {DateTime? startDate, DateTime? endDate}) async {
    final queryParams = {
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };
    final url = Uri.parse('$baseUrl/payment/paid-orders')
        .replace(queryParameters: queryParams);
    //final url = Uri.parse('$baseUrl/payment/paid-orders');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey("data") && responseData["data"] is List) {
        List<dynamic> data = responseData["data"];
        return data.map((json) => Payment.fromJson(json)).toList();
      } else {
        throw Exception('Dữ liệu không hợp lệ');
      }
    } else {
      throw Exception('Thất bại tải dữ liệu đơn hàng đã thanh toán');
    }
  }

  Future<String> saveToDownloads(String filePath) async {
    try {
      final file = File(filePath);

      // Lấy đường dẫn thư mục Tải xuống (Android)
      final downloadsDirectory = Directory('/storage/emulated/0/Download');

      if (!await downloadsDirectory.exists()) {
        throw Exception('Không tìm thấy thư mục Tải xuống');
      }

      // Tạo đường dẫn mới trong thư mục Tải xuống
      final newFilePath = join(downloadsDirectory.path, basename(filePath));

      // Sao chép file sang thư mục Tải xuống
      final newFile = await file.copy(newFilePath);

      return newFile.path; // Trả về đường dẫn file mới
    } catch (error) {
      print('Lỗi khi lưu file: $error');
      throw Exception('Không thể lưu file vào Tải xuống');
    }
  }

  Future<String> fetchInvoicePdf(int paymentId) async {
    final url = Uri.parse('$baseUrl/payment/invoice/$paymentId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final filePath = '${tempDir.path}/invoice_$paymentId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath; // Trả về đường dẫn file
      } else {
        throw Exception('Không thể tải hóa đơn');
      }
    } catch (error) {
      print("Error: $error"); // In lỗi chi tiết
      throw Exception('Lỗi khi kết nối đến server');
    }
  }
}
