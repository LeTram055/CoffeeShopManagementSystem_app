class Order {
  final int orderId;
  final int? tableId;
  final int? customerId;
  final String orderType; // 'dine_in' hoặc 'takeaway'
  final String
      status; // 'confirmed', 'received', 'pending_payment', 'paid', 'cancelled'
  final double totalPrice;
  final DateTime createdAt;

  Order({
    required this.orderId,
    this.tableId,
    this.customerId,
    required this.orderType,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      tableId: json['table_id'],
      customerId: json['customer_id'],
      orderType: json['order_type'],
      status: json['status'],
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'table_id': tableId,
      'customer_id': customerId,
      'order_type': orderType,
      'status': status,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
