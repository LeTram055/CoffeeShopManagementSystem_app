import 'table_status.dart';

class Table {
  final int tableId;
  final int tableNumber;
  final int statusId;
  final int capacity;
  final TableStatus status;

  Table({
    required this.tableId,
    required this.tableNumber,
    required this.statusId,
    required this.capacity,
    required this.status,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      tableId: json['table_id'],
      tableNumber: json['table_number'],
      statusId: json['status_id'],
      capacity: json['capacity'],
      status: TableStatus.fromJson(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_id': tableId,
      'table_number': tableNumber,
      'status_id': statusId,
      'capacity': capacity,
      'status': status.toJson(),
    };
  }
}
