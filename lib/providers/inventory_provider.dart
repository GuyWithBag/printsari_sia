import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/inventory_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<List<InventoryItem>> getItems() async {
    final query = await supabase.from('inventory_items').select();
    final result = List.generate(
      query.length,
      (i) => InventoryItem.fromJson(query[i]),
    );
    print(result.toString());
    return result;
  }
}
