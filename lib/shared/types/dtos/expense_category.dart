class ExpenseCategory {
  final int id;
  final String categoryName;
  final DateTime createdAt;

  ExpenseCategory({
    required this.id,
    required this.categoryName,
    required this.createdAt,
  });

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

}
