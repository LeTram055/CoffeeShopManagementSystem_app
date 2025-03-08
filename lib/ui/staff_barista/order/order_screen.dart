import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../managers/staff_barista/order_manager.dart';
import '../../../models/order.dart';
import '../../../models/order_item.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<OrderManager>(context, listen: false).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final orderManager = Provider.of<OrderManager>(context);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                'Đơn hàng',
                style: TextStyle(fontFamily: 'Prata'),
              ),
            ],
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.surfaceTint,
            indicatorColor: theme.colorScheme.secondary,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Chờ nhận món'),
              Tab(text: 'Tất cả đơn'),
            ],
          ),
        ),
        body: orderManager.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TabBarView(
                  children: [
                    _buildOrderList(
                      orderManager.orders
                          .where((order) => (order.status == 'confirmed'))
                          .toList(),
                      theme,
                    ),
                    _buildOrderList(orderManager.orders, theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, ThemeData theme) {
    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào.'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          color: theme.colorScheme.surface,
          shadowColor: theme.colorScheme.shadow,
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loại đơn: ${order.orderType == 'dine_in' ? 'Tại chỗ' : 'Mang đi'}',
                  style: theme.textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (order.orderType == 'dine_in')
                  Text(
                    'Bàn: ${order.tableNumber ?? ''}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Thời gian: ${DateFormat('HH:mm:ss dd/MM/yyyy').format(order.createdAt)}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Món: ${order.items.length} món',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            trailing:
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
            onTap: () {
              _showOrderDetailsDialog(context, order);
            },
          ),
        );
      },
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Chi tiết đơn hàng',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loại đơn: ${order.orderType == 'dine_in' ? 'Tại chỗ' : 'Mang đi'}',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (order.orderType == 'dine_in')
                      Text(
                        'Bàn: ${order.tableNumber ?? 'Chưa có'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                Text('Trạng thái: ${_getStatus(order.status)}',
                    style: theme.textTheme.bodyMedium),
                Text(
                    'Thời gian: ${DateFormat('HH:mm:ss dd/MM/yyyy').format(order.createdAt)}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text('Danh sách món:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 10),
                ...order.items.map((item) => _buildOrderItemTile(item, theme)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Đóng
                    TextButton(
                      child: Text('Đóng',
                          style: TextStyle(color: theme.colorScheme.primary)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    // Nếu trạng thái là "Chờ thanh toán" thì hiển thị nút "Hoàn thành"
                    if ((order.status == 'confirmed'))
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        onPressed: () => _completeOrder(context, order),
                        child: Text('Hoàn thành',
                            style:
                                TextStyle(color: theme.colorScheme.onPrimary)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Gửi request cập nhật trạng thái đơn hàng và giảm nguyên liệu
  void _completeOrder(BuildContext context, Order order) async {
    try {
      final orderManager = Provider.of<OrderManager>(context, listen: false);
      await orderManager.completeOrder(order.orderId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hoàn thành đơn hàng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không thể cập nhật đơn hàng'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOrderItemTile(OrderItem item, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      shadowColor: theme.colorScheme.shadow,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 90,
            height: 80,
            child: item.item.imageUrl.startsWith('http')
                ? Image.network(item.item.imageUrl,
                    width: 90, height: 80, fit: BoxFit.cover)
                : Icon(Icons.image_not_supported,
                    color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        title: Text(item.item.name,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lượng: ${item.quantity}',
                style: theme.textTheme.bodyMedium),
            Text('Ghi chú: ${item.note ?? ''}',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _getStatus(String status) {
    switch (status) {
      case 'confirmed':
        return 'Chờ nhận món';
      case 'received':
        return 'Đã nhận món';
      case 'pending_payment':
        return 'Chờ thanh toán';
      case 'cancelled':
        return 'Đã hủy';
      case 'paid':
        return 'Đã thanh toán';
      default:
        return 'Không xác định';
    }
  }
}
