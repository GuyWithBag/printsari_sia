class Machine {
  final int id;
  final int? serviceId;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Machine({
    required this.id,
    this.serviceId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'] as int,
      serviceId: json['service_id'] as int?,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      if (serviceId != null) 'service_id': serviceId,
      'name': name,
      'is_active': isActive,
    };
  }
}
