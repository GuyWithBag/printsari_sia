import 'package:printsari_sia/shared/types/dtos/paper_size_type.dart';

class PaperSize {
  final int id;
  final String sizeName;
  final DateTime createdAt;

  PaperSize({
    required this.id,
    required this.sizeName,
    required this.createdAt,
  });

  PaperSizeType? get sizeType => PaperSizeType.fromString(sizeName);

  factory PaperSize.fromJson(Map<String, dynamic> json) {
    return PaperSize(
      id: json['id'] as int,
      sizeName: json['size_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
