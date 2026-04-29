import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/inventory_item.dart';
import 'package:printsari_sia/shared/types/dtos/service_supply.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<InventoryItem>? _items;
  List<ServiceSupply>? _serviceSupplies;
  bool _hasPendingChanges = false;
  RealtimeChannel? _channel;

  bool get hasPendingChanges => _hasPendingChanges;

  void subscribeToChanges() {
    _channel?.unsubscribe();
    _channel = supabase
        .channel('inventory_items_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventory_items',
          callback: (_) {
            _hasPendingChanges = true;
            notifyListeners();
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void clearCache() {
    _items = null;
    _serviceSupplies = null;
  }

  Future<InventoryItem> stockIn({
    required int productId,
    required double quantity,
    required double purchasePrice,
    DateTime? expiryDate,
  }) async {
    final now = DateTime.now();

    // 1. Get current user's profile id
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');
    final profileQuery = await supabase
        .from('profiles')
        .select('id')
        .eq('user_id', currentUser.id)
        .single();
    final profileId = profileQuery['id'] as int;

    // 2. Insert into stock_in table and get its id
    final stockInRecord = await supabase
        .from('stock_in')
        .insert({
          'product_id': productId,
          'user_id': profileId,
          'purchase_price': purchasePrice,
          'quantity_added': quantity,
          if (expiryDate != null)
            'expiry_date': expiryDate.toIso8601String().substring(0, 10),
          'stock_in_date': now.toIso8601String(),
        })
        .select()
        .single();
    final stockInId = stockInRecord['id'] as int;

    // 3. Check if an inventory_items row already exists for this product + expiry date
    final expiryStr = expiryDate?.toIso8601String().substring(0, 10);
    var query = supabase
        .from('inventory_items')
        .select()
        .eq('product_id', productId);
    if (expiryStr != null) {
      query = query.eq('expiry_date', expiryStr);
    } else {
      query = query.isFilter('expiry_date', null);
    }
    final existing = await query.maybeSingle();

    InventoryItem newItem;
    if (existing != null) {
      // 4. Update: add stock, refresh purchase price and stock_in_id
      final existingId = existing['id'] as int;
      final currentStock = (existing['stock'] as num).toDouble();
      final updated = await supabase
          .from('inventory_items')
          .update({
            'stock': currentStock + quantity,
            'purchase_price': purchasePrice,
            'last_restocked': now.toIso8601String(),
            'stock_in_id': stockInId,
          })
          .eq('id', existingId)
          .select()
          .single();
      newItem = InventoryItem.fromJson(updated);

      // Update local cache
      _items = _items
          ?.map((i) => i.id == existingId ? newItem : i)
          .toList();
    } else {
      // 5. Insert new inventory row
      final inserted = await supabase
          .from('inventory_items')
          .insert({
            'product_id': productId,
            'stock': quantity,
            'purchase_price': purchasePrice,
            'last_restocked': now.toIso8601String(),
            'stock_in_id': stockInId,
            if (expiryDate != null)
              'expiry_date': expiryStr,
          })
          .select()
          .single();
      newItem = InventoryItem.fromJson(inserted);
      _items ??= [];
      _items!.add(newItem);
    }

    notifyListeners();
    return newItem;
  }

  Future<List<Map<String, dynamic>>> getStockHistory() async {
    final rows = await supabase
        .from('stock_in')
        .select('*, products(name), profiles(name, username)')
        .order('stock_in_date', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> recordStockOut({
    required int userId,
    required double quantityRemoved,
    int? transactionId,
    int? transactionItemId,
    int? productId,
    int? serviceSupplyId,
    int? inventoryItemId,
    String stockOutType = 'sale',
  }) async {
    await supabase.from('stock_out').insert({
      'user_id': userId,
      'quantity_removed': quantityRemoved,
      if (transactionId != null) 'transaction_id': transactionId,
      if (transactionItemId != null) 'transaction_item_id': transactionItemId,
      if (productId != null) 'product_id': productId,
      if (serviceSupplyId != null) 'service_supply_id': serviceSupplyId,
      if (inventoryItemId != null) 'inventory_item_id': inventoryItemId,
      'stock_out_type': stockOutType,
      'stock_out_date': DateTime.now().toIso8601String(),
    });
  }

  /// Manual stock-out: deducts stock, records in stock_out, creates a purchases expense.
  Future<void> stockOut({
    required InventoryItem item,
    required double quantity,
    String? notes,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    if (quantity <= 0) throw Exception('Quantity must be greater than 0');
    if (quantity > item.stock) throw Exception('Cannot remove more than current stock');

    // Get user profile id
    final profileRow = await supabase
        .from('profiles')
        .select('id')
        .eq('user_id', userId)
        .single();
    final profileId = profileRow['id'] as int;

    // Deduct from inventory_items
    await supabase
        .from('inventory_items')
        .update({'stock': item.stock - quantity})
        .eq('id', item.id);

    // Record in stock_out
    await supabase.from('stock_out').insert({
      'user_id': profileId,
      if (item.productId != null) 'product_id': item.productId,
      if (item.serviceSupplyId != null) 'service_supply_id': item.serviceSupplyId,
      'inventory_item_id': item.id,
      'quantity_removed': quantity,
      'stock_out_type': 'manual',
      'stock_out_date': DateTime.now().toIso8601String(),
      if (notes != null) 'notes': notes,
    });

    // Auto-create expense in 'purchases' category
    final categoryRow = await supabase
        .from('expense_categories')
        .select('id')
        .eq('category_name', 'purchases')
        .maybeSingle();
    if (categoryRow != null) {
      final categoryId = categoryRow['id'] as int;
      final amount = item.purchasePrice * quantity;
      final desc = notes?.isNotEmpty == true ? notes! : 'Manual stock-out adjustment';
      await supabase.from('expenses').insert({
        'description': desc,
        'amount': amount,
        'category_id': categoryId,
        'date': DateTime.now().toIso8601String(),
        'source_id': 1,
      });
    }

    clearCache();
    notifyListeners();
  }

  /// Stocks out remaining quantity (if any), then deletes the inventory record.
  Future<void> deleteItem(InventoryItem item) async {
    if (item.stock > 0) {
      await stockOut(
        item: item,
        quantity: item.stock,
        notes: 'Removed from inventory',
      );
    }
    await supabase.from('inventory_items').delete().eq('id', item.id);
    _items?.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  Future<List<InventoryItem>> getItems() async {
    if (_items != null) return _items!;

    final query = await supabase
        .from('inventory_items')
        .select('*, service_supplies(*), products(*)');
    _items = query.map((r) => InventoryItem.fromJson(r)).toList();
    _hasPendingChanges = false;
    return _items!;
  }

  Future<List<ServiceSupply>> getServiceSupplies() async {
    if (_serviceSupplies != null) return _serviceSupplies!;

    final query = await supabase
        .from('service_supplies')
        .select()
        .order('name');
    _serviceSupplies = query.map((r) => ServiceSupply.fromJson(r)).toList();
    return _serviceSupplies!;
  }

  Future<ServiceSupply> createServiceSupply(ServiceSupply supply) async {
    final inserted = await supabase
        .from('service_supplies')
        .insert(supply.toInsertJson())
        .select()
        .single();
    final newSupply = ServiceSupply.fromJson(inserted);
    _serviceSupplies ??= [];
    _serviceSupplies!.add(newSupply);
    notifyListeners();
    return newSupply;
  }

  Future<ServiceSupply> updateServiceSupply(
    int id,
    Map<String, dynamic> updates,
  ) async {
    final updated = await supabase
        .from('service_supplies')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    final updatedSupply = ServiceSupply.fromJson(updated);
    if (_serviceSupplies != null) {
      final idx = _serviceSupplies!.indexWhere((s) => s.id == id);
      if (idx != -1) _serviceSupplies![idx] = updatedSupply;
    }
    notifyListeners();
    return updatedSupply;
  }

  Future<void> deleteServiceSupply(int id) async {
    await supabase.from('service_supplies').delete().eq('id', id);
    _serviceSupplies?.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<InventoryItem> stockInSupply({
    required int serviceSupplyId,
    required double quantity,
    required double purchasePrice,
  }) async {
    final now = DateTime.now();

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');
    final profileQuery = await supabase
        .from('profiles')
        .select('id')
        .eq('user_id', currentUser.id)
        .single();
    final profileId = profileQuery['id'] as int;

    // Insert stock_in record
    final stockInRecord = await supabase.from('stock_in').insert({
      'service_supply_id': serviceSupplyId,
      'user_id': profileId,
      'purchase_price': purchasePrice,
      'quantity_added': quantity,
      'stock_in_date': now.toIso8601String(),
    }).select().single();
    final stockInId = stockInRecord['id'] as int;

    // Check if inventory row already exists for this supply
    final existing = await supabase
        .from('inventory_items')
        .select('*, service_supplies(*)')
        .eq('service_supply_id', serviceSupplyId)
        .maybeSingle();

    InventoryItem newItem;
    if (existing != null) {
      final currentStock = (existing['stock'] as num).toDouble();
      final updated = await supabase
          .from('inventory_items')
          .update({
            'stock': currentStock + quantity,
            'purchase_price': purchasePrice,
            'last_restocked': now.toIso8601String(),
            'stock_in_id': stockInId,
          })
          .eq('service_supply_id', serviceSupplyId)
          .select('*, service_supplies(*)')
          .single();
      newItem = InventoryItem.fromJson(updated);
      _items = _items
          ?.map((i) => i.serviceSupplyId == serviceSupplyId ? newItem : i)
          .toList();
    } else {
      final inserted = await supabase
          .from('inventory_items')
          .insert({
            'service_supply_id': serviceSupplyId,
            'stock': quantity,
            'purchase_price': purchasePrice,
            'last_restocked': now.toIso8601String(),
            'stock_in_id': stockInId,
          })
          .select('*, service_supplies(*)')
          .single();
      newItem = InventoryItem.fromJson(inserted);
      _items ??= [];
      _items!.add(newItem);
    }

    notifyListeners();
    return newItem;
  }
}
