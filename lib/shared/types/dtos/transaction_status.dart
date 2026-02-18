import 'package:printsari_sia/shared/types/types.dart';

class TransactionStatus {
  final int id;
  final String statusName;
  final DateTime createdAt;

  TransactionStatus({
    required this.id,
    required this.statusName,
    required this.createdAt,
  });

  TransactionStatusType? get statusType =>
      TransactionStatusType.fromString(statusName);

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      id: json['id'] as int,
      statusName: json['status_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_name': statusName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
