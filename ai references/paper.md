# PrintSari Corner System Design

**Authors:** Dulaugon, Lupase, Pacanza
**Adviser:** Mr. Rodwell Matchon
**Panelists:** Mr. Dwight Ian De Jesus, Mr. Antonio Bulao II
**Date:** November 2025
**Location:** Purok 5 RVM, Poblacion, Magpet, North Cotabato

---

## Preliminary Investigation Report

### Organization Details

**Business Name:** PrintSari Corner
**Address:** Purok 5 RVM, Poblacion, Magpet, North Cotabato
**Type:** Hybrid retail — sari-sari store + printing and document services

### Brief History

PrintSari Corner is a small community business combining a sari-sari store (convenience goods retail) with a printing and document services shop. The business serves the local community in Magpet, offering everyday consumer products alongside printing, photocopying, and lamination services.

### Business Process (As-Is)

1. **Sales** — Cashier manually records each sale (store products or printing services) on paper or basic spreadsheets.
2. **End-of-Day** — Owner manually tallies daily sales, counts inventory, and computes profit/loss.
3. **Inventory** — Stock levels tracked manually; restocking decisions made based on visual inspection.
4. **Expenses** — Business costs recorded in a notebook; no automatic linking to inventory purchases.

### Identified Problems

1. Manual recording leads to arithmetic errors in daily sales totals.
2. No real-time inventory visibility — stock-outs go undetected until a customer requests an item.
3. No structured expense tracking; business costs are not linked to inventory restocking.
4. No role-based access — any staff member can access all records.
5. No historical reporting; business performance can only be assessed manually from paper records.

---

## Events Table

| Event | Actor | Description |
|---|---|---|
| **Product Management** | Owner | Add, update, or delete store products with pricing, category, SKU, and supplier details |
| **Service Management** | Owner | Create and configure printing services (base service, paper size, color mode, machine assignment) |
| **Service Supply Management** | Owner | Add and manage printing supply records (paper, toner, lamination film) with purchase prices |
| **Sales Transaction** | Cashier / Owner | Process customer orders through POS — add items, compute total, record payment, update inventory |
| **Product Inventory Management** | Owner | Record stock-in for store products; track current quantity and expiry dates |
| **Service Supply Inventory Management** | Owner | Record stock-in for printing supplies; deduct supply on every service transaction |
| **Financial Reporting** | Owner | Generate daily, monthly, and yearly reports with revenue, expenses, profit breakdown, and export |
| **Expense Management** | Owner | Record business expenses by category; link expenses to inventory stock-in records |
| **User Management** | Owner | Create, update, activate/deactivate cashier accounts; view login history |

---

## Use Case List

### Sales Transaction System

A point-of-sale system for processing customer purchases. Both store products and printing services are handled in a single transaction. The system deducts inventory on checkout and records all items.

**Use Cases:**
- **Add New Transaction** — Cashier opens a new order and adds products/services to the cart
- **Edit Transaction Items** — Modify quantities or remove items before checkout
- **Process Transaction** — Confirm order and enter payment; system calculates total and change
- **Calculate Transaction Total** — System sums all cart items including any service page counts
- **Generate Receipt** — System produces a transaction summary on checkout
- **Record Transaction** — System saves transaction and all line items to the database
- **Deduct Inventory Stock** — System reduces inventory quantities for all sold items
- **View Transaction History** — Browse past transactions by date

### Dual Inventory Management System

Tracks two separate inventory streams: store product stock and printing service supply stock. Both are decremented by sales and restocked via stock-in records linked to expense entries.

**Use Cases (Product Inventory):**
- **Product Stock In** — Record new stock arrival; creates an Inventory_Item record
- **Create Inventory Item** — System creates a stock entry linked to the product and stock-in record
- **Link Stock to Expense** — Associate stock-in with an expense record for cost tracking
- **View Product Inventory** — Display all product stock levels with expiry dates
- **Adjust Product Quantity** — Manual stock correction
- **Deduct Product Inventory Every Transaction** — Automatic deduction on each sale
- **Track Product Expiry** — Flag items approaching or past their expiry date

**Use Cases (Service Supply Inventory):**
- **Service Supply Stock In** — Record printing supply replenishment
- **Create Service Supply Inventory Item** — System creates a supply inventory entry
- **Link Service Supply to Expense** — Connect supply purchase to expense record
- **View Service Supply Inventory** — Display current supply quantities
- **Adjust Service Supply Quantity** — Manual quantity correction
- **Deduct Service Supply on Every Service Transaction** — Automatic supply deduction on printing sales

### Financial Reporting System

Aggregates transaction and expense data into daily, monthly, and yearly reports. Computes store revenue, printing revenue, total expenses, and net profit.

**Use Cases:**
- **Generate Daily Reports** — Create Daily_Sales_Report with aggregated revenue, expenses, profit, net profit, and transaction count
- **Record Daily Transactions** — Generate Daily_Transaction records for each sale with revenue and profit breakdown
- **Generate Monthly Reports** — Produce Monthly_Report aggregating daily reports with month/year totals, averages, and transaction counts
- **Generate Yearly Reports** — Create Yearly_Report aggregating monthly data with annual totals, best/worst months, and monthly averages
- **View Daily Performance** — Display daily sales summaries with revenue and expense breakdown by date
- **View Monthly Performance** — Show monthly business performance comparing store and printing revenues across months
- **View Yearly Performance** — Display annual business reports with monthly comparisons and trend analysis
- **Export Reports** — Generate PDF/Excel files from Daily, Monthly, or Yearly reports for external use
- **Record Business Expenses** — Enter and track business costs with category, description, amount, and date
- **Link Expenses to Purchases** — Connect expense records to Stock_In records for inventory cost tracking
- **Calculate Net Profit** — Compute net profit by subtracting total expenses from transaction profit
- **Track Expense Categories** — Categorize expenses (utilities, supplies, maintenance, etc.) for detailed analysis

### Product and Service Management System

A comprehensive management system for maintaining product catalog and service offerings. The Product module handles store items with categories, types, purchase prices, selling prices, and profit margins. The Service module manages printing services through a three-tier structure: Service (base service), Service_Type (specific variants with paper size and color mode linked to Service_Supply and Machine), and Service_Type_Cost (detailed cost breakdown including supply cost, ink cost, electricity cost, labor cost, total cost, and selling price). Changes reflect immediately in the POS system.

**Use Cases:**
- **Manage Store Products** — Add, update, or remove products with category, type, purchase price, selling price, and profit calculation
- **View Product Catalog** — Display all products with detailed information and current inventory status
- **Manage Services** — Create and configure base printing services (xerox, printing, lamination)
- **Manage Service Types** — Define service variants linking Service, Service_Supply, Machine with specifications (paper size, color mode)
- **Manage Service Type Costs** — Configure detailed cost components (supply, ink, electricity, labor) and set selling prices
- **Update Product Pricing** — Modify product purchase prices and selling prices with automatic profit recalculation
- **Update Service Rates** — Adjust service type costs and selling prices with last updated timestamp
- **Configure Service Supplies** — Add and manage printing supplies (paper types, toner, lamination film) with purchase prices
- **Assign Machines to Services** — Link machines to services and manage active/inactive status
- **Track Service Profitability** — Calculate service profit margins from cost breakdown and selling prices

### User Management System

A role-based access control system that manages user authentication, permissions, and activity tracking. Two user roles: Owner (full access) and Cashier (restricted to POS and view-only inventory). Login_History table tracks all user sessions.

**Use Cases:**
- **Create User Account** — Add new user with username, password, personal info, role assignment, and address details
- **Assign User Role** — Set role-based access levels (Owner vs. Cashier)
- **Manage User Address** — Create and link Address records to users with complete location details
- **Update User Information** — Modify user credentials, personal details, contact info, and profile picture
- **Activate/Deactivate User** — Set user isActive status to enable or disable account access
- **View User Accounts** — Display all system users with roles, status, creation info, and contact details
- **Authenticate User** — Validate login credentials and create Login_History record with login timestamp
- **Track User Sessions** — Record all login and logout events with timestamps in Login_History table
- **End User Session** — Process logout and update Login_History with logout timestamp
- **Track User Actions** — Link user activities (transactions, stock movements, expense records) to userID
- **View Login History** — Display user session history with login/logout times for activity monitoring

---

## Use Case Diagrams

### A. Sales Transaction

```
[Cashier/Owner]
  ├── Add new transaction ──«include»──► Process transaction ──«include»──► Calculate transaction total
  │                                           │                                      │
  │         Edit transaction items ──«extend»─┘                          «include»──► Deduct inventory stock
  │                                           │                                      │
  ├── Generate receipt ◄──«include»───────────┘              Record transaction ◄──«include»──┘
  └── View transaction history
```

### B. Product and Service Management

```
[Owner]
  ├── View and search store products and printing services
  ├── Add store product or printing service ──«include»──► Input store product/printing service details ──«extend»──► (view)
  ├── Update store product or printing service details ──«include»──► (same input form)
  └── Remove store product or printing service
```

### C. User Management

```
[Owner]
  ├── Create user account ──«include»──► Assign user role
  │         └──«include»──► Input user information ◄──«include»── Update user information
  ├── Update user information ──«extend»──► Deactivate User Account
  ├── View user accounts ──«extend»──► Delete User Account
  ├── Login
  ├── Logout
  └── View Login History
```

### D. Financial Reporting

```
[Owner]
  ├── View monthly report ──«include»──► Generate Daily Report ──«include»──► Generate Daily Transactions
  ├── View weekly report  ──«include»──► Export report; Generate Monthly Report
  ├── View daily report   ──«include»──► Generate Yearly Report
  │         └──«extend»──► Record business expense ──«extend»──► Edit business expense item
  │                                                 └──«extend»──► Delete business expense item
  └── Export Report
```

### E. Service Supply Inventory Management

```
[Owner]
  ├── Service Supply Stock In ──«include»──► Create Service Supply Inventory Item
  │                                                   Deduct Service Supply on every Service Transaction
  ├── Link Service Supply to Expense
  └── View Service Supply Inventory ──«extend»──► Adjust Service Supply Quantity
```

### F. Product Inventory Management

```
[Owner]
  ├── Product Stock In ──«include»──► Create Inventory Item
  ├── Link Stock to Expense
  └── View Product Inventory ──«extend»──► Adjust Product Quantity
                              ──«extend»──► Deduct Product Inventory Every Transaction
                              ──«extend»──► Track Product Expiry
```

### G. Service Supply Management

```
[Owner]
  ├── View Service Supplies ──«extend»──► (Add New Supply)
  ├── Add New Supply ──«extend»──► (View Service Supplies)
  └── Update Supply Details ──«extend»──► (View Service Supplies)
```

### H. Expense Management

```
[Owner]
  ├── Record Business Expense ──«include»──► Categorize Expense
  │         └──«extend»──► Link Expense to Stock In
  └── View Expense History
```

---

## Use Case Descriptions

### 3.1 Sales Transaction

| Field | Description |
|---|---|
| **Use Case Name** | Process Sales Transaction |
| **Scenario** | Cashier records the customer's order and processes the payment |
| **Triggering Event** | Cashier inputs orders in the POS |
| **Brief Description** | Cashier lists ordered products/services in the POS. The system computes the total and records the transaction. |
| **Actors** | Cashier, Customer |
| **Related Use Case** | Product Inventory Management, Service Supply Inventory Management |
| **Preconditions** | Products and services must exist in the system |
| **Postconditions** | Transaction details are saved; inventory is updated |
| **Flow of Activities** | **Actor:** 1. Cashier lists orders in the POS. 2. Confirms order and enters payment. **System:** 1.1 System checks stock availability. 1.2 The system computes the total and records the payment. 1.3 System updates the inventory and saves the transaction. |
| **Exception Conditions** | If the stock is unavailable, the system notifies the cashier to remove or replace the item. |

### 3.2 Product and Service Management

| Field | Description |
|---|---|
| **Use Case Name** | Manage Products and Services |
| **Scenario** | Owner updates product or service details |
| **Triggering Event** | Owner edits data in the management panel |
| **Brief Description** | The owner can add, update, or remove product and service records |
| **Actors** | Owner |
| **Related Use Case** | Product Inventory Management, Service Supply Management |
| **Preconditions** | The system must contain product and service tables |
| **Postconditions** | Product and service lists are updated |
| **Flow of Activities** | **Actor:** 1. Owner selects product/service to edit. 2. Owner saves changes. **System:** 1.1 Updates the database record. 1.2 Displays confirmation. |
| **Exception Conditions** | If a duplicate product/service name is detected, the system prompts an error. |

### 3.3 User Management

| Field | Description |
|---|---|
| **Use Case Name** | Manage User Accounts |
| **Scenario** | The owner adds or modifies user access |
| **Triggering Event** | The owner creates or updates the user record |
| **Brief Description** | The owner can add, edit, or deactivate user accounts |
| **Actors** | Owner |
| **Related Use Case** | Login History |
| **Preconditions** | User table exists |
| **Postconditions** | User information and access are updated |
| **Flow of Activities** | **Actor:** 1. Owner inputs user details. 2. Saves the user record. **System:** 1.1 System validates input. 1.2 Saves data to the database. 1.3 Confirms update. |
| **Exception Conditions** | If the username already exists, the system prompts an error. |

### 3.4 Financial Reporting

| Field | Description |
|---|---|
| **Use Case Name** | Generate Financial Report |
| **Scenario** | The owner generates sales and expense reports |
| **Triggering Event** | The owner selects the report option |
| **Brief Description** | System compiles data and generates a summary report |
| **Actors** | Owner |
| **Related Use Case** | Sales Transaction, Expense Management |
| **Preconditions** | Transaction and expense data must exist |
| **Postconditions** | The report is generated and stored |
| **Flow of Activities** | **Actor:** 1. Owner chooses date range. 2. Requests report generation. **System:** 1.1 Collects relevant data. 1.2 Calculates totals and profit. 1.3 Displays or exports the report. |
| **Exception Conditions** | If no data is found, the system displays "No Records Found." |

### 3.5 Service Supply Inventory Management

| Field | Description |
|---|---|
| **Use Case Name** | Manage Service Supply Stock |
| **Scenario** | Owner records new or used supplies |
| **Triggering Event** | Owner inputs stock changes |
| **Brief Description** | System tracks service supply stock in/out |
| **Actors** | Owner |
| **Related Use Case** | Service Supply Management |
| **Preconditions** | Service supply items exist in the system |
| **Postconditions** | Stock levels updated |
| **Flow of Activities** | **Actor:** 1. Owner inputs supply data. 2. Submits stock update. **System:** 1.1 Updates stock quantity. 1.2 Logs stock transaction. |
| **Exception Conditions** | If a negative quantity is entered, the system displays an error. |

### 3.6 Product Inventory Management

| Field | Description |
|---|---|
| **Use Case Name** | Manage Product Inventory |
| **Scenario** | Owner updates product stock |
| **Triggering Event** | The owner records stock in or out |
| **Brief Description** | Tracks product stock movement and availability |
| **Actors** | Owner |
| **Related Use Case** | Sales Transaction |
| **Preconditions** | Product records exist |
| **Postconditions** | Inventory count updated |
| **Flow of Activities** | **Actor:** 1. Owner inputs stock details. 2. Confirms changes. **System:** 1.1 Updates stock level. 1.2 Saves a transaction record. |
| **Exception Conditions** | If invalid data is entered, the system prompts the user to correct it. |

### 3.7 Service Supply Management

| Field | Description |
|---|---|
| **Use Case Name** | Manage Service Supplies |
| **Scenario** | Owner adds or updates supply info |
| **Triggering Event** | Owner updates supply details |
| **Brief Description** | Manages list of supplies used in services |
| **Actors** | Owner |
| **Related Use Case** | Service Supply Inventory Management |
| **Preconditions** | Supply table exists |
| **Postconditions** | Supply info updated |
| **Flow of Activities** | **Actor:** 1. Owner selects supply. 2. Edits and saves details. **System:** 1.1 Updates record. 1.2 Confirms change. |
| **Exception Conditions** | If a duplicate name is found, the system prompts the user. |

### 3.8 Expense Management

| Field | Description |
|---|---|
| **Use Case Name** | Manage Expenses |
| **Scenario** | Owner records expenses |
| **Triggering Event** | Owner inputs expense data |
| **Brief Description** | Records and tracks business expenses |
| **Actors** | Owner |
| **Related Use Case** | Financial Reporting |
| **Preconditions** | The expense table must exist |
| **Postconditions** | Expense recorded |
| **Flow of Activities** | **Actor:** 1. Owner enters expense info. 2. Saves record. **System:** 1.1 Validates and saves data. 1.2 Confirms success. |
| **Exception Conditions** | If the amount is blank or invalid, the system shows an error. |

---

## Design Class Diagrams

### User Management

```
Adress
─────────────────────
addressID PK  : integer
street        : string
barangay      : string
city          : string
province      : string
region        : string
postalCode    : integer
country       : string
addressType   : string

User
─────────────────────
userID PK       : integer
addressID FK    : integer   ──── 0..* Adress
username        : string
password        : string
firstName       : string
lastName        : string
email           : string
phoneNumber     : integer
role            : string
isActive        : boolean
createdAt       : date
createdBy       : int
profilePicture  : string

Login_History
─────────────────────
loginID PK    : integer
userID FK     : integer   ──── 0..* User
username      : string
loginTime     : timestamp
logOutTime    : timestamp
```

### Product Management

```
Product
─────────────────────
productID PK          : integer
productName           : string
productCategory       : string
productType           : string
productPurchasePrice  : float
productSellingPrice   : float
expiryDate            : date
productProfit         : float

Service_Supply
─────────────────────
serviceSupplyID PK  : integer
serviceSupplyName   : string
supplyType          : string
supplySize          : string
purchasePrice       : float

Service
─────────────────────
serviceID PK   : integer
serviceName    : string

Service_Type
─────────────────────
serviceTypeID PK      : integer
serviceID FK          : integer   ──── Service
serviceSupplyID FK    : integer   ──── Service_Supply
machineID FK          : integer   ──── 0..* Machine
serviceTypeName       : string
paperSize             : string
colorMode             : string

Service_Type_Cost
─────────────────────
serviceTypeCostID PK  : integer
serviceTypeID FK      : integer
serviceSupplyCost     : float
inkCost               : float
electricityCost       : float
laborCost             : float
serviceTotalCost      : float
serviceSellingPrice   : float
lastUpdated           : date

Machine
─────────────────────
machineID PK  : integer
serviceID FK  : integer   (0..* — one machine links to many Service_Types)
machineName   : string
isActive      : boolean
```

### Inventory Management

```
Stock_In
─────────────────────
stockInID PK        : integer
productID FK        : integer
serviceSupplyID FK  : integer
userID FK           : integer
expenseID FK        : integer
purchasePrice       : float
quantity_added      : integer
expiryDate          : date
stockInDate         : datetime

Inventory_Item
─────────────────────
inventoryItemID PK  : integer
productID FK        : integer
serviceSupplyID FK  : integer
stockInID FK        : integer
currentQuantity     : integer
expiryDate          : date

Stock_Out
─────────────────────
stockOutID PK         : integer
transactionID FK      : integer
transactionItemID FK  : integer
productID FK          : integer
serviceSupplyID FK    : integer
inventoryItemID FK    : integer
userID FK             : integer
quantity_removed      : integer
stockOutType          : string
stockOutDate          : datetime
```

### Transaction Sales

```
Customer
─────────────
customerID PK  : integer
name           : string

Transaction
─────────────────────
transactionID PK    : integer
customerID FK       : integer
userID FK           : integer
totalAmount         : integer
transactionDate     : timestamp
cashReceived        : float
change              : float

Transaction_Item
─────────────────────
transactionItemID PK  : integer
transactionID FK      : integer
productID FK          : integer
serviceID FK          : integer
serviceTypeID FK      : integer
serviceTypeCostID FK  : integer
productPurchasePrice  : float
productSellingPrice   : float
serviceTotalCost      : float
serviceSellingPrice   : float
quantity              : integer
subtotal              : float
totalProfit           : float
```

### Business Expense

```
Expense
─────────────────────
expenseID PK      : integer
userD FK          : integer
expenseCategory   : string
description       : string
expenseAmount     : float
expenseDate       : timestamp
```

### Financial Report

```
Daily_Transaction
─────────────────────
dailyTransactionID PK     : integer
dailySalesReportID FK     : integer
transactionID FK          : integer
userID FK                 : integer
expenseID FK              : integer
transactionDate           : date
itemCount                 : integer
revenue                   : float
profit                    : float

Daily_Sales_Report
─────────────────────
dailySalesReportID PK  : integer
monthlyReportID FK     : integer
reportDate             : date
totalRevenue           : float
totalExpenses          : float
totalProfit            : float
netProfit              : float
transactionCount       : integer

Monthly_Report
─────────────────────
monthlyReportID PK      : integer
reportMonth             : integer
reportYear              : string
totalRevenue            : float
totalTransactionProfit  : float
totalExpenses           : float
netProfit               : float
transactionCount        : integer
avgMonthlyRevenue       : float
avgDailyRevenue         : float

Yearly_Report
─────────────────────
yearlyReportID PK       : integer
reportYear              : float
totalRevenue            : float
totalTransactionProfit  : float
totalExpenses           : float
netProfit               : float
transactionCount        : integer
avgMonthlyRevenue       : float
bestMonth               : string
worstMonth              : string
```

---

## UI/UX Design

### Login Page

- Centered card with PrintSari Corner logo (store + print icons)
- Username and Password fields
- Login button
- Demo credentials shown at bottom:
  - Owner: `owner / owner123`
  - Cashier: `cashier / cashier123`

### Owner Dashboard

**Dashboard** — Welcome banner (user name), four summary cards:
- Today's Sales (total P amount + transaction count)
- Store Sales (P amount + item count)
- Printing Sales (P amount + transaction count)
- Today's Expenses (P amount + expense count)

Lower section:
- Recent Transactions (item count + amount + timestamp + cashier name)
- Low Stock Alert (list of items below threshold, or "All items are well-stocked")

Sidebar navigation:
- Dashboard, Products & Services, Sales Transaction, Inventory, Expenses, Financial Reports, User Management
- Logout at bottom

### Products & Services Page

Tabs: **Store Products** | **Print Services** | **Machines**

- **Store Products tab** — Table: Name, Category, Purchase Price, Selling Price, Stock, SKU, Supplier, Actions (edit, delete)
- **Print Services tab** — Table: Name, Machine, Paper Size, Color Mode, Base Price, Cost/Page, Actions
- **Machines tab** — Table: Name, Status (Active/Inactive badge), Actions (edit, toggle, delete)

**Add Product/Service** button (top right, owner only)

### Sales Transaction (POS Terminal)

Two-panel layout:
- **Left (60%)** — Search bar, tab toggle (Store / Printing), product/service grid with name, price, available stock
- **Right (40%)** — Cart items list (quantity +/−, remove), Order Summary (items count, quantity total, grand total), Process Transaction button, cashier name

### Inventory Management

Tabs: **All Products** | **Store Products** | **Printing Supplies** | **Stock History**

- Product list with name, purchase price, current stock (units)
- Stock-in buttons (owner only): Stock In – Store / Stock In – Printing
- Stock History tab shows all stock-in events with date, quantity, user

### Expense Management

Header: Today's Expenses, This Month, Total Expenses (with P amounts)

Expense Records list: description + date + category + amount + delete button

"Record Expense" button opens dialog with: category dropdown, description, amount, date

### Financial Reports

Tabs: **Daily** | **Weekly** | **Monthly**

Summary cards: Total Sales, Store Revenue, Printing Revenue, Total Expenses, Net Profit, Transactions

Revenue Breakdown: horizontal bar chart (Store Products vs. Printing Services)

Export Report button (top right)

### User Management

Summary: Total Users, Owners, Cashiers

**Owner Accounts** section — cards with name, @username, edit/delete icons (green background)
**Cashier Accounts** section — cards with name, @username, edit/delete icons (green/gray background)

**Access Permissions** panel:
- Owner (Full Access): View Dashboard, Manage Products & Services, Process Sales Transactions, Manage inventory (Add/Edit Stock), Record Business Expenses, View Financial Reports, Manage Users
- Cashier (Limited Access): Process Sales Transactions, View Inventory

Add User button opens a dialog with: username, password, first/last name, email, phone, role dropdown, address fields

### Cashier Dashboard

Same layout as Owner Dashboard but sidebar only shows:
- Dashboard, Sales Transaction, Inventory
- Today's Expenses shows all business expenses (read-only)

### Cashier — Sales Transaction

Same POS layout as owner. Cashier name shown at bottom of Order Summary.

### Cashier — Inventory View

Read-only inventory list. No stock-in buttons. Shows current quantities per product.
