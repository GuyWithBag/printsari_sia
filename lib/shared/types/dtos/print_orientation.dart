import 'package:printsari_sia/shared/types/types.dart';

class PrintOrientation {
  final int id;
  final String orientationName;
  final DateTime createdAt;

  PrintOrientation({
    required this.id,
    required this.orientationName,
    required this.createdAt,
  });

  PrintOrientationType? get orientationType =>
      PrintOrientationType.fromString(orientationName);

  factory PrintOrientation.fromJson(Map<String, dynamic> json) {
    return PrintOrientation(
      id: json['id'] as int,
      orientationName: json['orientation_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orientation_name': orientationName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
