import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../managers/auth_manager.dart';
import '../../models/employee.dart';
import 'change_password.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    final Employee? employee = authManager.currentUser;

    // Hàm chuyển đổi vai trò sang tiếng Việt
    String getRole(String? role) {
      switch (role) {
        case "staff_serve":
          return "Nhân viên phục vụ";
        case "staff_barista":
          return "Nhân viên pha chế";
        default:
          return "Không xác định";
      }
    }

    // Hàm định dạng ngày
    String formatDate(String? date) {
      if (date == null) return "Không có dữ liệu";
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        return "Không hợp lệ";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_nbg.png',
              height: 60, // Giảm kích thước ảnh nếu cần
            ),
            const SizedBox(width: 8),
            const Text(
              'Thông tin nhân viên',
              style: TextStyle(fontFamily: 'Prata'),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card chứa thông tin nhân viên
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Tên", employee?.name),
                    _buildInfoRow("Số điện thoại", employee?.phoneNumber),
                    _buildInfoRow("Email", employee?.email),
                    _buildInfoRow("Địa chỉ", employee?.address),
                    _buildInfoRow(
                        "Ngày bắt đầu", formatDate(employee?.startDate)),
                    _buildInfoRow("Vai trò", getRole(employee?.role)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ChangePassword(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Đổi mật khẩu",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Khoảng cách giữa 2 nút
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Đăng xuất",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị mỗi dòng thông tin trong Card
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value ?? "Không có dữ liệu",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  Provider.of<AuthManager>(context, listen: false).logout();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Đăng xuất thành công!'),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    ),
  );
}
