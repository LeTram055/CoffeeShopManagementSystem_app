import 'package:coffeeshop/models/order.dart';

class Payment {
  final int paymentId;
  final int orderId;
  final int employeeId;
  final int? promotionId;
  final double discountAmount;
  final double finalPrice;
  final String paymentMethod;
  final double amountReceived;
  final DateTime paymentTime;
  final Order? order;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.employeeId,
    this.promotionId,
    required this.discountAmount,
    required this.finalPrice,
    required this.paymentMethod,
    required this.amountReceived,
    required this.paymentTime,
    this.order,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      orderId: json['order_id'],
      employeeId: json['employee_id'],
      promotionId: json['promotion_id'],
      discountAmount: (json['discount_amount'] is num)
          ? (json['discount_amount'] as num).toDouble()
          : double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      finalPrice: (json['final_price'] is num)
          ? (json['final_price'] as num).toDouble()
          : double.tryParse(json['final_price'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'],
      amountReceived: (json['amount_received'] is num)
          ? (json['amount_received'] as num).toDouble()
          : double.tryParse(json['amount_received'].toString()) ?? 0.0,
      paymentTime: DateTime.parse(json['payment_time']),
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'employee_id': employeeId,
      'promotion_id': promotionId,
      'discount_amount': discountAmount,
      'final_price': finalPrice,
      'payment_method': paymentMethod,
      'amount_received': amountReceived,
      'payment_time': paymentTime.toIso8601String(),
      'order': order!.toJson(),
    };
  }
}
