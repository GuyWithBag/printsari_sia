import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  static const _expensesKey = 'expenses';

  List<Expense>? _expenses;

  Box<String> get _box => Hive.box<String>('app_cache');

  void clearCache() {
    _expenses = null;
    _box.delete(_expensesKey);
  }

  Future<List<Expense>> getExpenses() async {
    if (_expenses != null) return _expenses!;

    final cached = _box.get(_expensesKey);
    if (cached != null) {
      try {
        final raw = jsonDecode(cached) as List;
        _expenses = raw.map((r) => Expense.fromJson(r as Map<String, dynamic>)).toList();
        return _expenses!;
      } catch (e) {
        debugPrint('Expenses cache parse error: $e');
        _box.delete(_expensesKey);
      }
    }

    final query = await supabase
        .from('expenses')
        .select('*, expense_categories(*), payment_methods(*), expense_sources(*)')
        .order('date', ascending: false);
    _expenses = query.map((r) => Expense.fromJson(r)).toList();
    await _box.put(_expensesKey, jsonEncode(query));
    return _expenses!;
  }

  Future<Expense> createExpense(Expense expense) async {
    final data = expense.toInsertJson();
    data['source_id'] = 1; // manual
    final inserted = await supabase
        .from('expenses')
        .insert(data)
        .select('*, expense_categories(*), payment_methods(*), expense_sources(*)')
        .single();
    final newExpense = Expense.fromJson(inserted);
    _expenses ??= [];
    _expenses!.insert(0, newExpense); // insert at top (ordered by date desc)
    _box.delete(_expensesKey);
    notifyListeners();
    return newExpense;
  }

  Future<Expense> updateExpense(int id, Map<String, dynamic> updates) async {
    // Only allow updating manual expenses (source_id = 1)
    final existing = await supabase
        .from('expenses')
        .select('source_id')
        .eq('id', id)
        .single();
    if (existing['source_id'] != 1) {
      throw Exception('Cannot update auto-generated expenses');
    }

    final updated = await supabase
        .from('expenses')
        .update(updates)
        .eq('id', id)
        .select('*, expense_categories(*), payment_methods(*), expense_sources(*)')
        .single();
    final updatedExpense = Expense.fromJson(updated);
    if (_expenses != null) {
      final idx = _expenses!.indexWhere((e) => e.id == id);
      if (idx != -1) _expenses![idx] = updatedExpense;
    }
    _box.delete(_expensesKey);
    notifyListeners();
    return updatedExpense;
  }

  Future<void> deleteExpense(int id) async {
    // Only allow deleting manual expenses (source_id = 1)
    final existing = await supabase
        .from('expenses')
        .select('source_id')
        .eq('id', id)
        .single();
    if (existing['source_id'] != 1) {
      throw Exception('Cannot delete auto-generated expenses');
    }

    await supabase.from('expenses').delete().eq('id', id);
    _expenses?.removeWhere((e) => e.id == id);
    _box.delete(_expensesKey);
    notifyListeners();
  }

  Future<List<Expense>> getExpensesForTransaction(int transactionId) async {
    // Always fetch from Supabase — transaction-specific, not worth caching
    final query = await supabase
        .from('expenses')
        .select('*, expense_categories(*), payment_methods(*), expense_sources(*)')
        .eq('linked_transaction_id', transactionId);
    return query.map((r) => Expense.fromJson(r)).toList();
  }
}
