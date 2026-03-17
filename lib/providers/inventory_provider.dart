import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:printsari_sia/shared/types/dtos/inventory_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  static const _itemsKey = 'inventory_items';

  List<InventoryItem>? _items;

  Box<String> get _box => Hive.box<String>('app_cache');

  void clearCache() {
    _items = null;
    _box.delete(_itemsKey);
  }

  Future<List<InventoryItem>> getItems() async {
    if (_items != null) return _items!;

    final cached = _box.get(_itemsKey);
    if (cached != null) {
      try {
        final raw = jsonDecode(cached) as List;
        _items = raw.map((r) => InventoryItem.fromJson(r as Map<String, dynamic>)).toList();
        return _items!;
      } catch (e) {
        debugPrint('Inventory cache parse error: $e');
        _box.delete(_itemsKey);
      }
    }

    final query = await supabase.from('inventory_items').select();
    _items = query.map((r) => InventoryItem.fromJson(r)).toList();
    await _box.put(_itemsKey, jsonEncode(query));
    return _items!;
  }
}
