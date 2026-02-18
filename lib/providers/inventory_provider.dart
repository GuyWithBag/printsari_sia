import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getItems() async {
    return await supabase.from('inventory_items').select();
  }
}
