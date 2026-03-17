import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  static const _transactionsKey = 'transactions';
  List<Transaction>? _transactions;
  Box<String> get _box => Hive.box<String>('app_cache');

  void clearTransactionsCache() {
    _transactions = null;
    _box.delete(_transactionsKey);
  }

  List<TransactionItem> _cart = [];

  List<TransactionItem> get cart => _cart;

  void addToCart(TransactionItem item) {
    _cart.add(item);
    notifyListeners();
  }

  void updateCartItemQuantity(int index, double quantity) {
    final item = _cart[index];
    _cart[index] = TransactionItem(
      id: item.id,
      transactionId: item.transactionId,
      inventoryId: item.inventoryId,
      productId: item.productId,
      productName: item.productName,
      quantity: quantity,
      unitPrice: item.unitPrice,
      subtotal: item.unitPrice * quantity,
      categoryId: item.categoryId,
      discount: item.discount,
      printOrderId: item.printOrderId,
      itemCost: item.itemCost,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cart = [];
    notifyListeners();
  }

  double get cartSubtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get cartStoreRevenue => _cart
      .where((item) => item.categoryId == 1)
      .fold(0.0, (sum, item) => sum + item.subtotal);

  double get cartPrintingRevenue => _cart
      .where((item) => item.categoryId == 2)
      .fold(0.0, (sum, item) => sum + item.subtotal);

  Future<Transaction?> checkout({
    required int cashierId,
    required int paymentMethodId,
    int? customerId,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final storeRevenue = cartStoreRevenue;
      final printingRevenue = cartPrintingRevenue;
      final subtotal = cartSubtotal;

      // Calculate total cost from cart items that have itemCost
      double totalCost = 0.0;
      for (final item in _cart) {
        if (item.itemCost != null) {
          totalCost += item.itemCost!;
        }
      }

      final grossProfit = subtotal - totalCost;

      // Generate transaction number: TXN-{yyyyMMdd}-{sequential 3 digit}
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final todayTransactions = await supabase
          .from('transactions')
          .select('id')
          .like('transaction_number', 'TXN-$dateStr-%');
      final sequentialNumber =
          (todayTransactions.length + 1).toString().padLeft(3, '0');
      final transactionNumber = 'TXN-$dateStr-$sequentialNumber';

      // Insert Transaction
      final transactionData = {
        'transaction_number': transactionNumber,
        'subtotal': subtotal,
        'total': subtotal,
        'date': now.toIso8601String(),
        'status_id': 1, // completed
        'payment_method_id': paymentMethodId,
        'cashier_id': cashierId,
        'customer_id': customerId,
        'notes': notes,
        'store_revenue': storeRevenue,
        'printing_revenue': printingRevenue,
        'total_cost': totalCost,
        'gross_profit': grossProfit,
      };

      final insertedTransaction = await supabase
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();

      final transactionId = insertedTransaction['id'] as int;

      // Insert each TransactionItem linked to the new transaction
      for (final item in _cart) {
        final itemData = {
          'transaction_id': transactionId,
          'inventory_id': item.inventoryId,
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
          'category_id': item.categoryId,
          'discount': item.discount,
          'print_order_id': item.printOrderId,
          'item_cost': item.itemCost,
        };
        await supabase.from('transaction_items').insert(itemData);

        // Deduct inventory for items with inventoryId
        if (item.inventoryId != null) {
          final inventoryRow = await supabase
              .from('inventory_items')
              .select('stock')
              .eq('id', item.inventoryId!)
              .single();
          final currentStock = (inventoryRow['stock'] as num).toDouble();
          await supabase
              .from('inventory_items')
              .update({'stock': currentStock - item.quantity})
              .eq('id', item.inventoryId!);
        }

        // Auto-generate expenses for print items
        if (item.printOrderId != null) {
          final printOrderRow = await supabase
              .from('print_orders')
              .select('*, print_services(*)')
              .eq('id', item.printOrderId!)
              .single();
          final printOrder = PrintOrder.fromJson(printOrderRow);
          final service = printOrder.service!;

          final expenseDate = now.toIso8601String();
          final expenses = [
            {
              'description':
                  'Ink cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': service.inkCostPerPage * printOrder.quantity,
              'category_id': 1, // printing_ink
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2, // auto_print
            },
            {
              'description':
                  'Paper cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': service.paperCostPerPage * printOrder.quantity,
              'category_id': 2, // printing_paper
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2, // auto_print
            },
            {
              'description':
                  'Electricity cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': service.electricityCostPerPage * printOrder.quantity,
              'category_id': 3, // printing_electricity
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2, // auto_print
            },
            {
              'description':
                  'Maintenance cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': service.maintenanceCostPerPage * printOrder.quantity,
              'category_id': 4, // printing_maintenance
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2, // auto_print
            },
          ];

          await supabase.from('expenses').insert(expenses);
        }
      }

      // Clear cart and invalidate transactions cache (new transaction added)
      _cart = [];
      _transactions = null;
      _box.delete(_transactionsKey);
      notifyListeners();

      return Transaction.fromJson(insertedTransaction);
    } catch (e) {
      debugPrint('Checkout error: $e');
      return null;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    if (_transactions != null) return _transactions!;

    final cached = _box.get(_transactionsKey);
    if (cached != null) {
      try {
        final raw = jsonDecode(cached) as List;
        _transactions = raw.map((r) => Transaction.fromJson(r as Map<String, dynamic>)).toList();
        return _transactions!;
      } catch (e) {
        debugPrint('Transactions cache parse error: $e');
        _box.delete(_transactionsKey);
      }
    }

    final query = await supabase
        .from('transactions')
        .select(
          '*, transaction_statuses(*), payment_methods(*), profiles(*), customers(*), transaction_items(*)',
        )
        .order('created_at', ascending: false);
    _transactions = query.map((r) => Transaction.fromJson(r)).toList();
    await _box.put(_transactionsKey, jsonEncode(query));
    return _transactions!;
  }

  Future<Transaction?> getTransaction(int id) async {
    try {
      final query = await supabase
          .from('transactions')
          .select(
            '*, transaction_statuses(*), payment_methods(*), profiles(*), customers(*), transaction_items(*)',
          )
          .eq('id', id)
          .single();
      return Transaction.fromJson(query);
    } catch (e) {
      debugPrint('Get transaction error: $e');
      return null;
    }
  }
}
