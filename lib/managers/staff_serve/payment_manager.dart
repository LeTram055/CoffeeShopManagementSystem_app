import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/staff_serve/payment_service.dart';

class PaymentManager extends ChangeNotifier {
  List<Payment> _paidOrders = [];
  bool _isLoading = false;

  List<Payment> get paidOrders => _paidOrders;
  bool get isLoading => _isLoading;

  final PaymentService _paymentService = PaymentService();

  Future<void> loadPaidOrders({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _paidOrders = await _paymentService.fetchPaidOrders(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print("Lỗi tải đơn đã thanh toán: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> saveInvoiceToDownloads(String filePath) async {
    try {
      return await _paymentService.saveToDownloads(filePath);
    } catch (error) {
      print('Lỗi khi lưu file: $error');
      throw Exception('Không thể lưu file');
    }
  }

  Future<String> fetchInvoicePdf(int paymentId) async {
    try {
      return await _paymentService.fetchInvoicePdf(paymentId);
    } catch (error) {
      throw error;
    }
  }
}
