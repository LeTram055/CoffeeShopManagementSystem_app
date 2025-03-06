class Promotion {
  final int promotionId;
  final String name;
  final String discountType; // 'percentage' hoặc 'fixed'
  final double discountValue;
  final double minOrderValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Promotion({
    required this.promotionId,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      promotionId: json['promotion_id'],
      name: json['name'],
      discountType: json['discount_type'],
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderValue: (json['min_order_value'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promotion_id': promotionId,
      'name': name,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_value': minOrderValue,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
}
