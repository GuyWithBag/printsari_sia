class Service {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {'name': name};
}
