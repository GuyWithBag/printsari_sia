import 'package:printsari_sia/shared/types/types.dart';

class InventoryItem {
  final int id;
  final int? productId;
  final int? serviceSupplyId;
  final double stock;
  final double retailPrice;
  final double? reorderLevel;
  final String? location;
  final DateTime? lastRestocked;
  final DateTime? expiryDate;
  final int? stockInId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ServiceSupply? serviceSupply;
  final Product? product;

  bool get isSupplyItem => serviceSupplyId != null;

  InventoryItem({
    required this.id,
    this.productId,
    this.serviceSupplyId,
    required this.stock,
    required this.retailPrice,
    this.reorderLevel,
    this.location,
    this.lastRestocked,
    this.expiryDate,
    this.stockInId,
    required this.createdAt,
    required this.updatedAt,
    this.serviceSupply,
    this.product,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as int,
      productId: json['product_id'] as int?,
      serviceSupplyId: json['service_supply_id'] as int?,
      stock: (json['stock'] as num).toDouble(),
      retailPrice: (json['retail_price'] as num).toDouble(),
      reorderLevel: json['reorder_level'] != null
          ? (json['reorder_level'] as num).toDouble()
          : null,
      location: json['location'] as String?,
      lastRestocked: json['last_restocked'] != null
          ? DateTime.parse(json['last_restocked'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      stockInId: json['stock_in_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      serviceSupply: json['service_supplies'] != null
          ? ServiceSupply.fromJson(
              json['service_supplies'] as Map<String, dynamic>,
            )
          : null,
      product: json['products'] != null
          ? Product.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'service_supply_id': serviceSupplyId,
      'stock': stock,
      'retail_price': retailPrice,
      'reorder_level': reorderLevel,
      'location': location,
      'last_restocked': lastRestocked?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      if (productId != null) 'product_id': productId,
      if (serviceSupplyId != null) 'service_supply_id': serviceSupplyId,
      'stock': stock,
      'retail_price': retailPrice,
      'reorder_level': reorderLevel,
      'location': location,
      'last_restocked': lastRestocked?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}
