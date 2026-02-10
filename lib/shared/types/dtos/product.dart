import 'package:printsari_sia/shared/types/types.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final double purchasePrice;
  final String? sku;
  final String? barcode;
  final String? supplier;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ProductCategory? category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.purchasePrice,
    this.sku,
    this.barcode,
    this.supplier,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as int,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      supplier: json['supplier'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['product_categories'] != null
          ? ProductCategory.fromJson(
              json['product_categories'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'sku': sku,
      'barcode': barcode,
      'supplier': supplier,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'sku': sku,
      'barcode': barcode,
      'supplier': supplier,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}
