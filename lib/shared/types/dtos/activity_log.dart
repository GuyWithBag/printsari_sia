import 'package:printsari_sia/shared/types/types.dart';

class ActivityLog {
  final int id;
  final int actionId;
  final String description;
  final DateTime timestamp;
  final String performedBy;
  final int performedById;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  // Optional joined data
  final ActivityAction? action;
  final Profile? performer;

  ActivityLog({
    required this.id,
    required this.actionId,
    required this.description,
    required this.timestamp,
    required this.performedBy,
    required this.performedById,
    this.metadata,
    required this.createdAt,
    this.action,
    this.performer,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int,
      actionId: json['action_id'] as int,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      performedBy: json['performed_by'] as String,
      performedById: json['performed_by_id'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      action: json['activity_actions'] != null
          ? ActivityAction.fromJson(
              json['activity_actions'] as Map<String, dynamic>,
            )
          : null,
      performer: json['profiles'] != null
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_id': actionId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performed_by': performedBy,
      'performed_by_id': performedById,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'action_id': actionId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performed_by': performedBy,
      'performed_by_id': performedById,
      'metadata': metadata,
    };
  }
}
