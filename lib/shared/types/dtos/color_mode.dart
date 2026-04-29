import 'package:printsari_sia/shared/types/dtos/color_mode_type.dart';

class ColorMode {
  final int id;
  final String modeName;
  final DateTime createdAt;

  ColorMode({
    required this.id,
    required this.modeName,
    required this.createdAt,
  });

  ColorModeType? get modeType => ColorModeType.fromString(modeName);

  factory ColorMode.fromJson(Map<String, dynamic> json) {
    return ColorMode(
      id: json['id'] as int,
      modeName: json['mode_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode_name': modeName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
