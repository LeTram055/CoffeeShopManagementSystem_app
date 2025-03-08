import 'menu_item.dart';

class OrderItem {
  final int orderId;
  final int itemId;
  final int quantity;
  final String? note;
  final MenuItem item;

  OrderItem({
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.item,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      note: json['note'] as String?,
      item: MenuItem.fromJson(json['item']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'item_id': itemId,
      'quantity': quantity,
      'note': note,
      'item': item.toJson(),
    };
  }
}
