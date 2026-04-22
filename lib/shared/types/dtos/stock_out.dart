class StockOut {
  final int id;
  final int? transactionId;
  final int? transactionItemId;
  final int? productId;
  final int? serviceSupplyId;
  final int? inventoryItemId;
  final int userId;
  final double quantityRemoved;
  final String stockOutType;
  final DateTime stockOutDate;
  final DateTime createdAt;

  StockOut({
    required this.id,
    this.transactionId,
    this.transactionItemId,
    this.productId,
    this.serviceSupplyId,
    this.inventoryItemId,
    required this.userId,
    required this.quantityRemoved,
    required this.stockOutType,
    required this.stockOutDate,
    required this.createdAt,
  });

  factory StockOut.fromJson(Map<String, dynamic> json) {
    return StockOut(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as int?,
      transactionItemId: json['transaction_item_id'] as int?,
      productId: json['product_id'] as int?,
      serviceSupplyId: json['service_supply_id'] as int?,
      inventoryItemId: json['inventory_item_id'] as int?,
      userId: json['user_id'] as int,
      quantityRemoved: (json['quantity_removed'] as num).toDouble(),
      stockOutType: json['stock_out_type'] as String,
      stockOutDate: DateTime.parse(json['stock_out_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'transaction_item_id': transactionItemId,
      'product_id': productId,
      'service_supply_id': serviceSupplyId,
      'inventory_item_id': inventoryItemId,
      'user_id': userId,
      'quantity_removed': quantityRemoved,
      'stock_out_type': stockOutType,
      'stock_out_date': stockOutDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
