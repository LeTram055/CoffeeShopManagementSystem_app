class TableStatus {
  final int statusId;
  final String name;

  TableStatus({
    required this.statusId,
    required this.name,
  });

  factory TableStatus.fromJson(Map<String, dynamic> json) {
    return TableStatus(
      statusId: json['status_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_id': statusId,
      'name': name,
    };
  }
}
