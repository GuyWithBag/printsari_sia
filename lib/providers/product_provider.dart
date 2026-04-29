import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/service_supply.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Product>? _products;
  List<Service>? _services;
  List<ServiceType>? _serviceTypes;
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
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'service_types',
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
  void clearServicesCache() => _services = null;
  void clearServiceTypesCache() => _serviceTypes = null;
  void clearMachinesCache() => _machines = null;
  void clearServiceSuppliesCache() => _serviceSupplies = null;

  void clearAllCache() {
    clearProductsCache();
    clearServicesCache();
    clearServiceTypesCache();
    clearMachinesCache();
    clearServiceSuppliesCache();
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<Product>> getProducts() async {
    if (_products != null) return _products!;
    final query = await supabase.from('products').select().order('name');
    _products = query.map((r) => Product.fromJson(r)).toList();
    _hasPendingChanges = false;
    return _products!;
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

  // ── Services ──────────────────────────────────────────────────────────────

  Future<List<Service>> getServices() async {
    if (_services != null) return _services!;
    final query = await supabase.from('services').select().order('name');
    _services = query.map((r) => Service.fromJson(r)).toList();
    return _services!;
  }

  Future<Service> createService(String name) async {
    final inserted = await supabase
        .from('services')
        .insert({'name': name})
        .select()
        .single();
    final newService = Service.fromJson(inserted);
    _services ??= [];
    _services!.add(newService);
    notifyListeners();
    return newService;
  }

  Future<Service> updateService(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('services')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    final updatedService = Service.fromJson(updated);
    if (_services != null) {
      final idx = _services!.indexWhere((s) => s.id == id);
      if (idx != -1) _services![idx] = updatedService;
    }
    notifyListeners();
    return updatedService;
  }

  Future<void> deleteService(int id) async {
    await supabase.from('services').delete().eq('id', id);
    _services?.removeWhere((s) => s.id == id);
    _serviceTypes?.removeWhere((st) => st.serviceId == id);
    notifyListeners();
  }

  // ── Service Types ─────────────────────────────────────────────────────────

  Future<List<ServiceType>> getServiceTypes() async {
    if (_serviceTypes != null) return _serviceTypes!;
    final query = await supabase
        .from('service_types')
        .select(
            '*, services(*), service_supplies(*), machines(*), service_type_costs(*)')
        .order('name');
    _serviceTypes = query.map((r) => ServiceType.fromJson(r)).toList();
    _hasPendingChanges = false;
    return _serviceTypes!;
  }

  Future<ServiceType> createServiceType(ServiceType st) async {
    final inserted = await supabase
        .from('service_types')
        .insert(st.toInsertJson())
        .select(
            '*, services(*), service_supplies(*), machines(*), service_type_costs(*)')
        .single();
    final newSt = ServiceType.fromJson(inserted);
    _serviceTypes ??= [];
    _serviceTypes!.add(newSt);
    notifyListeners();
    return newSt;
  }

  Future<ServiceType> updateServiceType(
      int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('service_types')
        .update(updates)
        .eq('id', id)
        .select(
            '*, services(*), service_supplies(*), machines(*), service_type_costs(*)')
        .single();
    final updatedSt = ServiceType.fromJson(updated);
    if (_serviceTypes != null) {
      final idx = _serviceTypes!.indexWhere((s) => s.id == id);
      if (idx != -1) _serviceTypes![idx] = updatedSt;
    }
    notifyListeners();
    return updatedSt;
  }

  Future<void> deleteServiceType(int id) async {
    await supabase.from('service_types').delete().eq('id', id);
    _serviceTypes?.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ── Service Type Costs ────────────────────────────────────────────────────

  Future<ServiceTypeCost> upsertServiceTypeCost(
      int serviceTypeId, Map<String, dynamic> costData) async {
    final existing = await supabase
        .from('service_type_costs')
        .select()
        .eq('service_type_id', serviceTypeId)
        .order('last_updated', ascending: false)
        .limit(1)
        .maybeSingle();

    Map<String, dynamic> result;
    if (existing != null) {
      result = await supabase
          .from('service_type_costs')
          .update({
            ...costData,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id'] as int)
          .select()
          .single();
    } else {
      result = await supabase
          .from('service_type_costs')
          .insert({...costData, 'service_type_id': serviceTypeId})
          .select()
          .single();
    }
    _serviceTypes = null;
    notifyListeners();
    return ServiceTypeCost.fromJson(result);
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
