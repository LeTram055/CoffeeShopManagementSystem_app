import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../managers/auth_manager.dart';
import '../../models/employee.dart';
import 'change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<void> _fetchData = Future.value();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final authManager = Provider.of<AuthManager>(context, listen: false);
        _fetchData = authManager.fetchEmployeeData(
            month: _selectedMonth, year: _selectedYear);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    final Employee? employee = authManager.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_nbg.png',
              height: 60,
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
      body: FutureBuilder<void>(
        future: _fetchData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(employee),
                  const SizedBox(height: 12),
                  _buildFilterSection(),
                  const SizedBox(height: 12),
                  _buildSection(
                      'Lịch làm việc',
                      authManager.workSchedules,
                      (schedule) =>
                          'Ca: ${schedule['shift']['name']} (${schedule['shift']['start_time']} - ${schedule['shift']['end_time']})\nNgày: ${_formatDate(schedule['work_date'])}\nTrạng thái: ${_getStatus(schedule['status'])}'),
                  const SizedBox(height: 12),
                  _buildSection(
                      'Thưởng/Phạt',
                      authManager.bonusesPenalties,
                      (bonusPenalty) =>
                          'Lí do: ${bonusPenalty['reason']}\nSố tiền: ${_formatCurrency(bonusPenalty['amount'])}\nNgày: ${_formatDate(bonusPenalty['date'])}'),
                  const SizedBox(height: 12),
                  _buildSection(
                      'Lương',
                      authManager.salaries,
                      (salary) =>
                          'Tháng: ${salary['month']}\nNăm: ${salary['year']}\nTổng: ${_formatCurrency(salary['total_salary'])}\nThưởng/Phạt: ${_formatCurrency(salary['total_bonus_penalty'])}\nLương cuối: ${_formatCurrency(salary['final_salary'])}\nTrạng thái: ${_getStatus(salary['status'])}'),
                  const SizedBox(height: 12),
                  _buildActionButtons(context),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<int>(
            value: _selectedMonth,
            onChanged: (value) {
              setState(() {
                _selectedMonth = value!;
                _fetchData = Provider.of<AuthManager>(context, listen: false)
                    .fetchEmployeeData(
                        month: _selectedMonth, year: _selectedYear);
              });
            },
            items: List.generate(12, (index) => index + 1)
                .map((month) => DropdownMenuItem<int>(
                      value: month,
                      child: Text('Tháng $month'),
                    ))
                .toList(),
          ),
          DropdownButton<int>(
            value: _selectedYear,
            onChanged: (value) {
              setState(() {
                _selectedYear = value!;
                _fetchData = Provider.of<AuthManager>(context, listen: false)
                    .fetchEmployeeData(
                        month: _selectedMonth, year: _selectedYear);
              });
            },
            items: List.generate(5, (index) => DateTime.now().year - index)
                .map((year) => DropdownMenuItem<int>(
                      value: year,
                      child: Text('Năm $year'),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Employee? employee) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên', employee?.name),
            _buildInfoRow('Số điện thoại', employee?.phoneNumber),
            _buildInfoRow('Email', employee?.email),
            _buildInfoRow('Địa chỉ', employee?.address),
            _buildInfoRow('Ngày bắt đầu', _formatDate(employee?.startDate)),
            _buildInfoRow('Vai trò', _getRole(employee?.role)),
            _buildInfoRow(
                'Lương theo giờ', _formatCurrency(employee?.hourlyRate)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value ?? 'Không có dữ liệu',
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 87, 87, 87))),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<dynamic> items, String Function(dynamic) itemBuilder) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0049ab))),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              // itemBuilder: (context, index) => Text(
              //   itemBuilder(items[index]),
              //   style: const TextStyle(fontSize: 16),
              // ),
              itemBuilder: (context, index) {
                String itemContent = itemBuilder(items[index]);
                List<String> parts = itemContent.split('\n');

                return Column(
                  children: parts.map((part) {
                    List<String> keyValue = part.split(': ');
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            keyValue[0],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            keyValue.length > 1 ? keyValue[1] : '',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 87, 87, 87)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                showDialog(context: context, builder: (_) => ChangePassword()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Đổi mật khẩu',
                style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _logout(context),
            child: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
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

  String _getRole(String? role) {
    return role == 'staff_serve'
        ? 'Nhân viên phục vụ'
        : role == 'staff_barista'
            ? 'Nhân viên pha chế'
            : 'Không xác định';
  }

  String _getStatus(String status) {
    return {
          'scheduled': 'Đã lên lịch',
          'completed': 'Hoàn thành',
          'absent': 'Vắng mặt',
          'pending': 'Chờ duyệt',
          'paid': 'Đã trả'
        }[status] ??
        'Không xác định';
  }

  String _formatDate(String? date) {
    return date == null
        ? 'Không có dữ liệu'
        : DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  }

  String _formatCurrency(dynamic amount) {
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0; // Chuyển đổi từ String sang double
    }
    final formatCurrency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    return formatCurrency.format(amount);
  }
}
