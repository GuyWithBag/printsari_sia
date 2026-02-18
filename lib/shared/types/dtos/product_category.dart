import 'package:printsari_sia/shared/types/types.dart';

class ProductCategory {
  final int id;
  final String categoryName;
  final DateTime createdAt;

  ProductCategory({
    required this.id,
    required this.categoryName,
    required this.createdAt,
  });

  ProductCategoryType? get categoryType =>
      ProductCategoryType.fromString(categoryName);

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      categoryName: json['category_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
