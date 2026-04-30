import 'package:printsari_sia/shared/types/types.dart';

class Expense {
  final int id;
  final String description;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String? receiptNumber;
  final String? vendor;
  final int? paymentMethodId;
  final String? notes;
  final int? linkedTransactionId;
  final int sourceId;
  final int? vendorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ExpenseCategory? category;
  final Transaction? linkedTransaction;
  final Vendor? vendorData;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.receiptNumber,
    this.vendor,
    this.paymentMethodId,
    this.notes,
    this.linkedTransactionId,
    required this.sourceId,
    this.vendorId,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.linkedTransaction,
    this.vendorData,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: (json['id'] as int?) ?? 0,
      description: (json['description'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: (json['category_id'] as int?) ?? 0,
      date: DateTime.parse(json['date'] as String),
      receiptNumber: json['receipt_number'] as String?,
      vendor: json['vendor'] as String?,
      paymentMethodId: json['payment_method_id'] as int?,
      notes: json['notes'] as String?,
      linkedTransactionId: json['linked_transaction_id'] as int?,
      sourceId: (json['source_id'] as int?) ?? 0,
      vendorId: json['vendor_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['expense_categories'] != null
          ? ExpenseCategory.fromJson(
              json['expense_categories'] as Map<String, dynamic>,
            )
          : null,
      linkedTransaction: json['transactions'] != null
          ? Transaction.fromJson(json['transactions'] as Map<String, dynamic>)
          : null,
      vendorData: json['vendors'] != null
          ? Vendor.fromJson(json['vendors'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'receipt_number': receiptNumber,
      'vendor': vendor,
      'payment_method_id': paymentMethodId,
      'notes': notes,
      'linked_transaction_id': linkedTransactionId,
      'source_id': sourceId,
      'vendor_id': vendorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'receipt_number': receiptNumber,
      'vendor': vendor,
      'payment_method_id': paymentMethodId,
      'notes': notes,
      'linked_transaction_id': linkedTransactionId,
      'source_id': sourceId,
      if (vendorId != null) 'vendor_id': vendorId,
    };
  }
}
