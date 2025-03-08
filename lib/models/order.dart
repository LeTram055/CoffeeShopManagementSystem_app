import 'order_item.dart';

class Order {
  final int orderId;
  final int? tableId;
  final int? tableNumber;
  final int? customerId;
  final String orderType; // 'dine_in' hoặc 'takeaway'
  final String
      status; // 'confirmed', 'received', 'pending_payment', 'paid', 'cancelled'
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    this.tableId,
    this.tableNumber,
    this.customerId,
    required this.orderType,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      tableId: json['table_id'],
      tableNumber: json['table_number'],
      customerId: json['customer_id'],
      orderType: json['order_type'],
      status: json['status'],
      totalPrice: (json['total_price'] is num)
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price'].toString()) ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      items: (json['order_items'] as List)
          .map((itemJson) => OrderItem.fromJson(itemJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'table_id': tableId,
      'table_number': tableNumber,
      'customer_id': customerId,
      'order_type': orderType,
      'status': status,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
