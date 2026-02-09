import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  PostgrestFilterBuilder<List<Map<String, dynamic>>> getItems() {
    return supabase.from('inventory_items').select();
  }
}
