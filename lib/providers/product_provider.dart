import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  static const _productsKey = 'products';
  static const _servicesKey = 'print_services';

  List<Product>? _products;
  List<PrintService>? _services;
  bool _hasPendingChanges = false;
  RealtimeChannel? _channel;

  bool get hasPendingChanges => _hasPendingChanges;

  Box<String> get _box => Hive.box<String>('app_cache');

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
    _box.delete(_productsKey);
  }

  void clearServicesCache() {
    _services = null;
    _box.delete(_servicesKey);
  }

  void clearAllCache() {
    clearProductsCache();
    clearServicesCache();
  }

  Future<List<Product>> getProducts() async {
    if (_products != null) return _products!;

    final cached = _box.get(_productsKey);
    if (cached != null) {
      try {
        final raw = jsonDecode(cached) as List;
        _products = raw.map((r) => Product.fromJson(r as Map<String, dynamic>)).toList();
        return _products!;
      } catch (e) {
        debugPrint('Products cache parse error: $e');
        _box.delete(_productsKey);
      }
    }

    final query = await supabase.from('products').select('*, product_categories(*)');
    _products = query.map((r) => Product.fromJson(r)).toList();
    await _box.put(_productsKey, jsonEncode(query));
    _hasPendingChanges = false;
    return _products!;
  }

  Future<List<PrintService>> getPrintServices() async {
    if (_services != null) return _services!;

    final cached = _box.get(_servicesKey);
    if (cached != null) {
      try {
        final raw = jsonDecode(cached) as List;
        _services = raw.map((r) => PrintService.fromJson(r as Map<String, dynamic>)).toList();
        return _services!;
      } catch (e) {
        debugPrint('PrintServices cache parse error: $e');
        _box.delete(_servicesKey);
      }
    }

    final query = await supabase
        .from('print_services')
        .select('*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*)');
    _services = query.map((r) => PrintService.fromJson(r)).toList();
    await _box.put(_servicesKey, jsonEncode(query));
    _hasPendingChanges = false;
    return _services!;
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
    _box.delete(_productsKey);
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
    _box.delete(_productsKey);
    notifyListeners();
    return updatedProduct;
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
    _products?.removeWhere((p) => p.id == id);
    _box.delete(_productsKey);
    notifyListeners();
  }

  Future<PrintService> createPrintService(PrintService service) async {
    final inserted = await supabase
        .from('print_services')
        .insert(service.toInsertJson())
        .select('*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*)')
        .single();
    final newService = PrintService.fromJson(inserted);
    _services ??= [];
    _services!.add(newService);
    _box.delete(_servicesKey);
    notifyListeners();
    return newService;
  }

  Future<PrintService> updatePrintService(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('print_services')
        .update(updates)
        .eq('id', id)
        .select('*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*)')
        .single();
    final updatedService = PrintService.fromJson(updated);
    if (_services != null) {
      final idx = _services!.indexWhere((s) => s.id == id);
      if (idx != -1) _services![idx] = updatedService;
    }
    _box.delete(_servicesKey);
    notifyListeners();
    return updatedService;
  }

  Future<void> deletePrintService(int id) async {
    await supabase.from('print_services').delete().eq('id', id);
    _services?.removeWhere((s) => s.id == id);
    _box.delete(_servicesKey);
    notifyListeners();
  }
}
