class Vendor {
  final int id;
  final String name;
  final String? contactNumber;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vendor({
    required this.id,
    required this.name,
    this.contactNumber,
    this.email,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      name: json['name'] as String,
      contactNumber: json['contact_number'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    };
  }
}
