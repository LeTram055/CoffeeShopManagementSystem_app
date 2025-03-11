class Customer {
  final int customerId;
  final String name;
  final String? phoneNumber;
  final String? notes;

  Customer({
    required this.customerId,
    required this.name,
    this.phoneNumber,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'phone_number': phoneNumber,
      'notes': notes,
    };
  }
}
