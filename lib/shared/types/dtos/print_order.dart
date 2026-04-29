import 'package:printsari_sia/shared/types/dtos/service_supply.dart';

class PrintOrder {
  final int id;
  final int? serviceSupplyId;
  final int quantity;
  final double totalPrice;
  final double totalCost;
  final double profitMargin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ServiceSupply? serviceSupply;

  PrintOrder({
    required this.id,
    this.serviceSupplyId,
    required this.quantity,
    required this.totalPrice,
    required this.totalCost,
    required this.profitMargin,
    required this.createdAt,
    required this.updatedAt,
    this.serviceSupply,
  });

  factory PrintOrder.fromJson(Map<String, dynamic> json) {
    return PrintOrder(
      id: json['id'] as int,
      serviceSupplyId: json['service_supply_id'] as int?,
      quantity: json['quantity'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      profitMargin: (json['profit_margin'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      serviceSupply: json['service_supplies'] != null
          ? ServiceSupply.fromJson(
              json['service_supplies'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_supply_id': serviceSupplyId,
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
      if (serviceSupplyId != null) 'service_supply_id': serviceSupplyId,
      'quantity': quantity,
      'total_price': totalPrice,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
    };
  }
}
