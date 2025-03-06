import 'package:flutter/foundation.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart' as coffee_category;
import '../../services/staff_barista/menu_sevice.dart';

class MenuManager with ChangeNotifier {
  final MenuService _menuService = MenuService();
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredItems = [];
  List<coffee_category.Category> _categories = [];
  int _selectedCategoryId = 0; // 0 là 'Tất cả'

  bool _isLoading = true; // 🔥 Thêm biến kiểm tra trạng thái loading

  List<MenuItem> get menuItems {
    if (_selectedCategoryId == 0) {
      return _filteredItems; // Hiển thị danh sách tìm kiếm đúng
    } else {
      return _filteredItems
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }
  }

  List<coffee_category.Category> get categories => _categories;
  int get selectedCategoryId => _selectedCategoryId;

  bool get isLoading => _isLoading;

  Future<void> fetchMenuItems() async {
    try {
      _isLoading = true; // Bắt đầu tải
      notifyListeners();

      _menuItems = await _menuService.fetchMenuItems();
      _filteredItems = List.from(_menuItems);

      _isLoading = false; // Đã tải xong
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print("Lỗi khi tải menu: $error");
      throw error;
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _menuService.fetchCategories();
      notifyListeners();
    } catch (error) {
      print("Lỗi khi tải danh mục: $error");
      throw error;
    }
  }

  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void searchMenu(String query) {
    if (query.isEmpty) {
      _filteredItems = List.from(_menuItems);
    } else {
      _filteredItems = _menuItems
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void toggleAvailability(int itemId) async {
    final index = _menuItems.indexWhere((item) => item.itemId == itemId);
    if (index != -1) {
      await _menuService.toggleAvailability(itemId);
      _menuItems[index].isAvailable = !_menuItems[index].isAvailable;
      notifyListeners();
    }
  }
}
