import 'dart:convert';

class Employee {
  final int employeeId;
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
    required this.employeeId,
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
      employeeId: json['employee_id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      startDate: json['start_date'] ?? '',
    );
  }

  String toJson() {
    return jsonEncode({
      "employee_id": employeeId,
      "name": name,
      "username": username,
      "password": password,
      "role": role,
      "status": status,
      "phone_number": phoneNumber,
      "email": email,
      "address": address,
      "start_date": startDate,
    });
  }
}
