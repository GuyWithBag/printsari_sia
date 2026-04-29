class ServiceTypeCost {
  final int id;
  final int serviceTypeId;
  final double serviceSupplyCost;
  final double inkCost;
  final double electricityCost;
  final double laborCost;
  final double serviceTotalCost;
  final double serviceSellingPrice;
  final DateTime lastUpdated;

  ServiceTypeCost({
    required this.id,
    required this.serviceTypeId,
    required this.serviceSupplyCost,
    required this.inkCost,
    required this.electricityCost,
    required this.laborCost,
    required this.serviceTotalCost,
    required this.serviceSellingPrice,
    required this.lastUpdated,
  });

  factory ServiceTypeCost.fromJson(Map<String, dynamic> json) {
    return ServiceTypeCost(
      id: json['id'] as int,
      serviceTypeId: json['service_type_id'] as int,
      serviceSupplyCost: (json['service_supply_cost'] as num).toDouble(),
      inkCost: (json['ink_cost'] as num).toDouble(),
      electricityCost: (json['electricity_cost'] as num).toDouble(),
      laborCost: (json['labor_cost'] as num).toDouble(),
      serviceTotalCost: (json['service_total_cost'] as num).toDouble(),
      serviceSellingPrice: (json['service_selling_price'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'service_type_id': serviceTypeId,
        'service_supply_cost': serviceSupplyCost,
        'ink_cost': inkCost,
        'electricity_cost': electricityCost,
        'labor_cost': laborCost,
        'service_selling_price': serviceSellingPrice,
      };

  Map<String, dynamic> toUpdateJson() => {
        'service_supply_cost': serviceSupplyCost,
        'ink_cost': inkCost,
        'electricity_cost': electricityCost,
        'labor_cost': laborCost,
        'service_selling_price': serviceSellingPrice,
        'last_updated': DateTime.now().toIso8601String(),
      };
}
