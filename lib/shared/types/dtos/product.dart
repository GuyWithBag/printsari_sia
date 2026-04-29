class Product {
  final int id;
  final String name;
  final String productCategory;
  final String productType;
  final double purchasePrice;
  final double? sellingPrice;
  final double? productProfit;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.productCategory,
    required this.productType,
    required this.purchasePrice,
    this.sellingPrice,
    this.productProfit,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      productCategory: (json['product_category'] as String?) ?? '',
      productType: (json['product_type'] as String?) ?? '',
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: json['selling_price'] != null
          ? (json['selling_price'] as num).toDouble()
          : null,
      productProfit: json['product_profit'] != null
          ? (json['product_profit'] as num).toDouble()
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_category': productCategory,
      'product_type': productType,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'product_category': productCategory,
      'product_type': productType,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
    };
  }
}
