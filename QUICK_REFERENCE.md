# Flutter Migration - Quick Reference Card

## 🎯 Core Concept
Dual business POS: **Sari-Sari Store + Printing Services** with unified transactions

## 🔑 Critical Business Rules

### 1. Transaction Flow
```
Cart → Can contain BOTH store + print items
↓
Checkout creates:
  ✅ Transaction record
  ✅ Inventory deductions (logged)
  ✅ Auto-expenses for print items (4 categories)
  ✅ Department revenue split (store/printing)
  ✅ Profit calculation (revenue - costs)
```

### 2. Print Service Magic ✨
```
Customer orders: 10 pages colored printing @ ₱10/page

Revenue: ₱100
Auto-generates 4 expense records:
  - Ink: ₱40 (printing_ink)
  - Paper: ₱20 (printing_paper)
  - Electricity: ₱5 (printing_electricity)
  - Maintenance: ₱5 (printing_maintenance)
Total Cost: ₱70
Gross Profit: ₱30
```

### 3. Department Revenue Tracking
Every transaction MUST calculate:
- `storeRevenue` = sum of store item subtotals
- `printingRevenue` = sum of print item subtotals
- `total` = storeRevenue + printingRevenue
- `totalCost` = sum of all item costs
- `grossProfit` = total - totalCost

### 4. Role Permissions
**Owner:**
- ✅ Everything (full access)

**Cashier:**
- ✅ POS operations
- ✅ View inventory (read-only)
- ✅ View activity logs
- ❌ Cannot manage products/users/expenses
- ❌ Cannot view financial reports

## 📊 Essential Data Relationships

```
Product (base definition)
  ↓
InventoryItem (has stock, retail price)
  ↓
TransactionItem (sold in transaction)
  ↓
Transaction (unified store + print sale)
  ↓
Auto-generates Expense records (for print items)
```

## 🗂️ Data Model Cheat Sheet

### Transaction
```typescript
{
  id, transactionNumber, items[], 
  subtotal, tax?, discount?, total,
  date, status, paymentMethod,
  cashierId, cashierName, customerId?,
  
  // CRITICAL FIELDS:
  storeRevenue: number,      // Store items total
  printingRevenue: number,   // Print items total
  totalCost?: number,        // Actual costs
  grossProfit?: number       // Profit margin
}
```

### TransactionItem
```typescript
{
  id, inventoryId, productId, productName,
  quantity, unitPrice, subtotal, category,
  
  // For PRINT items only:
  printResourceConsumption?: {
    inkUsed, paperUsed, electricityUsed,
    totalCost  // Actual cost incurred
  },
  itemCost?: number  // For profit calc
}
```

### PrintService
```typescript
{
  id, name, description,
  paperSize, colorMode, orientation?, finish?,
  basePrice,  // What customer pays
  
  // CRITICAL: Cost breakdown
  costBreakdown: {
    inkCostPerPage,
    paperCostPerPage,
    electricityCostPerPage,
    maintenanceCostPerPage,
    totalCostPerPage  // Sum of all
  },
  
  paperStock?, inkLevel?
}
```

### Expense
```typescript
{
  id, description, amount, category, date,
  
  // CRITICAL FIELDS:
  source: 'manual' | 'auto_print',  // Distinguish origin
  linkedTransactionId?: string      // For auto-generated
}

// Expense Categories:
// 'printing_ink', 'printing_paper', 'printing_electricity',
// 'printing_maintenance', 'store_inventory', 'utilities',
// 'rent', 'salaries', 'supplies', 'other'
```

## 🎨 UI Screens Priority Order

1. **Login** (authentication)
2. **Dashboard** (overview metrics)
3. **POS Interface** (core business function)
4. **Inventory Management** (view + edit stock)
5. **Product Management** (CRUD for products/services)
6. **Financial Reports** (daily/weekly/monthly)
7. **Expense Tracking** (manual + auto-generated)
8. **User Management** (CRUD users)
9. **Activity Logs** (audit trail)

## 🔐 Authentication Pattern

```dart
// Login flow
User? currentUser;

login(username, password) {
  // Find user from database
  // Verify password (hashed)
  // Set currentUser
  // Log LOGIN activity
  // Navigate to dashboard
}

logout() {
  // Log LOGOUT activity
  // Clear currentUser
  // Navigate to login
}
```

## 📝 Activity Logging Pattern

**Log everything:**
```dart
addLog(
  action: ActivityAction,  // e.g., 'transaction_created'
  description: "Detailed human-readable description",
  metadata: {
    // Relevant IDs, old/new values, etc.
  }
)

// Actions to log:
// - All transactions (created, cancelled, refunded)
// - Product changes (created, updated, deleted)
// - Inventory changes (added, updated, depleted)
// - User actions (created, updated, deleted, login, logout)
// - Expense changes (created, updated, deleted)
// - Customer changes (created, updated, deleted)
// - Print service changes (created, updated, deleted)
```

## 🚨 Alerts & Warnings

### Low Stock Alert
```dart
if (product.stock < 10) {
  // Show warning indicator
  // Display in dashboard alerts
}
```

### Expiration Warning
```dart
final daysUntilExpiry = calculateDays(product.expiryDate);
if (daysUntilExpiry <= 7 && daysUntilExpiry >= 0) {
  // Show warning indicator
  // Display in dashboard alerts
}
```

## 📈 Report Calculations

### Daily Metrics
```dart
final today = DateTime.now().toIso8601String().split('T')[0];
final todayTransactions = transactions.where((t) => t.date.startsWith(today));

revenue = sum(todayTransactions.map((t) => t.total));
storeRevenue = sum(todayTransactions.map((t) => t.storeRevenue));
printingRevenue = sum(todayTransactions.map((t) => t.printingRevenue));
expenses = sum(todayExpenses.map((e) => e.amount));
profit = revenue - expenses;
profitMargin = (profit / revenue) * 100;
```

### Weekly/Monthly Metrics
```dart
// Same as daily but with date range filtering
// Add trendData array for charts
// Add departmentRevenue breakdown (Store vs Printing pie chart)
// Add expensesByCategory breakdown (bar chart)
```

## 🎯 Print Job Processing

```dart
// When selling print service in POS:

1. Add print service to cart (like regular product)

2. On checkout, for each print item:
   a. Calculate resource consumption:
      - inkUsed = calculate based on colorMode & quantity
      - paperUsed = quantity
      - electricityUsed = estimate based on quantity
      - totalCost = quantity * service.costBreakdown.totalCostPerPage
   
   b. Create TransactionItem with printResourceConsumption
   
   c. Auto-generate 4 Expense records:
      - Ink expense (amount: quantity * inkCostPerPage)
      - Paper expense (amount: quantity * paperCostPerPage)
      - Electricity expense (amount: quantity * electricityCostPerPage)
      - Maintenance expense (amount: quantity * maintenanceCostPerPage)
   
   d. Link expenses to transaction (linkedTransactionId)
   
   e. Mark expenses as source: 'auto_print'

3. Calculate profit margin:
   revenue = quantity * service.basePrice
   cost = totalCost (from resourceConsumption)
   profit = revenue - cost
```

## 🗄️ Recommended Packages

```yaml
dependencies:
  # State Management
  provider: ^6.0.0  # or riverpod
  
  # Database
  supabase_flutter: ^2.0.0  # Cloud option
  # OR
  sqflite: ^2.3.0           # Local option
  
  # UI Components
  fl_chart: ^0.66.0         # Charts
  
  # Utils
  intl: ^0.18.0             # Date/number formatting
  uuid: ^4.0.0              # ID generation
  
  # Printing
  printing: ^5.11.0         # Receipt printing
  pdf: ^3.10.0              # PDF generation
  
  # Serialization
  json_annotation: ^4.8.0
  
  # Optional
  barcode_scan2: ^4.2.0     # Barcode scanning
  shared_preferences: ^2.2.0 # Local storage
```

## 🎨 Currency Formatting

```dart
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat.currency(
  locale: 'en_PH',
  symbol: '₱',
  decimalDigits: 2,
);

// Usage:
currencyFormatter.format(1234.56); // "₱1,234.56"
```

## 🏗️ Project Structure

```
lib/
├── models/          # Data models (match /lib/types/)
│   ├── user.dart
│   ├── product.dart
│   ├── transaction.dart
│   ├── expense.dart
│   └── ...
├── providers/       # State management
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── transaction_provider.dart
│   └── ...
├── screens/         # UI screens
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── pos_screen.dart
│   └── ...
├── widgets/         # Reusable components
│   ├── product_card.dart
│   ├── cart_item.dart
│   └── ...
├── services/        # API/Database layer
│   ├── database_service.dart
│   ├── auth_service.dart
│   └── ...
└── utils/           # Helper functions
    ├── constants.dart
    ├── formatters.dart
    └── ...
```

## ⚠️ Common Pitfalls to Avoid

1. ❌ **Don't** mix store and printing revenue in totals
   - ✅ **Always** track separately in `storeRevenue` and `printingRevenue`

2. ❌ **Don't** forget to generate auto-expenses for print jobs
   - ✅ **Always** create 4 expense records (ink, paper, electricity, maintenance)

3. ❌ **Don't** allow cashiers to edit products/expenses
   - ✅ **Always** check user role before showing edit options

4. ❌ **Don't** forget to log activities
   - ✅ **Always** log important actions with metadata

5. ❌ **Don't** allow editing auto-generated expenses
   - ✅ **Only** allow editing expenses with `source: 'manual'`

6. ❌ **Don't** forget to deduct inventory on transaction
   - ✅ **Always** update stock after successful checkout

7. ❌ **Don't** use simple counters for transaction numbers
   - ✅ **Always** use format: `TXN-YYYYMMDD-XXX`

## 🧪 Test Scenarios

### Critical Path Test
1. Login as Owner
2. Add store product (Coca Cola, stock: 50)
3. Add print service (A4 BW, ₱5/page, cost: ₱3/page)
4. Go to POS
5. Add 2 Coca Cola + 10 pages printing to cart
6. Checkout
7. Verify:
   - ✅ Inventory: Coca Cola stock now 48
   - ✅ Transaction: storeRevenue = Coca Cola total, printingRevenue = print total
   - ✅ Expenses: 4 new auto-generated expenses (total ₱30)
   - ✅ Activity Log: Transaction logged + inventory deduction logged
   - ✅ Dashboard: Revenue updated, profit calculated correctly

### Permission Test
1. Login as Cashier
2. Verify:
   - ✅ Can access POS
   - ✅ Can view inventory (no edit buttons)
   - ❌ Cannot access Products menu
   - ❌ Cannot access Users menu
   - ❌ Cannot access Expenses menu
   - ❌ Cannot access Reports menu

## 📞 When in Doubt

1. Check `/lib/types/` for exact TypeScript type definitions
2. Check `/docs/database-erd.md` for relationships
3. Check `/components/` React code for business logic examples
4. Reference `/FLUTTER_MIGRATION_INSTRUCTIONS.md` for detailed explanations

**Remember:** Preserve existing Flutter code that's better than React version!
