class Employee {
  final int id;
  final String name;
  final String username;
  final String password;
  final String role;
  final String status;
  final String phoneNumber;
  final String email;
  final String? address;
  final String startDate;

  Employee({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    required this.status,
    required this.phoneNumber,
    required this.email,
    this.address,
    required this.startDate,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['employee_id'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
      status: json['status'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      startDate: json['start_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'status': status,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'start_date': startDate,
    };
  }
}
