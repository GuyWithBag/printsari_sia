import 'package:printsari_sia/shared/types/types.dart';

class TransactionItem {
  final int id;
  final int transactionId;
  final int? inventoryId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final int categoryId;
  final double? discount;
  final int? printOrderId;
  final double? itemCost;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final InventoryItem? inventoryItem;
  final Product? product;
  final ProductCategory? category;
  final PrintOrder? printOrder;

  TransactionItem({
    required this.id,
    required this.transactionId,
    this.inventoryId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.categoryId,
    this.discount,
    this.printOrderId,
    this.itemCost,
    required this.createdAt,
    required this.updatedAt,
    this.inventoryItem,
    this.product,
    this.category,
    this.printOrder,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: (json['id'] as int?) ?? 0,
      transactionId: (json['transaction_id'] as int?) ?? 0,
      inventoryId: json['inventory_id'] as int?,
      productId: (json['product_id'] as int?) ?? 0,
      productName: (json['product_name'] as String?) ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      categoryId: (json['category_id'] as int?) ?? 0,
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      printOrderId: json['print_order_id'] as int?,
      itemCost: json['item_cost'] != null
          ? (json['item_cost'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      inventoryItem: json['inventory_items'] != null
          ? InventoryItem.fromJson(
              json['inventory_items'] as Map<String, dynamic>,
            )
          : null,
      product: json['products'] != null
          ? Product.fromJson(json['products'] as Map<String, dynamic>)
          : null,
      category: json['product_categories'] != null
          ? ProductCategory.fromJson(
              json['product_categories'] as Map<String, dynamic>,
            )
          : null,
      printOrder: json['print_orders'] != null
          ? PrintOrder.fromJson(json['print_orders'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'inventory_id': inventoryId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'category_id': categoryId,
      'discount': discount,
      'print_order_id': printOrderId,
      'item_cost': itemCost,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'transaction_id': transactionId,
      'inventory_id': inventoryId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'category_id': categoryId,
      'discount': discount,
      'print_order_id': printOrderId,
      'item_cost': itemCost,
    };
  }
}
