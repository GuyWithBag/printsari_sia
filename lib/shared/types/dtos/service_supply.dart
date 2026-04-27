class ServiceSupply {
  final int id;
  final String name;
  final String supplyType;
  final String? paperSize;
  final String? unit;
  final double purchasePrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceSupply({
    required this.id,
    required this.name,
    required this.supplyType,
    this.paperSize,
    this.unit,
    required this.purchasePrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceSupply.fromJson(Map<String, dynamic> json) {
    return ServiceSupply(
      id: json['id'] as int,
      name: json['name'] as String,
      supplyType: json['supply_type'] as String,
      paperSize: json['paper_size'] as String?,
      unit: json['unit'] as String?,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'supply_type': supplyType,
      'paper_size': paperSize,
      'unit': unit,
      'purchase_price': purchasePrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'supply_type': supplyType,
      if (paperSize != null) 'paper_size': paperSize,
      if (unit != null) 'unit': unit,
      'purchase_price': purchasePrice,
    };
  }
}
