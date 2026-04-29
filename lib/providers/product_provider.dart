import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/service_supply.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Product>? _products;
  List<Machine>? _machines;
  List<ServiceSupply>? _serviceSupplies;
  bool _hasPendingChanges = false;
  RealtimeChannel? _channel;

  bool get hasPendingChanges => _hasPendingChanges;

  void subscribeToChanges() {
    _channel?.unsubscribe();
    _channel = supabase
        .channel('products_services_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
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

  void clearProductsCache() => _products = null;
  void clearMachinesCache() => _machines = null;
  void clearServiceSuppliesCache() => _serviceSupplies = null;

  void clearAllCache() {
    clearProductsCache();
    clearMachinesCache();
    clearServiceSuppliesCache();
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<Product>> getProducts() async {
    if (_products != null) return _products!;
    final query = await supabase
        .from('products')
        .select()
        .eq('is_archived', false)
        .order('name');
    _products = query.map((r) => Product.fromJson(r)).toList();
    _hasPendingChanges = false;
    return _products!;
  }

  Future<List<Product>> getArchivedProducts() async {
    final query = await supabase
        .from('products')
        .select()
        .eq('is_archived', true)
        .order('name');
    return query.map((r) => Product.fromJson(r)).toList();
  }

  Future<void> archiveProduct(int id) async {
    await supabase
        .from('products')
        .update({'is_archived': true})
        .eq('id', id);
    _products?.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> restoreProduct(int id) async {
    await supabase
        .from('products')
        .update({'is_archived': false})
        .eq('id', id);
    // Clear cache so the restored product appears on next fetch
    _products = null;
    notifyListeners();
  }

  Future<Product> createProduct(Product product) async {
    final inserted = await supabase
        .from('products')
        .insert(product.toInsertJson())
        .select()
        .single();
    final newProduct = Product.fromJson(inserted);
    _products ??= [];
    _products!.add(newProduct);
    notifyListeners();
    return newProduct;
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('products')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    final updatedProduct = Product.fromJson(updated);
    if (_products != null) {
      final idx = _products!.indexWhere((p) => p.id == id);
      if (idx != -1) _products![idx] = updatedProduct;
    }
    notifyListeners();
    return updatedProduct;
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
    _products?.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ── Service Supplies ──────────────────────────────────────────────────────

  Future<List<ServiceSupply>> getServiceSupplies() async {
    if (_serviceSupplies != null) return _serviceSupplies!;
    final query =
        await supabase.from('service_supplies').select().order('name');
    _serviceSupplies =
        query.map((r) => ServiceSupply.fromJson(r)).toList();
    return _serviceSupplies!;
  }

  Future<ServiceSupply> createServiceSupply(
      ServiceSupply supply) async {
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
      int id, Map<String, dynamic> updates) async {
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

  // ── Machines ──────────────────────────────────────────────────────────────

  Future<List<Machine>> getMachines() async {
    if (_machines != null) return _machines!;
    final query = await supabase.from('machines').select().order('name');
    _machines = query.map((r) => Machine.fromJson(r)).toList();
    return _machines!;
  }

  Future<Machine> createMachine(Machine machine) async {
    final inserted = await supabase
        .from('machines')
        .insert(machine.toInsertJson())
        .select()
        .single();
    final newMachine = Machine.fromJson(inserted);
    _machines ??= [];
    _machines!.add(newMachine);
    notifyListeners();
    return newMachine;
  }

  Future<Machine> updateMachine(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('machines')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    final updatedMachine = Machine.fromJson(updated);
    if (_machines != null) {
      final idx = _machines!.indexWhere((m) => m.id == id);
      if (idx != -1) _machines![idx] = updatedMachine;
    }
    notifyListeners();
    return updatedMachine;
  }

  Future<void> deleteMachine(int id) async {
    await supabase.from('machines').delete().eq('id', id);
    _machines?.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
