import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';

class SocketService {
  late IO.Socket socket;
  bool isConnected = false;
  static final List<OverlaySupportEntry> _notifications =
      []; // Danh sách thông báo

  void showNotification({
    required String message,
    required Color color,
    IconData icon = Icons.info,
    Duration duration = const Duration(seconds: 5),
  }) {
    double baseTopMargin = MediaQueryData.fromView(
                WidgetsBinding.instance.platformDispatcher.views.first)
            .size
            .height *
        0.1;
    double spacing = 80.0; // Khoảng cách giữa các thông báo

    // Tính toán vị trí thông báo dựa vào số lượng thông báo hiện có
    double topMargin = baseTopMargin + (_notifications.length * spacing);

    // Khai báo biến entry trước
    late OverlaySupportEntry entry;

    entry = showOverlayNotification(
      (context) => Card(
        margin: EdgeInsets.only(top: topMargin, left: 20, right: 20),
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading:
              const Icon(Icons.check_circle, color: Colors.white, size: 30),
          title: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                entry.dismiss(); // Đóng thông báo khi bấm nút X
                _notifications.remove(entry); // Xóa khỏi danh sách
              },
            ),
          ),
        ),
      ),
      duration: Duration.zero, // Thông báo không tự mất
    );

    _notifications.add(entry); // Lưu thông báo vào danh sách
  }

  void connect() {
    socket = IO.io('http://192.168.217.199:6001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
    });

    socket.onConnect((_) {
      isConnected = true;
      print('✅ Connected to WebSocket Server');
      socket.emit('subscribe',
          {'channel': 'laravel_database_ordercompleted', 'auth': {}});
      socket.emit(
          'subscribe', {'channel': 'laravel_database_orderissue', 'auth': {}});
    });

    socket.on('order.completed', (data) {
      print('🔥 Dữ liệu nhận từ WebSocket: $data');

      if (data is List && data.length > 1 && data[1] is Map<String, dynamic>) {
        var orderData = data[1];

        if (orderData.containsKey('order')) {
          var order = orderData['order'];
          String tableId = order['table_id'].toString();

          showNotification(
            message: "Đơn hàng bàn $tableId đã hoàn thành!",
            color: Colors.green,
            icon: Icons.check_circle,
          );
        }
      } else {
        print("⚠️ Dữ liệu không đúng định dạng: $data");
      }
    });

    socket.on('order.issue', (data) {
      print('🔥 Dữ liệu nhận từ WebSocket: $data');

      // Kiểm tra xem dữ liệu có phải là danh sách và có ít nhất 2 phần tử không
      if (data is List && data.length > 1 && data[1] is Map<String, dynamic>) {
        var orderData = data[1]; // Lấy phần tử thứ hai của danh sách

        // Trích xuất thông tin từ orderData
        String orderId = orderData['order_id'].toString();
        String itemName = orderData['item_name'].toString();
        String reason = orderData['reason'];
        String orderType = orderData['order_type'].toString();

        // Hiển thị thông báo cho nhân viên phục vụ
        if (orderType == 'dine_in') {
          showNotification(
            message:
                "Đơn hàng #$orderId, Món: $itemName gặp trục trặc: $reason",
            color: Colors.red,
            icon: Icons.warning,
          );
        }
      } else {
        print("⚠️ Dữ liệu không đúng định dạng: $data");
      }
    });

    socket.onConnectError((error) {
      print('❌ Connection Error: $error');
    });

    socket.onDisconnect((_) {
      isConnected = false;
      print('⚠️ Disconnected from WebSocket');
    });

    socket.connect();
  }

  void disconnect() {
    socket.disconnect();
  }
}
