import 'package:printsari_sia/shared/types/types.dart';

class Transaction {
  final int id;
  final String transactionNumber;
  final double subtotal;
  final double? tax;
  final double? discount;
  final double total;
  final DateTime date;
  final int statusId;
  final int paymentMethodId;
  final int cashierId;
  final int? customerId;
  final String? notes;
  final double storeRevenue;
  final double printingRevenue;
  final double? totalCost;
  final double? grossProfit;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final TransactionStatus? status;
  final PaymentMethod? paymentMethod;
  final Profile? cashier;
  final Customer? customer;
  final List<TransactionItem>? items;

  Transaction({
    required this.id,
    required this.transactionNumber,
    required this.subtotal,
    this.tax,
    this.discount,
    required this.total,
    required this.date,
    required this.statusId,
    required this.paymentMethodId,
    required this.cashierId,
    this.customerId,
    this.notes,
    required this.storeRevenue,
    required this.printingRevenue,
    this.totalCost,
    this.grossProfit,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.paymentMethod,
    this.cashier,
    this.customer,
    this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      transactionNumber: json['transaction_number'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      statusId: json['status_id'] as int,
      paymentMethodId: json['payment_method_id'] as int,
      cashierId: json['cashier_id'] as int,
      customerId: json['customer_id'] as int?,
      notes: json['notes'] as String?,
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      totalCost: json['total_cost'] != null
          ? (json['total_cost'] as num).toDouble()
          : null,
      grossProfit: json['gross_profit'] != null
          ? (json['gross_profit'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['transaction_statuses'] != null
          ? TransactionStatus.fromJson(
              json['transaction_statuses'] as Map<String, dynamic>,
            )
          : null,
      paymentMethod: json['payment_methods'] != null
          ? PaymentMethod.fromJson(
              json['payment_methods'] as Map<String, dynamic>,
            )
          : null,
      cashier: json['profiles'] != null
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      customer: json['customers'] != null
          ? Customer.fromJson(json['customers'] as Map<String, dynamic>)
          : null,
      items: json['transaction_items'] != null
          ? (json['transaction_items'] as List)
                .map(
                  (item) =>
                      TransactionItem.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'date': date.toIso8601String(),
      'status_id': statusId,
      'payment_method_id': paymentMethodId,
      'cashier_id': cashierId,
      'customer_id': customerId,
      'notes': notes,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'total_cost': totalCost,
      'gross_profit': grossProfit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'transaction_number': transactionNumber,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'date': date.toIso8601String(),
      'status_id': statusId,
      'payment_method_id': paymentMethodId,
      'cashier_id': cashierId,
      'customer_id': customerId,
      'notes': notes,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'total_cost': totalCost,
      'gross_profit': grossProfit,
    };
  }
}
