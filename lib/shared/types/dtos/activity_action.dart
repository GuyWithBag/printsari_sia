class ActivityAction {
  final int id;
  final String actionName;
  final String category;
  final DateTime createdAt;

  ActivityAction({
    required this.id,
    required this.actionName,
    required this.category,
    required this.createdAt,
  });

  factory ActivityAction.fromJson(Map<String, dynamic> json) {
    return ActivityAction(
      id: json['id'] as int,
      actionName: json['action_name'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_name': actionName,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
