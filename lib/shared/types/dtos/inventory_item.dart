import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryItem {
  final int id;
  final int productId;
  final double stock;
  final double retailPrice;
  final double? reorderLevel;
  final String? location;
  final DateTime? lastRestocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.stock,
    required this.retailPrice,
    this.reorderLevel,
    this.location,
    this.lastRestocked,
    required this.createdAt,
    required this.updatedAt,
  });

  static Future<Product> getProduct(InventoryItem item) async {
    final supabase = Supabase.instance.client;
    final query = await supabase
        .from('products')
        .select()
        .eq('id', item.productId)
        .single();
    final result = Product.fromJson(query);
    return result;
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      stock: (json['stock'] as num).toDouble(),
      retailPrice: (json['retail_price'] as num).toDouble(),
      reorderLevel: json['reorder_level'] != null
          ? (json['reorder_level'] as num).toDouble()
          : null,
      location: json['location'] as String?,
      lastRestocked: json['last_restocked'] != null
          ? DateTime.parse(json['last_restocked'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'stock': stock,
      'retail_price': retailPrice,
      'reorder_level': reorderLevel,
      'location': location,
      'last_restocked': lastRestocked?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'product_id': productId,
      'stock': stock,
      'retail_price': retailPrice,
      'reorder_level': reorderLevel,
      'location': location,
      'last_restocked': lastRestocked?.toIso8601String(),
    };
  }
}
