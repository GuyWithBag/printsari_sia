class StockIn {
  final int id;
  final int? productId;
  final int? serviceSupplyId;
  final int userId;
  final int? expenseId;
  final double purchasePrice;
  final double quantityAdded;
  final DateTime? expiryDate;
  final DateTime stockInDate;
  final DateTime createdAt;

  StockIn({
    required this.id,
    this.productId,
    this.serviceSupplyId,
    required this.userId,
    this.expenseId,
    required this.purchasePrice,
    required this.quantityAdded,
    this.expiryDate,
    required this.stockInDate,
    required this.createdAt,
  });

  factory StockIn.fromJson(Map<String, dynamic> json) {
    return StockIn(
      id: json['id'] as int,
      productId: json['product_id'] as int?,
      serviceSupplyId: json['service_supply_id'] as int?,
      userId: json['user_id'] as int,
      expenseId: json['expense_id'] as int?,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      quantityAdded: (json['quantity_added'] as num).toDouble(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      stockInDate: DateTime.parse(json['stock_in_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'service_supply_id': serviceSupplyId,
      'user_id': userId,
      'expense_id': expenseId,
      'purchase_price': purchasePrice,
      'quantity_added': quantityAdded,
      'expiry_date': expiryDate?.toIso8601String().substring(0, 10),
      'stock_in_date': stockInDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
