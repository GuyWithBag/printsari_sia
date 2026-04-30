import 'package:printsari_sia/shared/types/dtos/service_type.dart';

class PrintOrder {
  final int id;
  final int? serviceTypeId;
  final int quantity;
  final double totalPrice;
  final double totalCost;
  final double profitMargin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ServiceType? serviceType;

  PrintOrder({
    required this.id,
    this.serviceTypeId,
    required this.quantity,
    required this.totalPrice,
    required this.totalCost,
    required this.profitMargin,
    required this.createdAt,
    required this.updatedAt,
    this.serviceType,
  });

  factory PrintOrder.fromJson(Map<String, dynamic> json) {
    return PrintOrder(
      id: json['id'] as int,
      serviceTypeId: json['service_type_id'] as int?,
      quantity: json['quantity'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      profitMargin: (json['profit_margin'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      serviceType: json['service_types'] != null
          ? ServiceType.fromJson(
              json['service_types'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type_id': serviceTypeId,
      'quantity': quantity,
      'total_price': totalPrice,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      if (serviceTypeId != null) 'service_type_id': serviceTypeId,
      'quantity': quantity,
      'total_price': totalPrice,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
    };
  }
}
