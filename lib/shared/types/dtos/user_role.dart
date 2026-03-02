import 'package:printsari_sia/shared/types/types.dart';

class UserRole {
  final int id;
  final String roleName;
  final DateTime createdAt;

  UserRole({required this.id, required this.roleName, required this.createdAt});

  UserRoleType? get roleType => UserRoleType.fromString(roleName);

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as int,
      roleName: json['role_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
