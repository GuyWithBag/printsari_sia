import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Product>? _products;
  List<PrintService>? _services;
  List<Machine>? _machines;
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
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'print_services',
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

  void clearProductsCache() {
    _products = null;
  }

  void clearServicesCache() {
    _services = null;
  }

  void clearMachinesCache() {
    _machines = null;
  }

  void clearAllCache() {
    clearProductsCache();
    clearServicesCache();
    clearMachinesCache();
  }

  Future<List<Product>> getProducts() async {
    if (_products != null) return _products!;

    final query = await supabase.from('products').select('*, product_categories(*)');
    _products = query.map((r) => Product.fromJson(r)).toList();
    _hasPendingChanges = false;
    return _products!;
  }

  Future<List<PrintService>> getPrintServices() async {
    if (_services != null) return _services!;

    final query = await supabase
        .from('print_services')
        .select('*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*), machines(*), service_supplies(*)');
    _services = query.map((r) => PrintService.fromJson(r)).toList();
    _hasPendingChanges = false;
    return _services!;
  }

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

  Future<Product> createProduct(Product product) async {
    final inserted = await supabase
        .from('products')
        .insert(product.toInsertJson())
        .select('*, product_categories(*)')
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
        .select('*, product_categories(*)')
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

  Future<PrintService> createPrintService(PrintService service) async {
    final inserted = await supabase
        .from('print_services')
        .insert(service.toInsertJson())
        .select('*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*), machines(*), service_supplies(*)')
        .single();
    final newService = PrintService.fromJson(inserted);
    _services ??= [];
    _services!.add(newService);
    notifyListeners();
    return newService;
  }

  Future<PrintService> updatePrintService(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('print_services')
        .update(updates)
        .eq('id', id)
        .select('*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*), machines(*), service_supplies(*)')
        .single();
    final updatedService = PrintService.fromJson(updated);
    if (_services != null) {
      final idx = _services!.indexWhere((s) => s.id == id);
      if (idx != -1) _services![idx] = updatedService;
    }
    notifyListeners();
    return updatedService;
  }

  Future<void> deletePrintService(int id) async {
    await supabase.from('print_services').delete().eq('id', id);
    _services?.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
