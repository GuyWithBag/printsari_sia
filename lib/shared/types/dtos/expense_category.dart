import 'package:printsari_sia/shared/types/types.dart';

class ExpenseCategory {
  final int id;
  final String categoryName;
  final DateTime createdAt;

  ExpenseCategory({
    required this.id,
    required this.categoryName,
    required this.createdAt,
  });

  // Convenience getter to get enum (if it exists)
  ExpenseCategoryType? get categoryType =>
      ExpenseCategoryType.fromString(categoryName);

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
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

  // Helper to create from enum
  static ExpenseCategory fromEnum({
    required int id,
    required ExpenseCategoryType type,
    required DateTime createdAt,
  }) {
    return ExpenseCategory(
      id: id,
      categoryName: type.value,
      createdAt: createdAt,
    );
  }
}
