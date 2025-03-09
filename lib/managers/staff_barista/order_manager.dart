import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/staff_barista/order_service.dart';

class OrderManager with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      _orders = await _orderService.fetchOrders();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Lỗi khi tải đơn: $e");
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOrder(int orderId, int employeeId) async {
    try {
      await _orderService.completeOrder(orderId, employeeId);
      fetchOrders();
    } catch (e) {
      print("Lỗi khi cập nhật đơn: $e");
      throw e;
    }
  }
}
