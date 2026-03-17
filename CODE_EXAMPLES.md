# Flutter Code Examples for POS System

This document contains example Flutter code snippets for implementing the POS system. Use these as references when building the actual implementation.

---

## 📦 Data Models

### User Model
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole { owner, cashier }

@JsonSerializable()
class Address {
  final String street;
  final String barangay;
  final String city;
  final String province;
  final String region;
  final String postalCode;
  final String country;

  Address({
    required this.street,
    required this.barangay,
    required this.city,
    required this.province,
    required this.region,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String username;
  final UserRole role;
  final String name;
  final String? phone;
  final String? profilePicture;
  final Address? address;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.name,
    this.phone,
    this.profilePicture,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  User copyWith({
    String? id,
    String? username,
    UserRole? role,
    String? name,
    String? phone,
    String? profilePicture,
    Address? address,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address ?? this.address,
    );
  }
}
```

### Transaction Model
```dart
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionStatus { completed, pending, cancelled, refunded }
enum PaymentMethod { cash, gcash, card, credit }

@JsonSerializable()
class Transaction {
  final String id;
  final String transactionNumber;
  final List<TransactionItem> items;
  final double subtotal;
  final double? tax;
  final double? discount;
  final double total;
  final String date;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final String cashierId;
  final String cashierName;
  final String? customerId;
  final String? notes;
  
  // Critical fields for department tracking
  final double storeRevenue;
  final double printingRevenue;
  final double? totalCost;
  final double? grossProfit;

  Transaction({
    required this.id,
    required this.transactionNumber,
    required this.items,
    required this.subtotal,
    this.tax,
    this.discount,
    required this.total,
    required this.date,
    required this.status,
    required this.paymentMethod,
    required this.cashierId,
    required this.cashierName,
    this.customerId,
    this.notes,
    required this.storeRevenue,
    required this.printingRevenue,
    this.totalCost,
    this.grossProfit,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => 
    _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class TransactionItem {
  final String id;
  final String inventoryId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final ProductCategory category;
  final double? discount;
  final PrintResourceConsumption? printResourceConsumption;
  final double? itemCost;

  TransactionItem({
    required this.id,
    required this.inventoryId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.category,
    this.discount,
    this.printResourceConsumption,
    this.itemCost,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) => 
    _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);
  
  TransactionItem copyWith({
    int? quantity,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id,
      inventoryId: inventoryId,
      productId: productId,
      productName: productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      subtotal: subtotal ?? this.subtotal,
      category: category,
      discount: discount,
      printResourceConsumption: printResourceConsumption,
      itemCost: itemCost,
    );
  }
}
```

### Print Service Model
```dart
import 'package:json_annotation/json_annotation.dart';

part 'print_service.g.dart';

enum PaperSize { short, long, a4, legal, letter }
enum ColorMode { bw, colored, grayscale }
enum PrintOrientation { portrait, landscape }
enum PrintFinish { none, laminated, bound }

@JsonSerializable()
class PrintCostBreakdown {
  final double inkCostPerPage;
  final double paperCostPerPage;
  final double electricityCostPerPage;
  final double maintenanceCostPerPage;
  final double totalCostPerPage;

  PrintCostBreakdown({
    required this.inkCostPerPage,
    required this.paperCostPerPage,
    required this.electricityCostPerPage,
    required this.maintenanceCostPerPage,
    required this.totalCostPerPage,
  });

  factory PrintCostBreakdown.fromJson(Map<String, dynamic> json) => 
    _$PrintCostBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$PrintCostBreakdownToJson(this);
}

@JsonSerializable()
class PrintResourceConsumption {
  final double inkUsed;
  final int paperUsed;
  final double electricityUsed;
  final double totalCost;

  PrintResourceConsumption({
    required this.inkUsed,
    required this.paperUsed,
    required this.electricityUsed,
    required this.totalCost,
  });

  factory PrintResourceConsumption.fromJson(Map<String, dynamic> json) => 
    _$PrintResourceConsumptionFromJson(json);
  Map<String, dynamic> toJson() => _$PrintResourceConsumptionToJson(this);
}

@JsonSerializable()
class PrintService {
  final String id;
  final String name;
  final String description;
  final PaperSize paperSize;
  final ColorMode colorMode;
  final double basePrice;
  final PrintCostBreakdown costBreakdown;
  final PrintOrientation? orientation;
  final PrintFinish? finish;
  final int? paperStock;
  final int? inkLevel;

  PrintService({
    required this.id,
    required this.name,
    required this.description,
    required this.paperSize,
    required this.colorMode,
    required this.basePrice,
    required this.costBreakdown,
    this.orientation,
    this.finish,
    this.paperStock,
    this.inkLevel,
  });

  factory PrintService.fromJson(Map<String, dynamic> json) => 
    _$PrintServiceFromJson(json);
  Map<String, dynamic> toJson() => _$PrintServiceToJson(this);
}
```

---

## 🔐 Authentication Provider

```dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/activity_log_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _db;
  final ActivityLogService _activityLog;
  
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._db, this._activityLog);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  
  bool get isOwner => _currentUser?.role == UserRole.owner;
  bool get isCashier => _currentUser?.role == UserRole.cashier;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user from database
      final user = await _db.getUserByUsername(username);
      
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify password (use bcrypt or similar in production)
      final isValid = await _verifyPassword(password, user.passwordHash);
      
      if (!isValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      
      // Log successful login
      await _activityLog.addLog(
        action: 'user_login',
        description: 'User logged in: ${user.name}',
        performedBy: user.name,
        performedById: user.id,
        metadata: {
          'username': user.username,
          'role': user.role.toString(),
        },
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      // Log logout
      await _activityLog.addLog(
        action: 'user_logout',
        description: 'User logged out: ${_currentUser!.name}',
        performedBy: _currentUser!.name,
        performedById: _currentUser!.id,
        metadata: {
          'username': _currentUser!.username,
        },
      );
    }

    _currentUser = null;
    notifyListeners();
  }

  Future<bool> _verifyPassword(String password, String hash) async {
    // TODO: Implement proper password verification with bcrypt
    // For now, simple comparison (INSECURE - only for development)
    return password == hash;
  }
}
```

---

## 🛒 Transaction Provider (POS Logic)

```dart
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../services/expense_service.dart';
import '../services/activity_log_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _db;
  final ExpenseService _expenseService;
  final ActivityLogService _activityLog;

  List<Transaction> _transactions = [];
  List<TransactionItem> _cart = [];
  bool _isLoading = false;

  TransactionProvider(this._db, this._expenseService, this._activityLog);

  List<Transaction> get transactions => _transactions;
  List<TransactionItem> get cart => _cart;
  bool get isLoading => _isLoading;

  double get cartSubtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  
  double get cartStoreRevenue => _cart
    .where((item) => item.category == ProductCategory.store)
    .fold(0.0, (sum, item) => sum + item.subtotal);
    
  double get cartPrintingRevenue => _cart
    .where((item) => item.category == ProductCategory.printing)
    .fold(0.0, (sum, item) => sum + item.subtotal);

  void addToCart({
    required Product product,
    required InventoryItem inventory,
    int quantity = 1,
  }) {
    if (inventory.stock < quantity) {
      throw Exception('Insufficient stock');
    }

    final existingIndex = _cart.indexWhere(
      (item) => item.productId == product.id
    );

    if (existingIndex >= 0) {
      final existing = _cart[existingIndex];
      final newQuantity = existing.quantity + quantity;
      
      if (newQuantity > inventory.stock) {
        throw Exception('Insufficient stock');
      }

      _cart[existingIndex] = existing.copyWith(
        quantity: newQuantity,
        subtotal: inventory.retailPrice * newQuantity,
      );
    } else {
      _cart.add(TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inventoryId: inventory.id,
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: inventory.retailPrice,
        subtotal: inventory.retailPrice * quantity,
        category: product.category,
        itemCost: product.category == ProductCategory.store 
          ? product.purchasePrice * quantity 
          : null, // Will be calculated for print services
      ));
    }

    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(
        quantity: newQuantity,
        subtotal: _cart[index].unitPrice * newQuantity,
      );
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<Transaction> checkout({
    required String cashierId,
    required String cashierName,
    required PaymentMethod paymentMethod,
    double? tax,
    double? discount,
    String? customerId,
    String? notes,
  }) async {
    if (_cart.isEmpty) {
      throw Exception('Cart is empty');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Calculate totals
      final subtotal = cartSubtotal;
      final total = subtotal + (tax ?? 0) - (discount ?? 0);
      final storeRevenue = cartStoreRevenue;
      final printingRevenue = cartPrintingRevenue;
      
      // Calculate total cost for profit margin
      double totalCost = 0.0;
      
      // Process print items and calculate resource consumption
      final processedItems = <TransactionItem>[];
      for (var item in _cart) {
        if (item.category == ProductCategory.printing) {
          // Get print service details
          final printService = await _db.getPrintService(item.productId);
          if (printService == null) {
            throw Exception('Print service not found');
          }

          // Calculate resource consumption
          final resourceConsumption = _calculateResourceConsumption(
            printService,
            item.quantity,
          );

          totalCost += resourceConsumption.totalCost;

          processedItems.add(TransactionItem(
            id: item.id,
            inventoryId: item.inventoryId,
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            subtotal: item.subtotal,
            category: item.category,
            discount: item.discount,
            printResourceConsumption: resourceConsumption,
            itemCost: resourceConsumption.totalCost,
          ));
        } else {
          // Store item - use purchase price as cost
          final product = await _db.getProduct(item.productId);
          final cost = product!.purchasePrice * item.quantity;
          totalCost += cost;
          
          processedItems.add(item.copyWith());
        }
      }

      final grossProfit = total - totalCost;

      // Create transaction
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transactionNumber: _generateTransactionNumber(),
        items: processedItems,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        date: DateTime.now().toIso8601String(),
        status: TransactionStatus.completed,
        paymentMethod: paymentMethod,
        cashierId: cashierId,
        cashierName: cashierName,
        customerId: customerId,
        notes: notes,
        storeRevenue: storeRevenue,
        printingRevenue: printingRevenue,
        totalCost: totalCost,
        grossProfit: grossProfit,
      );

      // Save transaction to database
      await _db.createTransaction(transaction);

      // Deduct inventory for all items
      for (var item in processedItems) {
        await _db.updateInventoryStock(
          item.inventoryId,
          -item.quantity, // Negative to deduct
        );

        // Log inventory deduction
        await _activityLog.addLog(
          action: 'inventory_depleted',
          description: 'Stock deducted: ${item.productName} (-${item.quantity})',
          performedBy: cashierName,
          performedById: cashierId,
          metadata: {
            'productId': item.productId,
            'inventoryId': item.inventoryId,
            'quantityDeducted': item.quantity,
            'transactionId': transaction.id,
          },
        );
      }

      // Generate auto-expenses for print items
      for (var item in processedItems) {
        if (item.category == ProductCategory.printing && 
            item.printResourceConsumption != null) {
          await _expenseService.generatePrintExpenses(
            transaction: transaction,
            transactionItem: item,
            resourceConsumption: item.printResourceConsumption!,
          );
        }
      }

      // Log transaction
      final itemsList = processedItems
        .map((item) => '${item.quantity}x ${item.productName}')
        .join(', ');
      
      await _activityLog.addLog(
        action: 'transaction_created',
        description: 'Completed sale: $itemsList - Total: ₱${total.toStringAsFixed(2)}',
        performedBy: cashierName,
        performedById: cashierId,
        metadata: {
          'transactionId': transaction.id,
          'transactionNumber': transaction.transactionNumber,
          'total': total,
          'itemCount': processedItems.length,
          'storeRevenue': storeRevenue,
          'printingRevenue': printingRevenue,
          'grossProfit': grossProfit,
        },
      );

      _transactions.insert(0, transaction);
      _cart.clear();
      _isLoading = false;
      notifyListeners();

      return transaction;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  PrintResourceConsumption _calculateResourceConsumption(
    PrintService service,
    int quantity,
  ) {
    final inkUsed = _calculateInkUsage(service.colorMode, quantity);
    final paperUsed = quantity;
    final electricityUsed = _calculateElectricityUsage(quantity);
    
    final totalCost = service.costBreakdown.totalCostPerPage * quantity;

    return PrintResourceConsumption(
      inkUsed: inkUsed,
      paperUsed: paperUsed,
      electricityUsed: electricityUsed,
      totalCost: totalCost,
    );
  }

  double _calculateInkUsage(ColorMode colorMode, int pages) {
    // Simplified calculation - adjust based on actual printer specs
    switch (colorMode) {
      case ColorMode.bw:
        return pages * 0.5; // 0.5% per page for B&W
      case ColorMode.grayscale:
        return pages * 1.0; // 1% per page
      case ColorMode.colored:
        return pages * 3.0; // 3% per page for colored
    }
  }

  double _calculateElectricityUsage(int pages) {
    // Simplified: assume 0.001 kWh per page
    return pages * 0.001;
  }

  String _generateTransactionNumber() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    // Count today's transactions
    final todayCount = _transactions.where((t) {
      final tDate = DateTime.parse(t.date);
      return tDate.year == now.year && 
             tDate.month == now.month && 
             tDate.day == now.day;
    }).length + 1;

    return 'TXN-$dateStr-${todayCount.toString().padLeft(3, '0')}';
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
```

---

## 💸 Expense Service (Auto-Generation)

```dart
import '../models/expense.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/activity_log_service.dart';

class ExpenseService {
  final DatabaseService _db;
  final ActivityLogService _activityLog;

  ExpenseService(this._db, this._activityLog);

  Future<void> generatePrintExpenses({
    required Transaction transaction,
    required TransactionItem transactionItem,
    required PrintResourceConsumption resourceConsumption,
  }) async {
    final printService = await _db.getPrintService(transactionItem.productId);
    if (printService == null) return;

    final quantity = transactionItem.quantity;
    final breakdown = printService.costBreakdown;

    // Generate 4 expense records
    final expenses = [
      // Ink expense
      Expense(
        id: '${transaction.id}_ink_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Ink for ${transactionItem.productName} (${quantity} pages)',
        amount: breakdown.inkCostPerPage * quantity,
        category: ExpenseCategory.printing_ink,
        date: transaction.date,
        linkedTransactionId: transaction.id,
        source: ExpenseSource.auto_print,
      ),
      
      // Paper expense
      Expense(
        id: '${transaction.id}_paper_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Paper for ${transactionItem.productName} (${quantity} sheets)',
        amount: breakdown.paperCostPerPage * quantity,
        category: ExpenseCategory.printing_paper,
        date: transaction.date,
        linkedTransactionId: transaction.id,
        source: ExpenseSource.auto_print,
      ),
      
      // Electricity expense
      Expense(
        id: '${transaction.id}_elec_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Electricity for ${transactionItem.productName} (${quantity} pages)',
        amount: breakdown.electricityCostPerPage * quantity,
        category: ExpenseCategory.printing_electricity,
        date: transaction.date,
        linkedTransactionId: transaction.id,
        source: ExpenseSource.auto_print,
      ),
      
      // Maintenance expense
      Expense(
        id: '${transaction.id}_maint_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Maintenance for ${transactionItem.productName} (${quantity} pages)',
        amount: breakdown.maintenanceCostPerPage * quantity,
        category: ExpenseCategory.printing_maintenance,
        date: transaction.date,
        linkedTransactionId: transaction.id,
        source: ExpenseSource.auto_print,
      ),
    ];

    // Save all expenses
    for (var expense in expenses) {
      await _db.createExpense(expense);
    }

    // Log auto-expense generation
    await _activityLog.addLog(
      action: 'expense_created',
      description: 'Auto-generated ${expenses.length} print expenses for transaction ${transaction.transactionNumber}',
      performedBy: 'System',
      performedById: 'system',
      metadata: {
        'transactionId': transaction.id,
        'transactionNumber': transaction.transactionNumber,
        'totalExpenseAmount': expenses.fold(0.0, (sum, e) => sum + e.amount),
        'expenseCount': expenses.length,
      },
    );
  }
}
```

---

## 📊 Report Provider

```dart
import 'package:flutter/foundation.dart';
import '../models/financial_report.dart';
import '../models/transaction.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ReportProvider extends ChangeNotifier {
  final DatabaseService _db;

  ReportProvider(this._db);

  FinancialReport? _dailyReport;
  FinancialReport? _weeklyReport;
  FinancialReport? _monthlyReport;
  bool _isLoading = false;

  FinancialReport? get dailyReport => _dailyReport;
  FinancialReport? get weeklyReport => _weeklyReport;
  FinancialReport? get monthlyReport => _monthlyReport;
  bool get isLoading => _isLoading;

  Future<void> generateDailyReport([DateTime? date]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = targetDate.toIso8601String().split('T')[0];

      final transactions = await _db.getTransactionsByDate(dateStr);
      final expenses = await _db.getExpensesByDate(dateStr);

      final revenue = transactions.fold(0.0, (sum, t) => sum + t.total);
      final storeRevenue = transactions.fold(0.0, (sum, t) => sum + t.storeRevenue);
      final printingRevenue = transactions.fold(0.0, (sum, t) => sum + t.printingRevenue);
      final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
      final profit = revenue - totalExpenses;
      final profitMargin = revenue > 0 ? (profit / revenue) * 100 : 0;

      _dailyReport = FinancialReport(
        period: ReportPeriod.daily,
        startDate: dateStr,
        endDate: dateStr,
        metrics: DailyMetrics(
          revenue: revenue,
          storeRevenue: storeRevenue,
          printingRevenue: printingRevenue,
          expenses: totalExpenses,
          profit: profit,
          transactionCount: transactions.length,
          profitMargin: profitMargin,
        ),
        trendData: [],
        departmentRevenue: _calculateDepartmentRevenue(storeRevenue, printingRevenue),
        expensesByCategory: _calculateExpensesByCategory(expenses),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generateWeeklyReport([DateTime? endDate]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final end = endDate ?? DateTime.now();
      final start = end.subtract(const Duration(days: 6));

      final transactions = await _db.getTransactionsByDateRange(
        start.toIso8601String().split('T')[0],
        end.toIso8601String().split('T')[0],
      );
      
      final expenses = await _db.getExpensesByDateRange(
        start.toIso8601String().split('T')[0],
        end.toIso8601String().split('T')[0],
      );

      final revenue = transactions.fold(0.0, (sum, t) => sum + t.total);
      final storeRevenue = transactions.fold(0.0, (sum, t) => sum + t.storeRevenue);
      final printingRevenue = transactions.fold(0.0, (sum, t) => sum + t.printingRevenue);
      final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
      final profit = revenue - totalExpenses;

      // Generate trend data (one point per day)
      final trendData = <TrendDataPoint>[];
      for (var i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        final dayTransactions = transactions.where((t) => t.date.startsWith(dateStr));
        final dayExpenses = expenses.where((e) => e.date.startsWith(dateStr));
        
        final dayRevenue = dayTransactions.fold(0.0, (sum, t) => sum + t.total);
        final dayStoreRev = dayTransactions.fold(0.0, (sum, t) => sum + t.storeRevenue);
        final dayPrintRev = dayTransactions.fold(0.0, (sum, t) => sum + t.printingRevenue);
        final dayExp = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
        
        trendData.add(TrendDataPoint(
          date: '${date.month}/${date.day}',
          revenue: dayRevenue,
          storeRevenue: dayStoreRev,
          printingRevenue: dayPrintRev,
          expenses: dayExp,
          profit: dayRevenue - dayExp,
        ));
      }

      _weeklyReport = FinancialReport(
        period: ReportPeriod.weekly,
        startDate: start.toIso8601String().split('T')[0],
        endDate: end.toIso8601String().split('T')[0],
        metrics: WeeklyMetrics(
          revenue: revenue,
          storeRevenue: storeRevenue,
          printingRevenue: printingRevenue,
          expenses: totalExpenses,
          profit: profit,
          dailyAverage: revenue / 7,
        ),
        trendData: trendData,
        departmentRevenue: _calculateDepartmentRevenue(storeRevenue, printingRevenue),
        expensesByCategory: _calculateExpensesByCategory(expenses),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  List<DepartmentRevenue> _calculateDepartmentRevenue(
    double storeRevenue,
    double printingRevenue,
  ) {
    final total = storeRevenue + printingRevenue;
    
    return [
      DepartmentRevenue(
        name: 'Store',
        value: storeRevenue,
        percentage: total > 0 ? (storeRevenue / total) * 100 : 0,
        color: '#3b82f6', // Blue
      ),
      DepartmentRevenue(
        name: 'Printing',
        value: printingRevenue,
        percentage: total > 0 ? (printingRevenue / total) * 100 : 0,
        color: '#a855f7', // Purple
      ),
    ];
  }

  List<ExpenseByCategory> _calculateExpensesByCategory(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    
    for (var expense in expenses) {
      categoryTotals[expense.category.toString()] = 
        (categoryTotals[expense.category.toString()] ?? 0) + expense.amount;
    }

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return categoryTotals.entries.map((entry) {
      return ExpenseByCategory(
        category: entry.key,
        amount: entry.value,
        percentage: total > 0 ? (entry.value / total) * 100 : 0,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
```

---

## 🎨 UI Examples

### Dashboard Screen
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    // Calculate today's metrics
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayTransactions = transactionProvider.transactions
      .where((t) => t.date.startsWith(today))
      .toList();
    
    final revenue = todayTransactions.fold(0.0, (sum, t) => sum + t.total);
    final storeRevenue = todayTransactions.fold(0.0, (sum, t) => sum + t.storeRevenue);
    final printingRevenue = todayTransactions.fold(0.0, (sum, t) => sum + t.printingRevenue);
    
    final todayExpenses = expenseProvider.expenses
      .where((e) => e.date.startsWith(today))
      .toList();
    final expenses = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final profit = revenue - expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${auth.currentUser?.name}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            
            // Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: "Today's Revenue",
                  value: '₱${revenue.toStringAsFixed(2)}',
                  subtitle: '${todayTransactions.length} transactions',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                _MetricCard(
                  title: 'Store Revenue',
                  value: '₱${storeRevenue.toStringAsFixed(2)}',
                  subtitle: 'Sari-sari sales',
                  icon: Icons.store,
                  color: Colors.blue,
                ),
                _MetricCard(
                  title: 'Printing Revenue',
                  value: '₱${printingRevenue.toStringAsFixed(2)}',
                  subtitle: 'Printing services',
                  icon: Icons.print,
                  color: Colors.purple,
                ),
                if (auth.isOwner)
                  _MetricCard(
                    title: "Today's Profit",
                    value: '₱${profit.toStringAsFixed(2)}',
                    subtitle: '${((profit / revenue) * 100).toStringAsFixed(1)}% margin',
                    icon: Icons.trending_up,
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Permission Check Widget
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OwnerOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const OwnerOnly({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.isOwner) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

// Usage:
// OwnerOnly(
//   child: ElevatedButton(
//     onPressed: () => _editProduct(),
//     child: const Text('Edit'),
//   ),
// )
```

---

## 🧪 Testing Examples

### Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yourapp/providers/transaction_provider.dart';

void main() {
  group('Transaction Calculations', () {
    test('calculates department revenue correctly', () {
      final provider = TransactionProvider(mockDb, mockExpense, mockLog);
      
      // Add store item
      provider.addToCart(
        product: Product(..., category: ProductCategory.store),
        inventory: InventoryItem(..., retailPrice: 50),
        quantity: 2,
      );
      
      // Add print item
      provider.addToCart(
        product: Product(..., category: ProductCategory.printing),
        inventory: InventoryItem(..., retailPrice: 10),
        quantity: 5,
      );
      
      expect(provider.cartStoreRevenue, 100); // 50 * 2
      expect(provider.cartPrintingRevenue, 50); // 10 * 5
      expect(provider.cartSubtotal, 150);
    });
    
    test('generates correct transaction number', () {
      // Test implementation
    });
  });
}
```

---

## 🔧 Utility Functions

### Currency Formatter
```dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }
}

// Usage:
// Text(CurrencyFormatter.format(1234.56)) // ₱1,234.56
```

### Role Permission Checker
```dart
class PermissionChecker {
  static bool canAccessProductManagement(User user) {
    return user.role == UserRole.owner;
  }

  static bool canAccessFinancialReports(User user) {
    return user.role == UserRole.owner;
  }

  static bool canEditInventory(User user) {
    return user.role == UserRole.owner;
  }

  static bool canEditExpenses(User user, Expense expense) {
    return user.role == UserRole.owner && 
           expense.source == ExpenseSource.manual;
  }

  static bool canDeleteExpense(User user, Expense expense) {
    return user.role == UserRole.owner && 
           expense.source == ExpenseSource.manual;
  }
}
```

---

**These examples should help you implement the core features. Adapt them to match your existing Flutter code structure!**
