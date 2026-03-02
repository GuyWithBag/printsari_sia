import 'package:printsari_sia/shared/types/types.dart';

class ReportPeriod {
  final int id;
  final String periodName;
  final DateTime createdAt;

  ReportPeriod({
    required this.id,
    required this.periodName,
    required this.createdAt,
  });

  ReportPeriodType? get periodType => ReportPeriodType.fromString(periodName);

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      id: json['id'] as int,
      periodName: json['period_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period_name': periodName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
