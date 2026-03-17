# 📊 Visual Summary - POS System Architecture

Quick visual reference for understanding the system architecture.

---

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     DUAL BUSINESS POS SYSTEM                    │
│                                                                 │
│  🏪 Sari-Sari Store          +          🖨️ Printing Services   │
└────────────────────────────────────────────────────────────────┘
                               │
                               ▼
        ┌──────────────────────────────────────────┐
        │        UNIFIED TRANSACTION SYSTEM         │
        │                                           │
        │  One cart can contain:                   │
        │  • Store items (Coca Cola, Noodles...)   │
        │  • Print services (A4 B&W, Color...)     │
        │                                           │
        │  Auto-calculates:                        │
        │  • Store Revenue                         │
        │  • Printing Revenue                      │
        │  • Total Cost                            │
        │  • Gross Profit                          │
        └──────────────────────────────────────────┘
```

---

## 👥 User Roles & Permissions

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER ROLES                              │
├─────────────────────────┬───────────────────────────────────────┤
│       👨‍💼 OWNER          │         👨‍💻 CASHIER                  │
├─────────────────────────┼───────────────────────────────────────┤
│ ✅ All POS Operations   │ ✅ POS Operations                     │
│ ✅ Product Management   │ ✅ View Inventory (read-only)         │
│ ✅ User Management      │ ✅ View Activity Logs                 │
│ ✅ Expense Management   │ ❌ Cannot Edit Products               │
│ ✅ Financial Reports    │ ❌ Cannot Manage Users                │
│ ✅ Inventory Editing    │ ❌ Cannot Edit Expenses               │
│ ✅ Activity Logs        │ ❌ Cannot View Financial Reports      │
│ ✅ Everything!          │ ❌ Cannot Edit Inventory              │
└─────────────────────────┴───────────────────────────────────────┘
```

---

## 🛒 Transaction Flow

```
┌─────────────┐
│   USER      │
│  ADDS ITEMS │
│  TO CART    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│              SHOPPING CART               │
│                                          │
│  2x Coca Cola (Store)          ₱90.00   │
│  1x White Bread (Store)        ₱50.00   │
│  10x A4 B&W Print (Printing)   ₱50.00   │
│  5x Color Print (Printing)     ₱50.00   │
│                                          │
│  Subtotal:                     ₱240.00  │
│  Tax:                           ₱0.00   │
│  Discount:                      ₱0.00   │
│  ─────────────────────────────────────  │
│  TOTAL:                        ₱240.00  │
└─────────────────────────────────────────┘
       │
       ▼  [CHECKOUT]
       │
       ├─────────────────────────────────────────┐
       │                                         │
       ▼                                         ▼
┌──────────────────┐                   ┌─────────────────┐
│   CREATE         │                   │   CALCULATE     │
│   TRANSACTION    │                   │   REVENUES      │
│                  │                   │                 │
│ • ID, Number     │                   │ Store:   ₱140  │
│ • Items[]        │                   │ Printing: ₱100 │
│ • Total: ₱240    │                   │ Total:   ₱240  │
│ • Date           │                   └─────────────────┘
│ • Cashier        │
│ • Payment        │
└────────┬─────────┘
         │
         ├────────────────────────────────┐
         │                                │
         ▼                                ▼
┌─────────────────┐            ┌──────────────────────┐
│   DEDUCT        │            │   AUTO-GENERATE      │
│   INVENTORY     │            │   PRINT EXPENSES     │
│                 │            │                      │
│ Coca Cola:      │            │ For 10x A4 B&W:      │
│   50 → 48       │            │  • Ink: ₱20          │
│                 │            │  • Paper: ₱10        │
│ White Bread:    │            │  • Electricity: ₱2   │
│   20 → 19       │            │  • Maintenance: ₱3   │
│                 │            │                      │
│ (Print services │            │ For 5x Color:        │
│  don't have     │            │  • Ink: ₱15          │
│  inventory)     │            │  • Paper: ₱5         │
└────────┬────────┘            │  • Electricity: ₱1   │
         │                     │  • Maintenance: ₱2   │
         │                     │                      │
         │                     │ Total: ₱58 expenses  │
         │                     └──────────┬───────────┘
         │                                │
         ├────────────────────────────────┤
         │                                │
         ▼                                ▼
┌──────────────────────────────────────────────────┐
│              LOG ACTIVITIES                       │
│                                                   │
│ • Transaction Created (₱240)                     │
│ • Inventory Deducted (Coca Cola: -2)            │
│ • Inventory Deducted (White Bread: -1)          │
│ • 8 Auto-Expenses Generated (₱58)               │
└───────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│              PROFIT CALCULATION                   │
│                                                   │
│ Revenue:           ₱240.00                       │
│ Total Cost:        ₱100.00 (store cost + print)  │
│ ─────────────────────────────────────────────    │
│ Gross Profit:      ₱140.00                       │
│ Profit Margin:     58.3%                         │
└───────────────────────────────────────────────────┘
```

---

## 🖨️ Print Service Magic

```
┌────────────────────────────────────────────────────────────┐
│                  PRINT SERVICE DEFINITION                  │
├────────────────────────────────────────────────────────────┤
│  Name: A4 Black & White Printing                          │
│  Paper Size: A4                                           │
│  Color Mode: Black & White                                │
│  Base Price: ₱5.00 per page (what customer pays)         │
│                                                            │
│  Cost Breakdown (per page):                               │
│  • Ink/Toner:        ₱2.00                                │
│  • Paper:            ₱1.00                                │
│  • Electricity:      ₱0.20                                │
│  • Maintenance:      ₱0.30                                │
│  ─────────────────────────                                │
│  • Total Cost:       ₱3.50 per page                       │
│                                                            │
│  Profit per page:    ₱1.50 (30% margin)                   │
└────────────────────────────────────────────────────────────┘
                        │
                        ▼ Customer orders 10 pages
                        │
┌───────────────────────────────────────────────────────────┐
│                   RESOURCE CONSUMPTION                     │
├────────────────────────────────────────────────────────────┤
│  Quantity: 10 pages                                       │
│                                                            │
│  Resources Used:                                          │
│  • Ink Used: 5% (calculated based on B&W mode)            │
│  • Paper Used: 10 sheets                                  │
│  • Electricity: 0.01 kWh                                  │
│                                                            │
│  Total Cost: ₱35.00 (10 × ₱3.50)                          │
└────────────────────────────────────────────────────────────┘
                        │
                        ▼ Auto-generate expenses
                        │
┌────────────────────────────────────────────────────────────┐
│              4 AUTO-GENERATED EXPENSE RECORDS              │
├────────────────────────────────────────────────────────────┤
│  1️⃣ Ink Expense                                            │
│     • Amount: ₱20.00 (10 × ₱2.00)                         │
│     • Category: printing_ink                              │
│     • Source: auto_print                                  │
│     • Linked to Transaction #TXN-20260317-001             │
│                                                            │
│  2️⃣ Paper Expense                                          │
│     • Amount: ₱10.00 (10 × ₱1.00)                         │
│     • Category: printing_paper                            │
│     • Source: auto_print                                  │
│     • Linked to Transaction #TXN-20260317-001             │
│                                                            │
│  3️⃣ Electricity Expense                                    │
│     • Amount: ₱2.00 (10 × ₱0.20)                          │
│     • Category: printing_electricity                      │
│     • Source: auto_print                                  │
│     • Linked to Transaction #TXN-20260317-001             │
│                                                            │
│  4️⃣ Maintenance Expense                                    │
│     • Amount: ₱3.00 (10 × ₱0.30)                          │
│     • Category: printing_maintenance                      │
│     • Source: auto_print                                  │
│     • Linked to Transaction #TXN-20260317-001             │
│                                                            │
│  📊 Total Auto-Expenses: ₱35.00                            │
└────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────────┐
│                    PROFIT CALCULATION                      │
├────────────────────────────────────────────────────────────┤
│  Revenue (Customer Paid):    ₱50.00 (10 × ₱5.00)         │
│  Total Cost (Resources):     ₱35.00                        │
│  ─────────────────────────────────────────────────────     │
│  Gross Profit:               ₱15.00                        │
│  Profit Margin:              30%                           │
└────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Database Schema (Simplified View)

```
┌──────────────┐         ┌───────────────┐         ┌──────────────┐
│    USERS     │         │   CUSTOMERS   │         │   PRODUCTS   │
├──────────────┤         ├───────────────┤         ├──────────────┤
│ • id         │         │ • id          │         │ • id         │
│ • username   │         │ • name        │         │ • name       │
│ • role       │         │ • email       │         │ • category   │
│ • name       │         │ • phone       │         │ • price      │
│ • phone      │         │ • address     │         │ • stock      │
│ • address    │         └───────────────┘         └──────────────┘
└──────────────┘                                            │
       │                                                    │
       │ creates                                            │ has
       ▼                                                    ▼
┌─────────────────────────────────────────────────┐  ┌─────────────┐
│                 TRANSACTIONS                     │  │  INVENTORY  │
├──────────────────────────────────────────────────┤  ├─────────────┤
│ • id                                             │  │ • id        │
│ • transactionNumber                              │  │ • productId │
│ • items[]                                        │  │ • stock     │
│ • total                                          │  │ • price     │
│ • cashierId ────────────────────────────────────►│  │ • location  │
│ • customerId (optional)                          │  └─────────────┘
│ • storeRevenue    ◄── CRITICAL                   │
│ • printingRevenue ◄── CRITICAL                   │
│ • totalCost                                      │
│ • grossProfit                                    │
└──────────────────────────────────────────────────┘
       │
       │ contains
       ▼
┌─────────────────────────────────────────────────┐
│              TRANSACTION ITEMS                   │
├──────────────────────────────────────────────────┤
│ • id                                             │
│ • transactionId                                  │
│ • productId                                      │
│ • quantity                                       │
│ • unitPrice                                      │
│ • category (store | printing)                    │
│ • printResourceConsumption (if printing)         │
│ • itemCost                                       │
└──────────────────────────────────────────────────┘
       │
       │ generates (if printing)
       ▼
┌─────────────────────────────────────────────────┐
│                  EXPENSES                        │
├──────────────────────────────────────────────────┤
│ • id                                             │
│ • description                                    │
│ • amount                                         │
│ • category (printing_ink, etc.)                  │
│ • source (manual | auto_print) ◄── CRITICAL     │
│ • linkedTransactionId (if auto)                  │
└──────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│             PRINT SERVICES                       │
├──────────────────────────────────────────────────┤
│ • id                                             │
│ • name                                           │
│ • paperSize                                      │
│ • colorMode                                      │
│ • basePrice ◄── Customer pays this               │
│ • costBreakdown:                                 │
│   - inkCostPerPage                               │
│   - paperCostPerPage                             │
│   - electricityCostPerPage                       │
│   - maintenanceCostPerPage                       │
│   - totalCostPerPage ◄── Actual cost             │
└──────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│             ACTIVITY LOGS                        │
├──────────────────────────────────────────────────┤
│ • id                                             │
│ • action                                         │
│ • description                                    │
│ • timestamp                                      │
│ • performedBy                                    │
│ • performedById ────────────────────────────────►│
│ • metadata (JSON)                                │
└──────────────────────────────────────────────────┘
```

---

## 📱 App Screens Hierarchy

```
┌──────────────────────────────────────────────────┐
│                 LOGIN SCREEN                      │
│                                                   │
│  Username: ___________                           │
│  Password: ___________                           │
│  [Login Button]                                  │
└──────────────────────────────────────────────────┘
                    │
                    ▼ (after login)
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
   ┌─────────┐          ┌──────────┐
   │  OWNER  │          │ CASHIER  │
   └─────────┘          └──────────┘
        │                       │
        ▼                       ▼

┌───────────────────────────────────────────────────────────┐
│                      MAIN APP                             │
│  ┌──────────────┐  ┌─────────────────────────────────┐   │
│  │   SIDEBAR    │  │      MAIN CONTENT AREA          │   │
│  │              │  │                                  │   │
│  │ [Profile]    │  │  Selected Screen Displays Here  │   │
│  │              │  │                                  │   │
│  │ Dashboard    │  │                                  │   │
│  │ POS          │  │                                  │   │
│  │ Inventory    │  │                                  │   │
│  │ Reports ★    │  │                                  │   │
│  │ Products ★   │  │                                  │   │
│  │ Users ★      │  │                                  │   │
│  │ Expenses ★   │  │                                  │   │
│  │ Logs         │  │                                  │   │
│  │              │  │                                  │   │
│  │ [Logout]     │  │                                  │   │
│  └──────────────┘  └─────────────────────────────────┘   │
│                                                           │
│  ★ = Owner only                                          │
└───────────────────────────────────────────────────────────┘

INDIVIDUAL SCREENS:

1. 📊 Dashboard
   - Metric Cards (Revenue, Store, Printing, Profit)
   - Alerts (Low Stock, Expiring Items)

2. 💰 POS Interface
   - Product Catalog (Tabs: Store | Printing)
   - Shopping Cart
   - Checkout Modal

3. 📦 Inventory Management
   - Tabs: Store Products | Printing Supplies
   - Stock Levels
   - Edit Stock Modal (Owner)

4. 📈 Financial Reports (Owner)
   - Tabs: Daily | Weekly | Monthly
   - Metric Cards
   - Charts (Revenue Trend, Department Split, Expenses)

5. 🏷️ Product Management (Owner)
   - Tabs: Store Products | Print Services
   - Product List
   - Create/Edit Forms

6. 👥 User Management (Owner)
   - User List
   - Create/Edit User Form

7. 💸 Expense Tracking (Owner)
   - Expense List (Manual + Auto)
   - Create Expense Form
   - Edit Modal (Manual only)

8. 📋 Activity Logs
   - Chronological Log List
   - Filters (Action, User, Date)
```

---

## 💰 Department Revenue Tracking

```
┌────────────────────────────────────────────────────────────┐
│              TRANSACTION #TXN-20260317-001                 │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  STORE ITEMS:                                              │
│  • 2x Coca Cola @ ₱45        = ₱90.00                     │
│  • 1x White Bread @ ₱50      = ₱50.00                     │
│                                ─────────                   │
│  Store Revenue:                ₱140.00 ◄────┐             │
│                                              │             │
│  PRINTING ITEMS:                            │             │
│  • 10x A4 B&W @ ₱5           = ₱50.00       │             │
│  • 5x Color Print @ ₱10      = ₱50.00       │             │
│                                ─────────     │             │
│  Printing Revenue:             ₱100.00 ◄────┤             │
│                                              │             │
│  ════════════════════════════════════════    │             │
│  TOTAL TRANSACTION:            ₱240.00       │             │
│                                              │             │
│  Saved in Transaction record:                │             │
│  • total: ₱240.00                            │             │
│  • storeRevenue: ₱140.00   ──────────────────┘             │
│  • printingRevenue: ₱100.00 ───────────────────────────┐   │
└────────────────────────────────────────────────────────┼───┘
                                                         │
                     Used in Financial Reports           │
                                                         │
┌────────────────────────────────────────────────────────▼───┐
│                    FINANCIAL REPORT                        │
├────────────────────────────────────────────────────────────┤
│  Total Revenue:        ₱240.00                             │
│                                                            │
│  Department Breakdown:                                     │
│  ┌────────────────┐  ┌────────────────┐                  │
│  │  🏪 STORE      │  │  🖨️ PRINTING   │                  │
│  │  ₱140.00       │  │  ₱100.00       │                  │
│  │  58.3%         │  │  41.7%         │                  │
│  └────────────────┘  └────────────────┘                  │
│                                                            │
│  📊 Pie Chart:                                             │
│      [Store: 58.3%] [Printing: 41.7%]                     │
│                                                            │
│  Performance Comparison:                                   │
│  • Store contributed more this period                     │
│  • Printing growing trend                                 │
└────────────────────────────────────────────────────────────┘
```

---

## 🔐 Permission Matrix

```
┌────────────────────────────────────────────────────────────┐
│                    FEATURE PERMISSIONS                     │
├──────────────────────────┬─────────────┬───────────────────┤
│        FEATURE           │    OWNER    │     CASHIER       │
├──────────────────────────┼─────────────┼───────────────────┤
│ Dashboard                │     ✅      │       ✅          │
│ POS Interface            │     ✅      │       ✅          │
│ Create Transaction       │     ✅      │       ✅          │
│ View Inventory           │     ✅      │       ✅          │
│ Edit Inventory           │     ✅      │       ❌          │
│ Product Management       │     ✅      │       ❌          │
│ Print Service Mgmt       │     ✅      │       ❌          │
│ User Management          │     ✅      │       ❌          │
│ Create Users             │     ✅      │       ❌          │
│ Edit Users               │     ✅      │       ❌          │
│ Delete Users             │     ✅      │       ❌          │
│ Expense Tracking         │     ✅      │       ❌          │
│ Create Manual Expense    │     ✅      │       ❌          │
│ Edit Manual Expense      │     ✅      │       ❌          │
│ Delete Manual Expense    │     ✅      │       ❌          │
│ View Auto-Expenses       │     ✅      │       ❌          │
│ Financial Reports        │     ✅      │       ❌          │
│ Daily Report             │     ✅      │       ❌          │
│ Weekly Report            │     ✅      │       ❌          │
│ Monthly Report           │     ✅      │       ❌          │
│ Export Reports           │     ✅      │       ❌          │
│ Activity Logs            │     ✅      │       ✅ (view)   │
│ Export Logs              │     ✅      │       ❌          │
└──────────────────────────┴─────────────┴───────────────────┘

RULE: Always check user role before:
  1. Rendering UI elements
  2. Processing API requests
  3. Saving data changes
```

---

## 🧮 Calculation Formulas

```
┌────────────────────────────────────────────────────────────┐
│                    KEY CALCULATIONS                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1️⃣ CART SUBTOTAL                                          │
│     sum(each item.quantity × item.unitPrice)              │
│                                                            │
│  2️⃣ STORE REVENUE                                          │
│     sum(items where category = 'store')                   │
│                                                            │
│  3️⃣ PRINTING REVENUE                                       │
│     sum(items where category = 'printing')                │
│                                                            │
│  4️⃣ TOTAL COST (for profit calculation)                   │
│     • Store items:                                        │
│       sum(quantity × product.purchasePrice)               │
│     • Print items:                                        │
│       sum(quantity × service.costBreakdown.totalCost)     │
│                                                            │
│  5️⃣ GROSS PROFIT                                           │
│     total - totalCost                                     │
│                                                            │
│  6️⃣ PROFIT MARGIN                                          │
│     (grossProfit / total) × 100%                          │
│                                                            │
│  7️⃣ PRINT RESOURCE COST                                    │
│     quantity × (inkCost + paperCost + elecCost +          │
│                 maintenanceCost)                           │
│                                                            │
│  8️⃣ TRANSACTION NUMBER                                     │
│     "TXN-YYYYMMDD-XXX"                                    │
│     where XXX = count of today's transactions + 1         │
│                                                            │
│  9️⃣ DAILY PROFIT                                           │
│     sum(today's transactions.total) -                     │
│     sum(today's expenses.amount)                          │
│                                                            │
│  🔟 DEPARTMENT PERCENTAGE                                  │
│     (departmentRevenue / totalRevenue) × 100%             │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│                      DATA FLOW                           │
└──────────────────────────────────────────────────────────┘

USER ACTION ──► PROVIDER ──► SERVICE ──► DATABASE
                   │                         │
                   └──────── NOTIFY ◄────────┘
                              │
                              ▼
                          UI UPDATE


Example: Creating a Transaction

[User clicks Checkout]
       │
       ▼
[TransactionProvider.checkout()]
       │
       ├──► Calculate totals
       ├──► Calculate department revenues
       ├──► Process print items
       │    └──► Calculate resource consumption
       │
       ├──► [DatabaseService.createTransaction()]
       │    └──► Save to database
       │
       ├──► [ProductProvider.deductInventory()]
       │    └──► Update stock levels
       │
       ├──► [ExpenseService.generatePrintExpenses()]
       │    └──► Create 4 expense records
       │
       └──► [ActivityLogService.addLog()]
            └──► Record activity
       
       [notifyListeners()]
       │
       ▼
[UI rebuilds with new data]
```

---

## 🎯 Critical Data Integrity Rules

```
┌────────────────────────────────────────────────────────────┐
│              DATA INTEGRITY CONSTRAINTS                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. Transaction.total = storeRevenue + printingRevenue    │
│     ⚠️ MUST always be true                                │
│                                                            │
│  2. Auto-generated expenses CANNOT be edited              │
│     ⚠️ source = 'auto_print' → read-only                  │
│                                                            │
│  3. Every print transaction item MUST have:               │
│     • printResourceConsumption object                     │
│     • 4 linked expense records                            │
│     ⚠️ Check on checkout                                   │
│                                                            │
│  4. Inventory CANNOT go negative                          │
│     ⚠️ Validate before deduction                          │
│                                                            │
│  5. Transaction numbers MUST be unique                    │
│     ⚠️ Format: TXN-YYYYMMDD-XXX                           │
│                                                            │
│  6. All important actions MUST be logged                  │
│     ⚠️ Include user, timestamp, metadata                  │
│                                                            │
│  7. Cashiers CANNOT access owner-only features            │
│     ⚠️ Check role on both UI and API levels               │
│                                                            │
│  8. Auto-expenses MUST link to source transaction         │
│     ⚠️ linkedTransactionId must be set                    │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 🚨 Common Pitfalls (Visual)

```
❌ WRONG:
transaction.total = 240
transaction.storeRevenue = 0
transaction.printingRevenue = 0
⚠️ Department revenues not tracked!

✅ CORRECT:
transaction.total = 240
transaction.storeRevenue = 140
transaction.printingRevenue = 100
✓ Proper department tracking


❌ WRONG:
[Print transaction completed]
[No expenses generated]
⚠️ Costs not tracked, profit calculation wrong!

✅ CORRECT:
[Print transaction completed]
[4 auto-expenses created: ink, paper, elec, maint]
[All linked to transaction]
✓ Complete cost tracking


❌ WRONG:
expense.source = 'auto_print'
[User clicks Edit button]
[Expense modified]
⚠️ Auto-generated expense should be read-only!

✅ CORRECT:
expense.source = 'auto_print'
[Edit button is hidden/disabled]
[Cannot modify]
✓ Data integrity maintained


❌ WRONG:
if (user.role === 'cashier') {
  showProductManagement(); // In UI only
}
⚠️ Cashier can still call API directly!

✅ CORRECT:
// UI Check:
if (user.role === 'cashier') {
  hideProductManagement();
}
// API Check:
if (user.role !== 'owner') {
  throw PermissionDenied();
}
✓ Multi-layer security
```

---

This visual summary should help you quickly understand the system architecture and key concepts when implementing the Flutter version! 🚀
