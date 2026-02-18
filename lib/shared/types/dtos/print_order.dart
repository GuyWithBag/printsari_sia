import 'package:printsari_sia/shared/types/types.dart';

class PrintOrder {
  final int id;
  final int serviceId;
  final int quantity;
  final bool? doubleSided;
  final int? copies;
  final int? additionalFinishId;
  final double totalPrice;
  final double inkUsed;
  final double paperUsed;
  final double electricityUsed;
  final double totalCost;
  final double profitMargin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final PrintService? service;
  final PrintFinish? additionalFinish;

  PrintOrder({
    required this.id,
    required this.serviceId,
    required this.quantity,
    this.doubleSided,
    this.copies,
    this.additionalFinishId,
    required this.totalPrice,
    required this.inkUsed,
    required this.paperUsed,
    required this.electricityUsed,
    required this.totalCost,
    required this.profitMargin,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.additionalFinish,
  });

  factory PrintOrder.fromJson(Map<String, dynamic> json) {
    return PrintOrder(
      id: json['id'] as int,
      serviceId: json['service_id'] as int,
      quantity: json['quantity'] as int,
      doubleSided: json['double_sided'] as bool?,
      copies: json['copies'] as int?,
      additionalFinishId: json['additional_finish_id'] as int?,
      totalPrice: (json['total_price'] as num).toDouble(),
      inkUsed: (json['ink_used'] as num).toDouble(),
      paperUsed: (json['paper_used'] as num).toDouble(),
      electricityUsed: (json['electricity_used'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      profitMargin: (json['profit_margin'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      service: json['print_services'] != null
          ? PrintService.fromJson(
              json['print_services'] as Map<String, dynamic>,
            )
          : null,
      additionalFinish: json['print_finishes'] != null
          ? PrintFinish.fromJson(json['print_finishes'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'quantity': quantity,
      'double_sided': doubleSided,
      'copies': copies,
      'additional_finish_id': additionalFinishId,
      'total_price': totalPrice,
      'ink_used': inkUsed,
      'paper_used': paperUsed,
      'electricity_used': electricityUsed,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'service_id': serviceId,
      'quantity': quantity,
      'double_sided': doubleSided,
      'copies': copies,
      'additional_finish_id': additionalFinishId,
      'total_price': totalPrice,
      'ink_used': inkUsed,
      'paper_used': paperUsed,
      'electricity_used': electricityUsed,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
    };
  }
}
