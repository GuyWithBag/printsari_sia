import 'package:printsari_sia/shared/types/types.dart';

class ExpenseSource {
  final int id;
  final String sourceName;
  final DateTime createdAt;

  ExpenseSource({
    required this.id,
    required this.sourceName,
    required this.createdAt,
  });

  ExpenseSourceType? get sourceType => ExpenseSourceType.fromString(sourceName);

  factory ExpenseSource.fromJson(Map<String, dynamic> json) {
    return ExpenseSource(
      id: json['id'] as int,
      sourceName: json['source_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_name': sourceName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
