import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/customer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Customer>? _customers;

  void clearCache() => _customers = null;

  Future<List<Customer>> getCustomers() async {
    if (_customers != null) return _customers!;
    final data = await supabase
        .from('customers')
        .select()
        .eq('is_archived', false)
        .order('name');
    _customers = (data as List).map((r) => Customer.fromJson(r as Map<String, dynamic>)).toList();
    return _customers!;
  }

  Future<List<Customer>> getArchivedCustomers() async {
    final data = await supabase
        .from('customers')
        .select()
        .eq('is_archived', true)
        .order('name');
    return (data as List).map((r) => Customer.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Customer> createCustomer(Map<String, dynamic> fields) async {
    final inserted = await supabase
        .from('customers')
        .insert(fields)
        .select()
        .single();
    final customer = Customer.fromJson(inserted);
    _customers ??= [];
    _customers!.add(customer);
    _customers!.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    notifyListeners();
    return customer;
  }

  Future<Customer> updateCustomer(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('customers')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    final customer = Customer.fromJson(updated);
    if (_customers != null) {
      final idx = _customers!.indexWhere((c) => c.id == id);
      if (idx != -1) _customers![idx] = customer;
    }
    notifyListeners();
    return customer;
  }

  Future<void> archiveCustomer(int id) async {
    await supabase.from('customers').update({'is_archived': true}).eq('id', id);
    _customers?.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> restoreCustomer(int id) async {
    await supabase.from('customers').update({'is_archived': false}).eq('id', id);
    _customers = null;
    notifyListeners();
  }

  Future<void> tagTransactionCustomer(int transactionId, int customerId) async {
    await supabase
        .from('transactions')
        .update({'customer_id': customerId})
        .eq('id', transactionId);
  }
}
