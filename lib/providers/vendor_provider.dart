import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/vendor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Vendor>? _vendors;

  void clearCache() => _vendors = null;

  Future<List<Vendor>> getVendors() async {
    if (_vendors != null) return _vendors!;
    final data = await supabase
        .from('vendors')
        .select()
        .order('name');
    _vendors = (data as List).map((r) => Vendor.fromJson(r as Map<String, dynamic>)).toList();
    return _vendors!;
  }

  Future<Vendor> createVendor(Vendor vendor) async {
    final inserted = await supabase
        .from('vendors')
        .insert(vendor.toInsertJson())
        .select()
        .single();
    final newVendor = Vendor.fromJson(inserted);
    _vendors ??= [];
    _vendors!.add(newVendor);
    _vendors!.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    return newVendor;
  }

  Future<Vendor> updateVendor(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('vendors')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    final updatedVendor = Vendor.fromJson(updated);
    if (_vendors != null) {
      final idx = _vendors!.indexWhere((v) => v.id == id);
      if (idx != -1) _vendors![idx] = updatedVendor;
    }
    notifyListeners();
    return updatedVendor;
  }

  Future<void> deleteVendor(int id) async {
    await supabase.from('vendors').delete().eq('id', id);
    _vendors?.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}
