import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/employee.dart';

class AuthManager extends ChangeNotifier {
  Employee? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool isAuth = false;

  Employee? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  AuthManager() {
    _loadUserFromPrefs(); // Load user khi app khởi động
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      if (response!.containsKey('error') && response['error'] == true) {
        _errorMessage = response['message'];
      } else if (response.containsKey('username')) {
        _currentUser = Employee.fromJson(response);
        isAuth = true;
        await _saveUserToPrefs();
      } else {
        _errorMessage = "Sai tài khoản hoặc mật khẩu!";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối máy chủ!";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
          _currentUser!.username, oldPassword, newPassword);

      if (response!.containsKey('error') && response['error'] == true) {
        _errorMessage = response['message'];
        return false;
      } else {
        return true;
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối máy chủ!";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', _currentUser!.toJson());
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        _currentUser = Employee.fromJson(userMap);
        isAuth = true;
      } catch (e) {
        print("Lỗi khi load user: $e");
        _currentUser = null;
        isAuth = false;
      }
    }
    notifyListeners();
  }

  void logout() async {
    _currentUser = null;
    _errorMessage = null;
    isAuth = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }
}
