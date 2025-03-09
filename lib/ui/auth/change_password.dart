import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/auth_manager.dart';
import '../../services/auth_service.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final authManager = Provider.of<AuthManager>(context, listen: false);
    final authService = AuthService();

    final response = await authService.changePassword(
      authManager.currentUser!.username,
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (response!['error'] == null) {
      Navigator.pop(context);
      _logout(context);
    } else {
      setState(() {
        // Phân tích lỗi và gán vào từng trường
        if (response['message'].contains('Mật khẩu cũ')) {
          _oldPasswordError = response['message'];
        } else if (response['message'].contains('Mật khẩu mới')) {
          _newPasswordError = response['message'];
        } else if (response['message'].contains('không khớp')) {
          _confirmPasswordError = response['message'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Đổi Mật Khẩu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                      _oldPasswordController, 'Mật khẩu cũ', Icons.lock_outline,
                      obscure: true, errorText: _oldPasswordError),
                  SizedBox(height: 12),
                  _buildTextField(
                      _newPasswordController, 'Mật khẩu mới', Icons.lock,
                      obscure: true, errorText: _newPasswordError),
                  SizedBox(height: 12),
                  _buildTextField(
                    _confirmPasswordController,
                    'Xác nhận mật khẩu mới',
                    Icons.lock_reset,
                    obscure: true,
                    errorText: _confirmPasswordError,
                    validator: (value) => value != _newPasswordController.text
                        ? 'Mật khẩu không khớp'
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy', style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Đổi mật khẩu',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorText: errorText, // Hiển thị lỗi dưới ô nhập
      ),
      obscureText: obscure,
      validator: validator ??
          (value) => value!.isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }
}

Future<void> _logout(BuildContext context) async {
  Provider.of<AuthManager>(context, listen: false).logout();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Đổi mật khẩu thành công!'),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    ),
  );
}
