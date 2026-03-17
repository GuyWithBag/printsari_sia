import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<List<Expense>> getExpenses() async {
    final query = await supabase
        .from('expenses')
        .select(
          '*, expense_categories(*), payment_methods(*), expense_sources(*)',
        )
        .order('date', ascending: false);
    final result = List.generate(
      query.length,
      (i) => Expense.fromJson(query[i]),
    );
    return result;
  }

  Future<Expense> createExpense(Expense expense) async {
    final data = expense.toInsertJson();
    data['source_id'] = 1; // manual
    final inserted = await supabase
        .from('expenses')
        .insert(data)
        .select(
          '*, expense_categories(*), payment_methods(*), expense_sources(*)',
        )
        .single();
    notifyListeners();
    return Expense.fromJson(inserted);
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
        .select(
          '*, expense_categories(*), payment_methods(*), expense_sources(*)',
        )
        .single();
    notifyListeners();
    return Expense.fromJson(updated);
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
    notifyListeners();
  }

  Future<List<Expense>> getExpensesForTransaction(int transactionId) async {
    final query = await supabase
        .from('expenses')
        .select(
          '*, expense_categories(*), payment_methods(*), expense_sources(*)',
        )
        .eq('linked_transaction_id', transactionId);
    final result = List.generate(
      query.length,
      (i) => Expense.fromJson(query[i]),
    );
    return result;
  }
}
