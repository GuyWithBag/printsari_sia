class PaymentMethod {
  final int id;
  final String methodName;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.methodName,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      methodName: json['method_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method_name': methodName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
