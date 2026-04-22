class LoginHistory {
  final int id;
  final int profileId;
  final String username;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final DateTime createdAt;

  LoginHistory({
    required this.id,
    required this.profileId,
    required this.username,
    required this.loginTime,
    this.logoutTime,
    required this.createdAt,
  });

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      id: json['id'] as int,
      profileId: json['profile_id'] as int,
      username: json['username'] as String,
      loginTime: DateTime.parse(json['login_time'] as String),
      logoutTime: json['logout_time'] != null
          ? DateTime.parse(json['logout_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'username': username,
      'login_time': loginTime.toIso8601String(),
      'logout_time': logoutTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
