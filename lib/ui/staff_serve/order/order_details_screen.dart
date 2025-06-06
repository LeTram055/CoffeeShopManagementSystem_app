import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../managers/staff_serve/order_manager.dart';
import '../../../models/order.dart';
import '../../../models/order_item.dart';
import '../../../models/menu_item.dart';
import '../../../models/table.dart' as table_model;
import 'dart:async';
import 'payment_modal.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<OrderItem> selectedItems = [];
  TextEditingController searchController = TextEditingController();
  int? selectedTableId;
  Timer? _searchFocusTimer;
  FocusNode _searchFocusNode = FocusNode();
  List<FocusNode> _focusNodes = [];
  List<Timer?> _noteFocusTimers = [];
  List<OrderItem> orderItems = [];

  @override
  void initState() {
    super.initState();
    orderItems = List.from(widget.order.items);
    selectedTableId = widget.order.tableId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderServeManager>(context, listen: false).loadCustomers();
      Provider.of<OrderServeManager>(context, listen: false).loadMenu();
      Provider.of<OrderServeManager>(context, listen: false).loadTables();
    });
    _updateFocusNodes();
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

  void showItemSelection(BuildContext context, int orderId) {
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
                  prefixIcon: const Icon(Icons.search),
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
                              orderId: orderId, // Giá trị tạm thời
                              itemId: item.itemId,
                              quantity:
                                  selectedItems[existingIndex].quantity + 1,
                              item: item,
                              status: selectedItems[existingIndex]
                                  .status, // Thêm MenuItem vào OrderItem
                              note: selectedItems[existingIndex].note,
                            );
                          } else {
                            selectedItems.add(OrderItem(
                              orderId: orderId, // Giá trị tạm thời
                              itemId: item.itemId,
                              quantity: 1,
                              item: item,
                              status: "order", // Thêm MenuItem vào OrderItem
                              note: null,
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

  void updateOrder(BuildContext context) async {
    bool hasChanges = false;
    // Kiểm tra nếu bàn được chọn khác với bàn ban đầu
    if (selectedTableId != widget.order.tableId) {
      hasChanges = true; // Đánh dấu có thay đổi
    }

    // Kiểm tra nếu có thay đổi trong số lượng món hoặc ghi chú
    if (selectedItems.length != orderItems.length) {
      hasChanges = true; // Số lượng món thay đổi
    } else {
      for (int i = 0; i < selectedItems.length; i++) {
        OrderItem currentItem = selectedItems[i];
        OrderItem? originalItem = orderItems.firstWhere(
          (item) => item.itemId == currentItem.itemId,
          orElse: () => OrderItem(
            orderId: -1, // Giá trị mặc định
            itemId: -1, // Giá trị mặc định
            quantity: 0,
            item: currentItem.item,
            status: "unknown", // Trạng thái mặc định
          ),
        );

        if (originalItem.orderId == -1 ||
            currentItem.quantity != originalItem.quantity ||
            (currentItem.note != originalItem.note &&
                originalItem.status == "order")) {
          hasChanges = true; // Phát hiện thay đổi trong số lượng hoặc ghi chú
          break;
        }
      }
    }

    // Nếu không có thay đổi, hiển thị thông báo và thoát
    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có thay đổi nào để cập nhật!'),
          backgroundColor: Colors.orange,
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
      orderId: widget.order.orderId,
      tableId: selectedTableId!,
      tableNumber: widget.order.tableNumber,
      customerId: widget.order.customerId,
      orderType: 'dine_in',
      status: 'confirmed',
      totalPrice: totalPrice,
      createdAt: widget.order.createdAt,
      items: selectedItems, // Danh sách OrderItem
    );

    final orderManager = Provider.of<OrderServeManager>(context, listen: false);
    // Lưu đơn hàng vào cơ sở dữ liệu
    try {
      await orderManager.updateOrder(newOrder);

      if (orderManager.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderManager.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        setState(() {
          selectedItems.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                orderManager.successMessage ?? 'Cập nhật đơn hàng thành công!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (error) {
      // Xử lý lỗi khi lưu đơn hàng
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lỗi khi cập nhật đơn hàng!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  void cancelOrder(BuildContext context) async {
    final orderManager = Provider.of<OrderServeManager>(context, listen: false);
    try {
      await orderManager.cancelOrder(widget.order.orderId);
      if (orderManager.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderManager.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(orderManager.successMessage ?? "Hủy đơn hàng thành công!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      // Xử lý lỗi khi lưu đơn hàng
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lỗi khi hủy đơn hàng!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  void completeOrder(BuildContext context) async {
    try {
      await Provider.of<OrderServeManager>(context, listen: false)
          .completeOrder(widget.order.orderId);
      Navigator.pop(context, true);
    } catch (error) {
      // Xử lý lỗi khi lưu đơn hàng
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lỗi khi thanh toán đơn hàng!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedItems = widget.order.items;
    bool isConfirmed = widget.order.status == "confirmed";
    bool isReceived = widget.order.status == "received";
    bool isEditable =
        widget.order.status == "confirmed" || widget.order.status == "received";

    final orderManager = Provider.of<OrderServeManager>(context);
    List<table_model.Table> tables = orderManager.tables;

    List<table_model.Table> availableTables = tables.where((table) {
      return table.tableId == widget.order.tableId || table.statusId == 1;
    }).toList();

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
                      "Bàn ${widget.order.tableNumber}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isEditable) // Chỉ hiển thị dropdown khi đơn hàng đã xác nhận
                    Expanded(
                      // Sử dụng Expanded để cung cấp chiều rộng cho DropdownButtonFormField
                      child: DropdownButtonFormField<int>(
                        value: selectedTableId,
                        items: availableTables.map<DropdownMenuItem<int>>(
                            (table_model.Table table) {
                          return DropdownMenuItem<int>(
                            value:
                                table.tableId, // Sử dụng tableId từ lớp Table
                            child: Text(
                                "Bàn ${table.tableNumber}"), // Sử dụng tableNumber từ lớp Table
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedTableId = newValue; // Cập nhật ID bàn mới
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Chọn bàn mới",
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trạng thái",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    widget.order.status == "confirmed"
                        ? "Đã xác nhận"
                        : widget.order.status == "received"
                            ? "Đã nhận món"
                            : widget.order.status == "pending_payment"
                                ? "Chờ thanh toán"
                                : "Đã thanh toán",
                    style: const TextStyle(
                      fontSize: 16,
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
              Text(
                "${widget.order.customer!.name} - ${widget.order.customer!.phoneNumber}",
                style: const TextStyle(fontSize: 16),
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
                  if (isEditable)
                    ElevatedButton.icon(
                      onPressed: () =>
                          showItemSelection(context, widget.order.orderId),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.item.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              maxLines:
                                                  1, // Giới hạn số dòng hiển thị
                                              overflow: TextOverflow.ellipsis,
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
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (isEditable)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  if (item.quantity >
                                                      (item.completedQuantity ??
                                                          1)) {
                                                    selectedItems[index] =
                                                        OrderItem(
                                                      orderId: item.orderId,
                                                      itemId: item.itemId,
                                                      quantity:
                                                          item.quantity - 1,
                                                      note: item.note,
                                                      item: item.item,
                                                      status: item.status,
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal:
                                                    0), // Căn giữa khi không có nút
                                            child: Text(
                                              "${item.quantity}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          if (isEditable)
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
                                                    status: item.status,
                                                  );
                                                });
                                              },
                                            ),
                                          if (isEditable)
                                            SizedBox(
                                              width:
                                                  30, // Đảm bảo kích thước cố định
                                              child: item.status != "completed"
                                                  ? IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        setState(() {
                                                          selectedItems
                                                              .removeAt(index);
                                                        });
                                                      },
                                                    )
                                                  : null, // Không hiển thị nút xóa nếu món đã hoàn thành
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
                                    readOnly: !isEditable,
                                    onChanged: isEditable
                                        ? null
                                        : (value) {
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

                                            _noteFocusTimers[index] = Timer(
                                                const Duration(seconds: 5), () {
                                              if (mounted &&
                                                  _focusNodes[index].hasFocus) {
                                                _focusNodes[index].unfocus();
                                              }
                                            });
                                          },
                                    onTap: (isEditable)
                                        ? null
                                        : () {
                                            // Nếu nhấn vào ô nhưng chưa nhập gì, đặt timer để mất focus sau 5 giây
                                            if (item.note == null ||
                                                item.note!.isEmpty) {
                                              _noteFocusTimers[index]?.cancel();
                                              _noteFocusTimers[index] = Timer(
                                                  const Duration(seconds: 5),
                                                  () {
                                                if (mounted &&
                                                    _focusNodes[index]
                                                        .hasFocus) {
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
              if (isEditable)
                Text(
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
              const SizedBox(
                height: 60,
              ),
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
              if (isEditable) ...[
                ElevatedButton.icon(
                  onPressed: () => updateOrder(context),
                  icon: const Icon(Icons.update, color: Colors.white),
                  label: const Text("Cập nhật",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
              if (isConfirmed &&
                  !selectedItems.any((item) => item.status == "completed")) ...[
                ElevatedButton.icon(
                  onPressed: () => cancelOrder(context),
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text("Hủy đơn",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
              if (isReceived &&
                  selectedItems
                      .every((item) => item.status == "completed")) ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        return PaymentModal(order: widget.order);
                      },
                    );

                    if (result == true) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, true); // Đóng modal
                      }
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, true); // Đóng màn hình chi tiết
                      }
                    }
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text("Thanh toán",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}
