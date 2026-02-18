class Customer {
  final int id;
  final String? name;
  final String email;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime registeredDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    this.name,
    required this.email,
    this.phone,
    this.address,
    this.notes,
    required this.registeredDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      registeredDate: DateTime.parse(json['registered_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'registered_date': registeredDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }
}
