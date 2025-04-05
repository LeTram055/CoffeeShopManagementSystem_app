import 'package:flutter/material.dart';
import '../../models/table.dart' as table_model;
import '../../models/customer.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../models/promotion.dart';
import '../../models/payment.dart';
import '../../services/staff_serve/order_service.dart';

class OrderServeManager extends ChangeNotifier {
  final OrderServeService _orderService = OrderServeService();
  List<table_model.Table> _tables = [];
  List<Customer> _customers = [];
  List<MenuItem> _menu = [];
  List<Promotion> _promotions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<table_model.Table> get tables => _tables;
  List<Customer> get customers => _customers;
  List<MenuItem> get menuItems => _menu;
  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadTables() async {
    print("🔄 Đang tải danh sách bàn...");
    _isLoading = true;
    notifyListeners();

    try {
      _tables = await _orderService.fetchTables();
      print("✅ Danh sách bàn đã cập nhật: ${_tables.length}");
    } catch (error) {
      print("Lỗi khi tải bàn: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _orderService.fetchCustomers();
    } catch (error) {
      print("Lỗi khi tải khách hàng: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addCustomer(String name, String? phoneNumber) async {
    try {
      Customer? newCustomer =
          await _orderService.addCustomer(name, phoneNumber);
      if (newCustomer != null) {
        _customers.add(newCustomer);
        notifyListeners();
        return null; // Không có lỗi
      }
    } catch (error) {
      return error.toString(); // Trả về lỗi chính xác
    }

    return "Lỗi không xác định";
  }

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      _menu = await _orderService.fetchMenu();
    } catch (error) {
      print("Lỗi khi tải khách hàng: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createOrder(Order order) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;

    notifyListeners();

    try {
      final message = await _orderService.createOrder(order);
      _successMessage = message;
    } catch (error) {
      final rawError = error.toString();
      if (rawError.startsWith('Exception: ')) {
        _errorMessage = rawError.replaceFirst('Exception: ', '');
      } else {
        _errorMessage = rawError;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> getOrderByTableId(int tableId) async {
    //_isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.fetchOrderByTableId(tableId);

      return order;
    } catch (error) {
      _errorMessage = error.toString();
      print("Lỗi khi lấy đơn hàng: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> updateOrder(Order order) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final message = await _orderService.updateOrder(order);
      _successMessage = message;
    } catch (error) {
      final rawError = error.toString();
      if (rawError.startsWith('Exception: ')) {
        _errorMessage = rawError.replaceFirst('Exception: ', '');
      } else {
        _errorMessage = rawError;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelOrder(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final message = await _orderService.cancelOrder(orderId);
      _successMessage = message;
    } catch (error) {
      final rawError = error.toString();
      if (rawError.startsWith('Exception: ')) {
        _errorMessage = rawError.replaceFirst('Exception: ', '');
      } else {
        _errorMessage = rawError;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOrder(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.completeOrder(orderId);
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPromotions(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _promotions = await _orderService.fetchPromotions(orderId);
    } catch (error) {
      print("Lỗi khi tải khuyến mãi: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> savePayment(Payment payment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.savePayment(payment);
    } catch (error) {
      _errorMessage = error.toString();
      print("Lỗi khi lưu thanh toán: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
  }
}
