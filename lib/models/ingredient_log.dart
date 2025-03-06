class IngredientLog {
  final int id;
  final int ingredientId;
  final double quantityChange;
  final String? reason;
  final int employeeId;
  final DateTime changedAt;

  IngredientLog({
    required this.id,
    required this.ingredientId,
    required this.quantityChange,
    this.reason,
    required this.employeeId,
    required this.changedAt,
  });

  factory IngredientLog.fromJson(Map<String, dynamic> json) {
    return IngredientLog(
      id: json['log_id'],
      ingredientId: json['ingredient_id'],
      quantityChange: (json['quantity_change'] as num).toDouble(),
      reason: json['reason'],
      employeeId: json['employee_id'],
      changedAt: DateTime.parse(json['changed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': id,
      'ingredient_id': ingredientId,
      'quantity_change': quantityChange,
      'reason': reason,
      'employee_id': employeeId,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
