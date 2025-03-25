import 'package:coffeeshop/ui/staff_serve/order/table_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../models/customer.dart';
import '../../../models/table.dart' as table_model;
import '../../../models/menu_item.dart';
import '../../../models/order_item.dart';
import '../../../models/order.dart';
import '../../../managers/staff_serve/order_manager.dart';
import 'dart:async';

class OrderServeScreen extends StatefulWidget {
  final table_model.Table table;

  OrderServeScreen({required this.table});

  @override
  _OrderServeScreenState createState() => _OrderServeScreenState();
}

class _OrderServeScreenState extends State<OrderServeScreen> {
  Customer? selectedCustomer;
  List<OrderItem> selectedItems = [];
  TextEditingController searchController = TextEditingController();

  Timer? _searchFocusTimer;
  FocusNode _searchFocusNode = FocusNode();
  List<FocusNode> _focusNodes = [];
  List<Timer?> _noteFocusTimers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderServeManager>(context, listen: false).loadCustomers();
      Provider.of<OrderServeManager>(context, listen: false).loadMenu();
    });
    _updateFocusNodes();
    // _focusNodes = List.generate(selectedItems.length, (index) => FocusNode());
  }

  void dispose() {
    _searchFocusTimer?.cancel();
    searchController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var timer in _noteFocusTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _updateFocusNodes() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var timer in _noteFocusTimers) {
      timer?.cancel();
    }
    _focusNodes = List.generate(selectedItems.length, (index) => FocusNode());
    _noteFocusTimers = List.generate(selectedItems.length, (index) => null);
  }

  void addNewCustomer(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    String? nameError;
    String? phoneError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Thêm khách hàng mới",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0049ab)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Tên khách hàng",
                        border: const OutlineInputBorder(),
                        errorText: nameError,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        border: const OutlineInputBorder(),
                        errorText: phoneError,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String phone = phoneController.text.trim();

                    setState(() {
                      nameError =
                          name.isEmpty ? "Tên không được để trống" : null;
                      if (phone.isEmpty) {
                        phoneError = "Số điện thoại không được để trống";
                      } else if (!RegExp(r'^\d{10,}$').hasMatch(phone)) {
                        phoneError =
                            "Số điện thoại không hợp lệ (ít nhất 10 số)";
                      } else {
                        phoneError = null;
                      }
                    });

                    if (nameError == null && phoneError == null) {
                      String? errorMessage =
                          await Provider.of<OrderServeManager>(context,
                                  listen: false)
                              .addCustomer(name, phone);

                      if (errorMessage != null) {
                        setState(() => phoneError = errorMessage);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Thêm khách hàng thành công!"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Thêm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showItemSelection(BuildContext context) {
    final orderManager = Provider.of<OrderServeManager>(context, listen: false);
    List<MenuItem> menuItems = orderManager.menuItems;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn món",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm món...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {});
                  _searchFocusTimer?.cancel();
                  _searchFocusTimer = Timer(const Duration(seconds: 5), () {
                    if (mounted && _searchFocusNode.hasFocus) {
                      _searchFocusNode
                          .unfocus(); // Mất focus sau 5 giây không nhập
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: menuItems
                      .where((item) => item.name
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()))
                      .length,
                  itemBuilder: (context, index) {
                    List<MenuItem> filteredItems = menuItems
                        .where((item) => item.name
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()))
                        .toList();

                    MenuItem item = filteredItems[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Kiểm tra nếu sản phẩm đã có trong danh sách thì tăng số lượng
                          int existingIndex = selectedItems.indexWhere(
                              (order) => order.itemId == item.itemId);
                          if (existingIndex != -1) {
                            selectedItems[existingIndex] = OrderItem(
                              orderId: 0, // Giá trị tạm thời
                              itemId: item.itemId,
                              quantity:
                                  selectedItems[existingIndex].quantity + 1,
                              item: item, // Thêm MenuItem vào OrderItem
                            );
                          } else {
                            selectedItems.add(OrderItem(
                              orderId: 0, // Giá trị tạm thời
                              itemId: item.itemId,
                              quantity: 1,
                              item: item, // Thêm MenuItem vào OrderItem
                            ));
                          }
                        });
                        searchController.clear();
                        Navigator.pop(context);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("${item.price}đ",
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void placeOrder(BuildContext context) async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khách hàng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một món!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tính tổng giá trị của đơn hàng
    double totalPrice = 0.0;
    selectedItems.forEach((item) {
      totalPrice += item.item.price * item.quantity;
    });

    // Tạo đối tượng Order
    Order newOrder = Order(
      orderId: DateTime.now().millisecondsSinceEpoch,
      tableId: widget.table.tableId,
      tableNumber: widget.table.tableNumber,
      customerId: selectedCustomer?.customerId,
      orderType: 'dine_in',
      status: 'confirmed',
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
      items: selectedItems, // Danh sách OrderItem
    );

    // Lưu đơn hàng vào cơ sở dữ liệu
    try {
      await Provider.of<OrderServeManager>(context, listen: false)
          .createOrder(newOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lập đơn thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedItems.clear();
        selectedCustomer = null;
      });

      // Quay về màn hình trước đó
      // Navigator.pop(context, true);
      Navigator.pushNamed(context, TableScreen.routeName);
    } catch (error) {
      // Xử lý lỗi khi lưu đơn hàng
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lỗi khi lập đơn hàng!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerManager = Provider.of<OrderServeManager>(context);
    List<Customer> customers = customerManager.customers;

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
              'Đặt hàng',
              style: TextStyle(fontFamily: 'Prata'),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Bàn ${widget.table.tableNumber}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                  ),
                ],
              ),
              Text(
                "Khách hàng",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<Customer>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Tìm kiếm khách hàng",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      items: customers,
                      itemAsString: (Customer customer) =>
                          "${customer.name} - ${customer.phoneNumber}",
                      onChanged: (Customer? customer) {
                        setState(() {
                          selectedCustomer = customer;
                        });
                      },
                      selectedItem: selectedCustomer,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Chọn khách hàng",
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => addNewCustomer(context),
                    child: Icon(Icons.add, size: 24),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      iconColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Món",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showItemSelection(context),
                    label: const Text("Chọn món",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (selectedItems.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      OrderItem item = selectedItems[index];
                      if (_focusNodes.length <= index) {
                        _focusNodes.add(FocusNode());
                      }
                      if (_noteFocusTimers.length <= index) {
                        _noteFocusTimers.add(null);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.item.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Cột bên phải (chứa thông tin + ghi chú)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${NumberFormat("#,###", "vi_VN").format(item.item.price)}đ",
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                if (item.quantity > 1) {
                                                  selectedItems[index] =
                                                      OrderItem(
                                                    orderId: item.orderId,
                                                    itemId: item.itemId,
                                                    quantity: item.quantity - 1,
                                                    note: item.note,
                                                    item: item.item,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                            "${item.quantity}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle,
                                                color: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                selectedItems[index] =
                                                    OrderItem(
                                                  orderId: item.orderId,
                                                  itemId: item.itemId,
                                                  quantity: item.quantity + 1,
                                                  note: item.note,
                                                  item: item.item,
                                                );
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                selectedItems.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Ghi chú
                                  TextFormField(
                                    focusNode: index < _focusNodes.length
                                        ? _focusNodes[index]
                                        : FocusNode(),
                                    initialValue: item.note,
                                    decoration: const InputDecoration(
                                      hintText: "Ghi chú...",
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                    ),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[800]),
                                    onChanged: (value) {
                                      _noteFocusTimers[index]?.cancel();
                                      setState(() {
                                        selectedItems[index] = OrderItem(
                                          orderId: item.orderId,
                                          itemId: item.itemId,
                                          quantity: item.quantity,
                                          note: value,
                                          item: item.item,
                                        );
                                      });

                                      _noteFocusTimers[index] =
                                          Timer(const Duration(seconds: 5), () {
                                        if (mounted &&
                                            _focusNodes[index].hasFocus) {
                                          _focusNodes[index].unfocus();
                                        }
                                      });
                                    },
                                    onTap: () {
                                      // Nếu nhấn vào ô nhưng chưa nhập gì, đặt timer để mất focus sau 5 giây
                                      if (item.note == null ||
                                          item.note!.isEmpty) {
                                        _noteFocusTimers[index]?.cancel();
                                        _noteFocusTimers[index] = Timer(
                                            const Duration(seconds: 5), () {
                                          if (mounted &&
                                              _focusNodes[index].hasFocus) {
                                            _focusNodes[index].unfocus();
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(
                height: 60,
              )
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tổng tiền với border
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Text(
                  "Tổng: ${NumberFormat("#,###", "vi_VN").format(
                    selectedItems.fold<double>(0.0,
                        (sum, item) => sum + (item.quantity * item.item.price)),
                  )}đ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),

              // Nút "Lập đơn"
              ElevatedButton.icon(
                onPressed: () => placeOrder(context),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Lập đơn",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
