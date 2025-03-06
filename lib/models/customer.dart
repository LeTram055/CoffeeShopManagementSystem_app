class Customer {
  final int id;
  final String name;
  final String? phoneNumber;
  final String? notes;

  Customer({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['customer_id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': id,
      'name': name,
      'phone_number': phoneNumber,
      'notes': notes,
    };
  }
}
