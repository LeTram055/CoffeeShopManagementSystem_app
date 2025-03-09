import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../managers/staff_barista/ingredient_manager.dart';
import '../../../managers/auth_manager.dart';

class IngredientScreen extends StatefulWidget {
  static const routeName = '/ingredients';
  @override
  _IngredientScreenState createState() => _IngredientScreenState();
}

class _IngredientScreenState extends State<IngredientScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IngredientManager>(context, listen: false).loadIngredients();
    });
  }

  void _showUpdateDialog(
      BuildContext context, int ingredientId, double currentQuantity) {
    final TextEditingController quantityController =
        TextEditingController(text: '');
    final TextEditingController reasonController = TextEditingController();
    String adjustmentType = 'increase';

    String? quantityError;
    String? reasonError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text(
                'Cập nhật số lượng',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0049ab)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nhập số lượng
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nhập số lượng',
                        errorText: quantityError,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Chọn Tăng/Giảm
                    Column(
                      children: [
                        ListTile(
                          title: const Text('Tăng'),
                          leading: Radio<String>(
                            value: 'increase',
                            groupValue: adjustmentType,
                            onChanged: (value) {
                              setState(() {
                                adjustmentType = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Giảm'),
                          leading: Radio<String>(
                            value: 'decrease',
                            groupValue: adjustmentType,
                            onChanged: (value) {
                              setState(() {
                                adjustmentType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Nhập lý do
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Lý do điều chỉnh',
                        errorText: reasonError,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      quantityError = null;
                      reasonError = null;
                    });

                    final enteredQuantity =
                        double.tryParse(quantityController.text);
                    if (enteredQuantity == null || enteredQuantity <= 0) {
                      setState(() {
                        quantityError = 'Vui lòng nhập số lượng hợp lệ';
                      });
                      return;
                    }

                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      setState(() {
                        reasonError = 'Vui lòng nhập lý do';
                      });
                      return;
                    }

                    if (adjustmentType == 'decrease' &&
                        enteredQuantity > currentQuantity) {
                      setState(() {
                        quantityError = 'Không thể giảm quá số lượng hiện có';
                      });
                      return;
                    }

                    double finalQuantity = (adjustmentType == 'increase')
                        ? enteredQuantity
                        : -enteredQuantity;

                    final employeeId =
                        Provider.of<AuthManager>(context, listen: false)
                            .currentUser!
                            .employeeId;

                    try {
                      await Provider.of<IngredientManager>(context,
                              listen: false)
                          .updateQuantity(
                              ingredientId, finalQuantity, employeeId, reason);

                      // Hiển thị thông báo cập nhật thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Load lại danh sách nguyên liệu
                      await Provider.of<IngredientManager>(context,
                              listen: false)
                          .loadIngredients();
                      Navigator.of(ctx).pop();
                    } catch (error) {
                      setState(() {
                        quantityError = 'Có lỗi xảy ra: $error';
                      });
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredientManager = Provider.of<IngredientManager>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
              'Nguyên liệu',
              style: TextStyle(fontFamily: 'Prata'),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nguyên liệu...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ingredientManager.searchIngredient(value);
                _searchTimer?.cancel();
                _searchTimer = Timer(const Duration(seconds: 5), () {
                  if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
                });
              },
            ),
          ),
          Expanded(
            child: ingredientManager.isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary))
                : ingredientManager.errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          ingredientManager.errorMessage,
                          style: textTheme.labelMedium!
                              .copyWith(color: colorScheme.secondary),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: ingredientManager.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient =
                                ingredientManager.ingredients[index];
                            bool isLowStock =
                                ingredient.quantity < ingredient.minQuantity;

                            return Card(
                              color: colorScheme.surface,
                              shadowColor: colorScheme.shadow,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ingredient.name,
                                          style:
                                              textTheme.labelMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: colorScheme.primary),
                                          onPressed: () => _showUpdateDialog(
                                              context,
                                              ingredient.ingredientId,
                                              ingredient.quantity),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Số lượng: ${ingredient.quantity} ${ingredient.unit}',
                                          style:
                                              textTheme.labelMedium!.copyWith(
                                            color: isLowStock
                                                ? colorScheme.secondary
                                                : colorScheme.onSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Tối thiểu: ${ingredient.minQuantity} ${ingredient.unit}',
                                          style: textTheme.labelSmall!.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
