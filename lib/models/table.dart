class Table {
  final int tableId;
  final int tableNumber;
  final int statusId;
  final int capacity;

  Table({
    required this.tableId,
    required this.tableNumber,
    required this.statusId,
    required this.capacity,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      tableId: json['table_id'],
      tableNumber: json['table_number'],
      statusId: json['status_id'],
      capacity: json['capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_id': tableId,
      'table_number': tableNumber,
      'status_id': statusId,
      'capacity': capacity,
    };
  }
}
