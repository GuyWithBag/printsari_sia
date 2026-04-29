import 'package:printsari_sia/shared/types/dtos/print_finish_type.dart';

class PrintFinish {
  final int id;
  final String finishName;
  final DateTime createdAt;

  PrintFinish({
    required this.id,
    required this.finishName,
    required this.createdAt,
  });

  PrintFinishType? get finishType => PrintFinishType.fromString(finishName);

  factory PrintFinish.fromJson(Map<String, dynamic> json) {
    return PrintFinish(
      id: json['id'] as int,
      finishName: json['finish_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'finish_name': finishName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
