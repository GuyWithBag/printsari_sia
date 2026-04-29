import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Transaction>? _transactions;

  // Incremented each time checkout() succeeds.
  // Used by BusinessExpensesPage to auto-refresh its list.
  int _completedTransactionCount = 0;
  int get completedTransactionCount => _completedTransactionCount;

  void clearTransactionsCache() {
    _transactions = null;
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

      // Insert each TransactionItem and deduct inventory
      for (final item in _cart) {
        final itemData = <String, dynamic>{
          'transaction_id': transactionId,
          'inventory_id': item.inventoryId,
          if (item.productId != null) 'product_id': item.productId,
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

        // Deduct inventory for store items with inventoryId
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

        // Auto-generate expenses and deduct supply stock for print items
        if (item.printOrderId != null) {
          final printOrderRow = await supabase
              .from('print_orders')
              .select('*, service_types(*, service_type_costs(*))')
              .eq('id', item.printOrderId!)
              .single();
          final printOrder = PrintOrder.fromJson(printOrderRow);
          final service = printOrder.serviceType;
          final cost = service?.cost;

          final expenseDate = now.toIso8601String();
          final expenses = [
            {
              'description':
                  'Ink cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': (cost?.inkCost ?? 0) * printOrder.quantity,
              'category_id': 1,
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2,
            },
            {
              'description':
                  'Supply cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': (cost?.serviceSupplyCost ?? 0) * printOrder.quantity,
              'category_id': 2,
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2,
            },
            {
              'description':
                  'Electricity cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': (cost?.electricityCost ?? 0) * printOrder.quantity,
              'category_id': 3,
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2,
            },
            {
              'description':
                  'Labor cost - ${item.productName} (${printOrder.quantity} pages)',
              'amount': (cost?.laborCost ?? 0) * printOrder.quantity,
              'category_id': 4,
              'date': expenseDate,
              'linked_transaction_id': transactionId,
              'source_id': 2,
            },
          ];

          await supabase.from('expenses').insert(expenses);

          // Deduct supply stock if this service type links to a service supply
          if (service?.serviceSupplyId != null) {
            final supplyRow = await supabase
                .from('inventory_items')
                .select('id, stock')
                .eq('service_supply_id', service!.serviceSupplyId!)
                .maybeSingle();
            if (supplyRow != null) {
              final currentStock = (supplyRow['stock'] as num).toDouble();
              final deduction = printOrder.quantity.toDouble();
              final supplyInventoryId = supplyRow['id'] as int;
              await supabase
                  .from('inventory_items')
                  .update({'stock': (currentStock - deduction).clamp(0.0, double.infinity)})
                  .eq('id', supplyInventoryId);

              // Get cashier profile id for stock_out record
              final currentUser = supabase.auth.currentUser;
              if (currentUser != null) {
                final profileRow = await supabase
                    .from('profiles')
                    .select('id')
                    .eq('user_id', currentUser.id)
                    .maybeSingle();
                if (profileRow != null) {
                  await supabase.from('stock_out').insert({
                    'user_id': profileRow['id'] as int,
                    'quantity_removed': deduction,
                    'transaction_id': transactionId,
                    'service_supply_id': service!.serviceSupplyId,
                    'inventory_item_id': supplyInventoryId,
                    'stock_out_type': 'sale',
                    'stock_out_date': now.toIso8601String(),
                  });
                }
              }
            }
          }
        }
      }

      _cart = [];
      _transactions = null;
      _completedTransactionCount++;
      notifyListeners();

      return Transaction.fromJson(insertedTransaction);
    } catch (e) {
      debugPrint('Checkout error: $e');
      return null;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    if (_transactions != null) return _transactions!;

    final query = await supabase
        .from('transactions')
        .select(
          '*, transaction_statuses(*), payment_methods(*), profiles(*), customers(*), transaction_items(*)',
        )
        .order('created_at', ascending: false);
    _transactions = query.map((r) => Transaction.fromJson(r)).toList();
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
