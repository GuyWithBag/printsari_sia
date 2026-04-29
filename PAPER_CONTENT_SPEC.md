# PrintSari Corner — Complete Paper Content Specification
# For Claude to Reproduce the Academic System Design Paper

This document contains a complete, accurate description of every section, table, diagram, and piece of content in the 49-page paper "PrintSari Corner System Design" (November 2025). Use this to generate a new version of the paper with the same structure and content.

---

## COVER PAGE

- Title: **PrintSari Corner**
- Subtitle: **Retail & Print Services Management System**
- (or equivalent system design title your professor approves)
- Authors (in order they appear):
  - Dulaugon, Loejee Miguel S.
  - Lupase, Daniel David M.
  - Pacanza, Bernard Louie T.
- Adviser: **Mr. Rodwell Matchon**
- Panelists:
  - Mr. Dwight Ian De Jesus
  - Mr. Antonio Bulao II
- Month/Year: **November 2025**
- Institution seal/logo: **Ateneo de Davao University** (displayed at bottom)

---

## TABLE OF CONTENTS

Section numbers and titles exactly as they appear:

1. Preliminary Investigation Report
2. Events Table / Use Case List / Use Case Diagram
   - 2.1 Events Table
   - 2.2 Use Case List
   - 2.3 Use Case Diagram
3. Use Case Description
   - 3.1 Sales Transaction
   - 3.2 Product and Service Management
   - 3.3 User Management
   - 3.4 Financial Reporting
   - 3.5 Service Supply Inventory Management
   - 3.6 Product Inventory Management
   - 3.7 Service Supply Management
   - 3.8 Expense Management
4. Domain Class Diagram
5. Design Class Diagram
   - 5.1 User Management
   - 5.2 Product Management
   - 5.3 Inventory Management
   - 5.4 Transaction Sales
   - 5.5 Business Expense
   - 5.6 Financial Report
6. UI/UX Design
   - 6.1 Login Page
   - 6.2 Owner Dashboard
   - 6.3 Cashier Dashboard

---

## SECTION 1: PRELIMINARY INVESTIGATION REPORT (PIR)

### Organization Information

| Field | Value |
|---|---|
| Organization Name | PrintSari Corner |
| Industry | Retail & Print Services |
| Address | Purok 5 RVM Poblacion, Magpet, North Cotabato |
| Contact Person | Dennis A. Lupase |
| Phone | 09124372005 |
| Email | dennislupase@gmail.com |
| Owners | Dennis A. Lupase and Charita Lupase |
| Workers | Zimon Catipay, Desiree Jane Lupase, Monique Anguit |
| Stock Person | Ellaine Lupase |

### Brief History
PrintSari Corner was established in 2023, located near the municipal hall in Magpet, North Cotabato. The business was founded in response to community demand for document photocopying services, as residents frequently needed documents for government transactions at the nearby municipal hall. A gymnasium nearby also drove sales of snacks and drinks. The business operates two combined segments: a sari-sari (convenience) store and a printing shop.

### Current Business Processes (3 processes described)

**1. Sari-Sari Store (Retail) Process:**
- The cashier manually checks the price of each item
- Records are kept on bond paper
- No receipts are issued to customers

**2. Printing Services Process:**
- The clerk asks the customer for their printing specifications
- Price is calculated manually based on job type
- Records are kept on bond paper

**3. End-of-Day Reconciliation Process:**
- The owner counts physical cash at the end of the day
- Reads the bond paper records to compute the day's totals
- Estimates stock levels by physically counting items

### Identified Problems (5 problems)

1. **No Sales Tracking** — No system for recording sales data; revenue tracking is entirely manual and unreliable
2. **Inventory Management Issues** — No automated stock tracking; stock levels are estimated manually leading to overstock or stockouts
3. **Manual Calculation Errors** — Hand-computed totals on bond paper are prone to arithmetic mistakes
4. **Financial Record Keeping Problems** — No organized record of expenses, profit, or loss; no historical data for business decisions
5. **Mixed Business Tracking** — Store and printing segments are not separated, making it hard to assess which part of the business is profitable

---

## SECTION 2: EVENTS TABLES

### Events Table Format
All events tables use 6 columns: **Event | Trigger | Source | Use Case | Response | Destination**

---

### Events Table: Product Management

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Add Store Product | Owner enters product details | Owner | Manage Store Products | Product record created with productID, name, category, type, purchase price, selling price, profit | Product Table |
| Update Store Product | Owner edits product info | Owner | Manage Store Products | Product record updated with new details, profit recalculated | Product Table |
| Remove Store Product | Owner deletes product | Owner | Manage Store Products | Product marked inactive or removed from system | Product Table |
| View Store Products | Owner/Cashier views catalog | Owner/Cashier | View Product Catalog | Display all products with details and stock status | Product Interface |

---

### Events Table: Service Management

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Add Print Service | Owner creates service type | Owner | Manage Services | Service record created with serviceID, name, type, machine linkage | Service Table |
| Update Service Details | Owner modifies service | Owner | Manage Services | Service record updated | Service Table |
| Add Service Type | Owner defines variant | Owner | Manage Service Types | Service_Type record created with paper size, color mode, supply/machine link | Service_Type Table |
| Set Service Type Cost | Owner inputs cost breakdown | Owner | Manage Service Type Costs | Service_Type_Cost record with supply, ink, electricity, labor cost and selling price | Service_Type_Cost Table |
| Update Service Rates | Owner adjusts pricing | Owner | Update Service Rates | Service_Type_Cost updated, lastUpdated timestamp set | Service_Type_Cost Table |
| Assign Machine to Service | Owner links printer | Owner | Assign Machines to Services | Machine assigned to service type; active/inactive status set | Machine Table |
| Add Service Supply | Owner adds supply item | Owner | Configure Service Supplies | Service_Supply record with name, type, paper size, purchase price | Service_Supply Table |

---

### Events Table: Sales Transactions (continuation from pages 8–11)

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Add Product to Transaction | Cashier selects item | Cashier | Add Product to Transaction | Transaction_Item created with productID, quantity, purchase price, selling price, subtotal, profit | Transaction_Item Table |
| Add Service to Transaction | Cashier selects print job | Cashier | Add Service to Transaction | Transaction_Item created with serviceID, serviceTypeID, cost breakdown, selling price | Transaction_Item Table |
| Calculate Total | Items added | System | Calculate Transaction Totals | Total amount computed from all items; total profit calculated | — |
| Process Payment | Cashier enters cash received | Cashier | Process Customer Transaction | Cash received and change calculated and recorded | Transaction Table |
| Complete Transaction | Transaction finalized | System | Record Transaction | Transaction saved with complete details, timestamp recorded | Transaction Table |
| Generate Receipt | Customer requests receipt | Cashier | Generate Customer Receipt | Receipt generated with transaction details, items, prices, totals | Customer |
| Auto-Deduct Inventory | Transaction completed | System | Auto-Update Inventory | Stock_Out record created for each item, quantities reduced in Inventory_Item | Stock_Out Table, Inventory_Item Table |

---

### Events Table: Product Inventory Management

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Product Stock In | Owner receives new stock | Owner | Update Store Inventory | Stock_In record created with productID, userID, quantity, purchase price, expiry date, stockInDate | Stock_In Table |
| Link Stock to Expense | Owner records purchase expense | Owner | Track Business Expenses | Stock_In linked to expense record via expenseID | Stock_In Table |
| Create Inventory Item | Stock In processed | System | Update Inventory Items | Inventory_Item created/updated with productID, stockInID, current quantity, expiry date | Inventory_Item Table |
| View Product Inventory | Owner/Cashier views stock | Owner/Cashier | View Current Inventory | Display all inventory items with current quantities, expiry dates per product | Inventory Interface |
| Adjust Product Quantity | Owner manually adjusts stock | Owner | Update Store Inventory | Stock_In or Stock_Out record created for adjustment, Inventory_Item quantity updated | Stock_In/Out Table, Inventory_Item |
| Track Product Expiry | System checks expiry dates | System | Monitor Product Expiration | Alert generated for products approaching expiry date | User Interface |

---

### Events Table: Service Supply Inventory Management

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Service Supply Stock In | Owner receives supplies | Owner | Update Printing Inventory | Stock_In record created with serviceSupplyID, userID, quantity, purchase price, stockInDate | Stock_In Table |
| Link Service Supply to Expense | Owner records purchase expense | Owner | Track Business Expenses | Stock_In linked to expense record via expenseID | Stock_In Table |
| Create Service Supply Inventory Item | Stock In processed | System | Update Inventory Items | Inventory_Item created/updated with serviceSupplyID, stockInID, current quantity | Inventory_Item Table |
| View Service Supply Inventory | Owner/Cashier views supplies | Owner/Cashier | View Current Inventory | Display all supply inventory items with current quantities | Inventory Interface |
| Adjust Service Supply Quantity | Owner manually adjusts supplies | Owner | Update Printing Inventory | Stock_In or Stock_Out record created for adjustment, Inventory_Item quantity updated | Stock_In/Out Table, Inventory_Item |
| Deduct Service Supply on Service | Service transaction completed | System | Auto-Deduct Inventory | Stock_Out record created with serviceSupplyID, transactionItemID, quantity removed, stockOutType | Stock_Out Table |

---

### Events Table: Financial Reporting

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Generate Daily Report | System runs end-of-day | System | Generate Daily Reports | Daily_Sales_Report created with date, total revenue, expenses, profit, net profit, transaction count | Daily_Sales_Report Table |
| Generate Daily Transactions | System aggregates transactions | System | Track Daily Performance | Daily_Transaction records created linking to dailySalesReportID with transaction details, revenue, profit | Daily_Transaction Table |
| View Daily Report | Owner selects "Daily" tab | Owner | Display Daily Reports | Display daily report with revenue breakdown, expenses, profit analysis | Owner Interface |
| Generate Monthly Report | System runs end-of-month | System | Generate Monthly Reports | Monthly_Report created aggregating daily reports with month/year, totals, averages | Monthly_Report Table |
| View Monthly Report | Owner selects "Monthly" tab | Owner | Display Monthly Reports | Display monthly performance with revenue, profit, expenses, averages | Owner Interface |
| Generate Yearly Report | System runs end-of-year | System | Generate Yearly Reports | Yearly_Report created aggregating monthly data with best/worst months, annual totals | Yearly_Report Table |
| View Yearly Report | Owner selects "Yearly" tab | Owner | Display Yearly Reports | Display annual performance with monthly comparisons, trends | Owner Interface |
| Export Report | Owner clicks export button | Owner | Generate Report File | PDF/Excel file generated from selected report data | Owner Device |

---

### Events Table: Expense Management

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Record Business Expense | Owner enters expense data | Owner | Track Business Expenses | Expense record created with expenseID, userID, category, description, amount, date | Expense Table |
| Link Expense to Stock In | Owner records inventory purchase | Owner | Record Purchase Expense | Expense linked to Stock_In record for inventory cost tracking | Expense Table, Stock_In Table |
| View Expense History | Owner views expenses | Owner | View Expense Records | Display all expenses by category, date, amount | Expense Interface |
| Categorize Expense | Owner assigns expense category | Owner | Track Business Expenses | Expense category assigned (utilities, supplies, maintenance, etc.) | Expense Table |

---

### Events Table: User Management

| Event | Trigger | Source | Use Case | Response | Destination |
|---|---|---|---|---|---|
| Create User Account | Owner adds new user | Owner | Manage User Accounts | User record created with userID, username, password, personal info, role, addressID, isActive status | User Table |
| Assign User Role | Owner sets user role | Owner | Manage User Permissions | User role assigned (Owner/Cashier) determining access level | User Table |
| Add User Address | Owner enters address info | Owner | Manage User Accounts | Address record created and linked to user via addressID | Address Table, User Table |
| Update User Information | Owner modifies user details | Owner | Manage User Accounts | User credentials, personal info, contact details, profile picture updated | User Table |
| Deactivate User Account | Owner removes user | Owner | Manage User Accounts | User isActive status set to false, account access revoked | User Table |
| View User Accounts | Owner views user list | Owner | View User Accounts | Display all users with roles, status, creation info | User Interface |
| User Login | User enters credentials | User | Authenticate User | Login_History record created with loginID, userID, username, loginTime | Login_History Table |
| User Logout | User clicks logout | User | End User Session | Login_History record updated with logOutTime | Login_History Table |
| Track Login History | System logs user sessions | System | Monitor User Activity | All login/logout events recorded with timestamps | Login_History Table |

---

## SECTION 2.2: USE CASE LIST

### Sales Transaction System

**Description paragraph:** A unified transaction system that processes both sari-sari store items and printing services in a single integrated interface. The system handles combined purchases where customers can buy store products and request printing services simultaneously. Each transaction is linked to a customer record and tracks detailed item information including purchase prices, selling prices, and profit margins. The system automatically updates inventory through Stock_Out records upon transaction completion.

**Use Cases:**
- **Process Customer Transaction**: Handle combined purchases of store items and/or printing services, creating transaction records with customer linkage
- **Add Product to Transaction**: Add product items to transaction with quantity, purchase price, selling price, subtotal, and profit calculation
- **Add Service to Transaction**: Add printing service types to transaction with cost breakdown (supply cost, ink cost, electricity cost, labor cost) and selling price
- **Calculate Transaction Totals**: Automatically compute total amount from all transaction items and calculate total profit
- **Process Payment**: Record cash received and calculate change for customer
- **Generate Customer Receipt**: Create and print optional receipt with complete transaction details including itemized list
- **Track Transaction Items**: Record individual items in Transaction_Item table with detailed pricing and profit information
- **Auto-Deduct Inventory**: Automatically create Stock_Out records and reduce inventory quantities when transaction is completed

---

### Dual Inventory Management System

**Description paragraph:** A comprehensive real-time inventory tracking system that monitors stock levels for both sari-sari store products and printing supplies through Inventory_Item records. The system tracks stock movements via Stock_In and Stock_Out records, linking purchases to expense records for accurate cost tracking. Inventory items maintain current quantities and expiry dates, with automatic deductions triggered by sales transactions. The owner manages stock additions and adjustments, while cashiers have view-only access to monitor current levels.

**Use Cases:**
- **Record Product Stock In**: Create Stock_In records when receiving new product inventory with quantity, purchase price, expiry date, and link to expense
- **Record Supply Stock In**: Create Stock_In records when receiving printing supplies with quantity and purchase price
- **Create Inventory Items**: Generate or update Inventory_Item records linking to Stock_In with current quantities and expiry tracking
- **View Current Inventory**: Display real-time stock levels for all products and supplies from Inventory_Item table (Owner and Cashier)
- **Adjust Product Quantity**: Manually create Stock_In or Stock_Out records for inventory adjustments (Owner only)
- **Adjust Supply Quantity**: Manually adjust printing supply quantities through Stock_In/Out records (Owner only)
- **Monitor Product Expiration**: Track expiry dates in Inventory_Item and generate alerts for perishable products
- **Track Stock Movements**: View complete history of Stock_In and Stock_Out records with dates, quantities, and reasons
- **Auto-Deduct on Sale**: Automatically create Stock_Out records linked to transactions when items are sold
- **Link Purchases to Expenses**: Connect Stock_In records to Expense records for financial tracking

---

### Financial Report

**Description paragraph:** An automated financial tracking and reporting system that computes business performance through a hierarchical reporting structure. The system generates Daily_Sales_Report aggregating Daily_Transaction records, which roll up into Monthly_Report and Yearly_Report. Each level tracks revenue from both store and printing segments, expenses, transaction profit, and net profit after expenses. The system links business expenses to stock purchases and operational costs. Reports include transaction counts, averages, and identify best/worst performing periods. Accessible only to the owner for business analysis and decision-making.

**Use Cases:**
- **Generate Daily Reports**: Create Daily_Sales_Report with aggregated revenue, expenses, profit, net profit, and transaction count
- **Record Daily Transactions**: Generate Daily_Transaction records for each sale with revenue and profit breakdown
- **Generate Monthly Reports**: Produce Monthly_Report aggregating daily reports with month/year totals, averages, and transaction counts
- **Generate Yearly Reports**: Create Yearly_Report aggregating monthly data with annual totals, best/worst months, and monthly averages
- **View Daily Performance**: Display daily sales summaries with revenue and expense breakdown by date
- **View Monthly Performance**: Show monthly business performance comparing store and printing revenues across months
- **View Yearly Performance**: Display annual business reports with monthly comparisons and trend analysis
- **Export Reports**: Generate PDF/Excel files from Daily, Monthly, or Yearly reports for external use
- **Record Business Expenses**: Enter and track business costs with category, description, amount, and date
- **Link Expenses to Purchases**: Connect expense records to Stock_In records for inventory cost tracking
- **Calculate Net Profit**: Compute net profit by subtracting total expenses from transaction profit
- **Track Expense Categories**: Categorize expenses (utilities, supplies, maintenance, etc.) for detailed analysis

---

### Product and Service Management System

**Description paragraph:** A comprehensive management system for maintaining product catalog and service offerings. The Product module handles store items with categories, types, purchase prices, selling prices, and profit margins. The Service module manages printing services through a three-tier structure: Service (base service), Service_Type (specific variants with paper size and color mode linked to Service_Supply and Machine), and Service_Type_Cost (detailed cost breakdown including supply cost, ink cost, electricity cost, labor cost, total cost, and selling price). Changes reflect immediately in the POS system for transaction processing.

**Use Cases:**
- **Manage Store Products**: Add, update, or remove products with category, type, purchase price, selling price, and profit calculation
- **View Product Catalog**: Display all products with detailed information and current inventory status
- **Manage Services**: Create and configure base printing services (xerox, printing, lamination)
- **Manage Service Types**: Define service variants linking Service, Service_Supply, Machine with specifications (paper size, color mode)
- **Manage Service Type Costs**: Configure detailed cost components (supply, ink, electricity, labor) and set selling prices
- **Update Product Pricing**: Modify product purchase prices and selling prices with automatic profit recalculation
- **Update Service Rates**: Adjust service type costs and selling prices with last updated timestamp
- **Configure Service Supplies**: Add and manage printing supplies (paper types, toner, lamination film) with purchase prices
- **Assign Machines to Services**: Link machines to services and manage active/inactive status
- **Track Service Profitability**: Calculate service profit margins from cost breakdown and selling prices

---

### User Management System

**Description paragraph:** A role-based access control system that manages user authentication, permissions, and activity tracking. The system supports two user roles: Owner (full access to all features) and Cashier (restricted access to POS and view-only inventory). User records include comprehensive personal information, contact details, address linkage through Address table, profile pictures, and account status (isActive). The Login_History table tracks all user sessions with login and logout timestamps. Upon login, the system displays interface elements appropriate to the user's role and records the session. Users are linked to their actions throughout the system via userID foreign keys.

**Use Cases:**
- **Create User Account**: Add new user with username, password, personal info, role assignment, and address details
- **Assign User Role**: Set role-based access levels (Owner vs. Cashier) determining system permissions
- **Manage User Address**: Create and link Address records to users with complete location details
- **Update User Information**: Modify user credentials, personal details, contact info, and profile picture
- **Activate/Deactivate User**: Set user isActive status to enable or disable account access
- **View User Accounts**: Display all system users with roles, status, creation info, and contact details
- **Authenticate User**: Validate login credentials and create Login_History record with login timestamp
- **Track User Sessions**: Record all login and logout events with timestamps in Login_History table
- **End User Session**: Process logout and update Login_History with logout timestamp
- **Track User Actions**: Link user activities (transactions, stock movements, expense records) to userID
- **View Login History**: Display user session history with login/logout times for activity monitoring

---

## SECTION 2.3: USE CASE DIAGRAMS

There are 7 use case diagrams. Each uses blue oval shapes on white background with a stick figure actor. Relationships are <<include>> (solid arrows with dashed lines) and <<Extend>> (dashed arrows).

### A. Sales Transaction
- **Actor**: Cashier/Owner (single stick figure on left)
- **System boundary box** labeled "Sales Transaction"
- **Use case nodes**: Add new transaction, Edit transaction items, Process transaction, Calculate transaction total, Generate receipt, View transaction history, Record transaction, Deduct inventory stock
- **Relationships**:
  - Actor → Add new transaction
  - Actor → Process transaction (with <<include>> to Add new transaction)
  - Actor → Generate receipt
  - Actor → View transaction history
  - Edit transaction items →<<Extend>>→ Calculate transaction total
  - Process transaction →<<include>>→ Calculate transaction total
  - Calculate transaction total →<<include>>→ Record transaction
  - Generate receipt →<<include>>→ Calculate transaction total (via include)
  - Record transaction →<<include>>→ Deduct inventory stock

### B. Product and Service Management
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "Product Management"
- **Use case nodes**: View and search store products and printing services, Add store product or printing service, Input store product details or printing service details, Update store product details or printing service details, Remove store product or printing service
- **Relationships**:
  - Actor → View and search store products and printing services
  - Actor → Add store product or printing service
  - Actor → Update store product details or printing service details
  - Actor → Remove store product or printing service
  - Add store product →<<include>>→ Input store product details or printing service details
  - Input store product details →<<Extend>>→ View and search (dashed back)
  - Update store product →<<include>>→ Input store product details or printing service details
  - Input store product details →<<Extend>>→ (another extend going right, outside box)

### C. User Management
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "User Management"
- **Use case nodes**: Create user account, Assign user role, Input user information, Update user information, View user accounts, Deactivate User Account, Delete User Account, Login, Logout, View Login History
- **Relationships**:
  - Actor → Create user account, Update user information, View user accounts, Delete User Account, Login, Logout, View Login History
  - Create user account →<<include>>→ Assign user role
  - Create user account →<<include>>→ Input user information
  - Update user information →<<include>>→ Input user information
  - View user accounts →<<Extend>>→ Deactivate User Account
  - View user accounts →<<Extend>>→ Delete User Account

### D. Financial Reporting
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "Financial Reporting"
- **Use case nodes**: View monthly report, View weekly report, View daily report, Record business expense, Export Report, Generate Daily Report, Generate Daily Transactions, Generate Monthly Report, Generate Yearly Report, Edit business expense item, Delete business expense item
- **Relationships**:
  - Actor → View monthly report, View weekly report, View daily report, Record business expense, Export Report
  - View monthly report →<<include>>→ Generate Daily Report (dashed)
  - View weekly report →<<include>>→ Generate Daily Report (dashed)
  - View daily report →<<include>>→ Generate Daily Report (dashed)
  - Generate Daily Report →<<include>>→ Generate Daily Transactions
  - View monthly report →<<Extend>>→ Export report
  - View weekly report →<<Extend>>→ Export report
  - View daily report →<<Extend>>→ Export report
  - Generate Daily Report →→ Generate Monthly Report
  - Generate Monthly Report →→ Generate Yearly Report
  - Record business expense →<<Extend>>→ Edit business expense item
  - Record business expense →<<Extend>>→ Delete business expense item

### E. Service Supply Inventory Management
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "Service Supply Inventory Management"
- **Use case nodes**: Service Supply Stock In, Create Service Supply Inventory Item, Link Service Supply to Expense, Adjust Service Supply Quantity, View Service Supply Inventory, Deduct Service Supply on every Service Transaction
- **Relationships**:
  - Actor → Service Supply Stock In, Link Service Supply to Expense, View Service Supply Inventory
  - Service Supply Stock In →<<include>>→ Create Service Supply Inventory Item
  - View Service Supply Inventory →<<Extend>>→ Adjust Service Supply Quantity
  - Deduct Service Supply on every Service Transaction (floats outside, connected via dashed line)

### F. Product Inventory Management
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "Product Inventory Management"
- **Use case nodes**: Product Stock In, Create Inventory Item, Link Stock to Expense, Adjust Product Quantity, View Product Inventory, Deduct Product Inventory Every Transaction, Track Product Expiry
- **Relationships**:
  - Actor → Product Stock In, Link Stock to Expense, View Product Inventory
  - Product Stock In →<<include>>→ Create Inventory Item
  - View Product Inventory →<<Extend>>→ Adjust Product Quantity
  - View Product Inventory →<<Extend>>→ Track Product Expiry
  - Deduct Product Inventory Every Transaction (floats, dashed arrow back to inventory)

### G. Service Supply Management
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "Service Supply Management"
- **Use case nodes**: View Service Supplies, Add New Supply, Update Supply Details
- **Relationships**:
  - Actor → View Service Supplies, Add New Supply, Update Supply Details
  - Add New Supply →<<Extend>>→ View Service Supplies
  - Update Supply Details →<<Extend>>→ View Service Supplies (via dashed)

### H. Expense Management
- **Actor**: Owner (stick figure on left)
- **System boundary box** labeled "Expense Management"
- **Use case nodes**: Record Business Expense, Categorize Expense, Link Expense to Stock In, View Expense History
- **Relationships**:
  - Actor → Record Business Expense, Link Expense to Stock In, View Expense History
  - Record Business Expense →<<include>>→ Categorize Expense
  - Record Business Expense →<<Extend>>→ Link Expense to Stock In

---

## SECTION 3: USE CASE DESCRIPTIONS

All use case descriptions use a 2-column table format with **Field** and **Description** columns. Fields are: Use Case Name, Scenario, Triggering Event, Brief Description, Actors, Related Use Case, Preconditions, Postconditions, Flow of Activities, Exception Conditions.

### 3.1 Sales Transaction

| Field | Description |
|---|---|
| Use Case Name | Process Sales Transaction |
| Scenario | Cashier records the customer's order and processes the payment |
| Triggering Event | Cashier inputs orders in the POS |
| Brief Description | Cashier lists ordered products/services in the POS. The system computes the total and records the transaction. |
| Actors | Cashier, Customer |
| Related Use Case | Product Inventory Management, Service Supply Inventory Management |
| Preconditions | Products and services must exist in the system |
| Postconditions | Transaction details are saved; inventory is updated |
| Flow of Activities | **Actor:** 1. Cashier lists orders in the POS. 2. Confirms order and enters payment. **System:** 1.1 System checks stock availability. 1.2 The system computes the total and records the payment. 1.3 System updates the inventory and saves the transaction. |
| Exception Conditions | If the stock is unavailable, the system notifies the cashier to remove or replace the item. |

---

### 3.2 Product and Service Management

| Field | Description |
|---|---|
| Use Case Name | Manage Products and Services |
| Scenario | Owner updates product or service details |
| Triggering Event | Owner edits data in the management panel |
| Brief Description | The owner can add, update, or remove product and service records |
| Actors | Owner |
| Related Use Case | Product Inventory Management, Service Supply Management |
| Preconditions | The system must contain product and service tables |
| Postconditions | Product and service lists are updated |
| Flow of Activities | **Actor:** 1. Owner selects product/service to edit. 2. Owner saves changes. **System:** 1.1 Updates the database record. 1.2 Displays confirmation. |
| Exception Conditions | If a duplicate product/service name is detected, the system prompts an error. |

---

### 3.3 User Management

| Field | Description |
|---|---|
| Use Case Name | Manage User Accounts |
| Scenario | The owner adds or modifies user access |
| Triggering Event | The owner creates or updates the user record |
| Brief Description | The owner can add, edit, or deactivate user accounts |
| Actors | Owner |
| Related Use Case | Login History |
| Preconditions | User table exists |
| Postconditions | User information and access are updated |
| Flow of Activities | **Actor:** 1. Owner inputs user details. 2. Saves the user record. **System:** 1.1 System validates input. 1.2 Saves data to the database. 1.3 Confirms update. |
| Exception Conditions | If the username already exists, the system prompts an error. |

---

### 3.4 Financial Reporting

| Field | Description |
|---|---|
| Use Case Name | Generate Financial Report |
| Scenario | The owner generates sales and expense reports |
| Triggering Event | The owner selects the report option |
| Brief Description | System compiles data and generates a summary report |
| Actors | Owner |
| Related Use Case | Sales Transaction, Expense Management |
| Preconditions | Transaction and expense data must exist |
| Postconditions | The report is generated and stored |
| Flow of Activities | **Actor:** 1. Owner chooses date range. 2. Requests report generation. **System:** 1.1 Collects relevant data. 1.2 Calculates totals and profit. 1.3 Displays or exports the report. |
| Exception Conditions | If no data is found, the system displays "No Records Found." |

---

### 3.5 Service Supply Inventory Management

| Field | Description |
|---|---|
| Use Case Name | Manage Service Supply Stock |
| Scenario | Owner records new or used supplies |
| Triggering Event | Owner inputs stock changes |
| Brief Description | System tracks service supply stock in/out |
| Actors | Owner |
| Related Use Case | Service Supply Management |
| Preconditions | Service supply items exist in the system |
| Postconditions | Stock levels updated |
| Flow of Activities | **Actor:** 1. Owner inputs supply data. 2. Submits stock update. **System:** 1.1 Updates stock quantity. 1.2 Logs stock transaction. |
| Exception Conditions | If a negative quantity is entered, the system displays an error. |

---

### 3.6 Product Inventory Management

| Field | Description |
|---|---|
| Use Case Name | Manage Product Inventory |
| Scenario | Owner updates product stock |
| Triggering Event | The owner records stock in or out |
| Brief Description | Tracks product stock movement and availability |
| Actors | Owner |
| Related Use Case | Sales Transaction |
| Preconditions | Product records exist |
| Postconditions | Inventory count updated |
| Flow of Activities | **Actor:** 1. Owner inputs stock details. 2. Confirms changes. **System:** 1.1 Updates stock level. 1.2 Saves a transaction record. |
| Exception Conditions | If invalid data is entered, the system prompts the user to correct it. |

---

### 3.7 Service Supply Management

| Field | Description |
|---|---|
| Use Case Name | Manage Service Supplies |
| Scenario | Owner adds or updates supply info |
| Triggering Event | Owner updates supply details |
| Brief Description | Manages list of supplies used in services |
| Actors | Owner |
| Related Use Case | Service Supply Inventory Management |
| Preconditions | Supply table exists |
| Postconditions | Supply info updated |
| Flow of Activities | **Actor:** 1. Owner selects supply. 2. Edits and saves details. **System:** 1.1 Updates record. 1.2 Confirms change. |
| Exception Conditions | If a duplicate name is found, the system prompts the user. |

---

### 3.8 Expense Management

| Field | Description |
|---|---|
| Use Case Name | Manage Expenses |
| Scenario | Owner records expenses |
| Triggering Event | Owner inputs expense data |
| Brief Description | Records and tracks business expenses |
| Actors | Owner |
| Related Use Case | Financial Reporting |
| Preconditions | The expense table must exist |
| Postconditions | Expense recorded |
| Flow of Activities | **Actor:** 1. Owner enters expense info. 2. Saves record. **System:** 1.1 Validates and saves data. 1.2 Confirms success. |
| Exception Conditions | If the amount is blank or invalid, the system shows an error. |

---

## SECTION 4: DOMAIN CLASS DIAGRAM

The domain class diagram is a full-page entity-relationship overview of ALL tables in the system. It appears small/dense on a single page. It contains roughly 15+ entity boxes connected by relationship lines.

**Entities visible (names only — the diagram is the same as the Design Class Diagrams combined):**
User, Address, Login_History, Product, Service, Service_Type, Service_Supply, Service_Type_Cost, Machine, Stock_In, Stock_Out, Inventory_Item, Transaction, Transaction_Item, Customer, Expense, Daily_Transaction, Daily_Sales_Report, Monthly_Report, Yearly_Report

**Note for reproduction:** The domain class diagram should be reproduced as a compressed overview showing all entities and their FK relationships. Attributes listed below in the Design Class Diagram section are the authoritative field lists.

---

## SECTION 5: DESIGN CLASS DIAGRAMS

### 5.1 User Management

**Three tables shown:**

**Address**
- addressID PK — integer
- street — string
- barangay — string
- city — string
- province — string
- region — string
- postalCode — integer
- country — string
- addressType — string

**User**
- userID PK — integer
- addressID FK — integer
- username — string
- password — string
- firstName — string
- lastName — string
- email — string
- phoneNumber — integer
- role — string
- isActive — boolean
- createdAt — date
- createdBy — int
- profilePicture — string

**Login_History**
- loginID PK — integer
- userID FK — integer
- username — string
- loginTime — timestamp
- logOutTime — timestamp

**Relationships:**
- Address 1 → 0..* User (one address can have many users)
- User 1 → 0..* Login_History (one user has many login records)
- User self-references createdBy (User 0..* → 1 User for createdBy)

---

### 5.2 Product Management

**Product table:**
- productID PK — integer
- productName — string
- productCategory — string
- productType — string
- productPurchasePrice — float
- productSellingPrice — float
- expiryDate — date
- productProfit — float

**Service_Supply table:**
- serviceSupplyID PK — integer
- serviceSupplyName — string
- supplyType — string
- paperSize — string
- purchasePrice — float

**Service table:**
- serviceID PK — integer
- serviceName — string

**Service_Type table:**
- serviceTypeID PK — integer
- serviceID FK — integer
- serviceSupplyID FK — integer
- machineID FK — integer
- serviceTypeName — string
- paperSize — string
- colorMode — string

**Service_Type_Cost table:**
- serviceTypeCostID PK — integer
- serviceTypeID FK — integer
- serviceSupplyCost — float
- inkCost — float
- electricityCost — float
- laborCost — float
- serviceTotalCost — float
- serviceSellingPrice — float
- lastUpdated — date

**Machine table:**
- machineID PK — integer
- serviceID FK — integer
- machineName — string
- isActive — boolean

**Relationships:**
- Service 1 → 0..* Service_Type
- Service_Supply 1 → 0..* Service_Type
- Service_Type 1 → 0..* Service_Type_Cost
- Machine 0..* → 1 Service (machine FK references service)
- (A fragment at top-left of the diagram shows float/integer/float/float — this belongs to a partially visible class, likely a customer or transaction cost fragment)

---

### 5.3 Inventory Management

**Stock_In table:**
- stockInID PK — integer
- productID FK — integer
- serviceSupplyID FK — integer
- userID FK — integer
- expenseID FK — integer
- purchasePrice — float
- quantity_added — integer
- expiryDate — date
- stockInDate — datetime

**Inventory_Item table:**
- inventoryItemID PK — integer
- productID FK — integer
- serviceSupplyID FK — integer
- stockInID FK — integer
- currentQuantity — integer
- expiryDate — date

**Stock_Out table:**
- stockOutID PK — integer
- transactionID FK — integer
- transactionItemID FK — integer
- productID FK — integer
- serviceSupplyID FK — integer
- inventoryItemID FK — integer
- userID FK — integer
- quantity_removed — integer
- stockOutType — string
- stockOutDate — datetime

**Relationships:**
- Stock_In 1 → 0..* Inventory_Item
- Inventory_Item 0..* → 0..* Stock_Out
- (FK lines connect to User, Expense, Product, Service_Supply from the other diagrams)

---

### 5.4 Transaction Sales

**Customer table:**
- customerID PK — integer
- name — string

**Transaction table:**
- transactionID PK — integer
- customerID FK — integer
- userID — integer
- totalAmount — integer
- transactionDate — timestamp
- cashReceived — float
- change — float

**Transaction_Item table:**
- transactionItemID PK — integer
- transactionID FK — integer
- productID FK — integer
- serviceID FK — integer
- serviceTypeID FK — integer
- serviceCostID FK (serviceTypeCostID) — integer
- productPurchasePrice — float
- productSellingPrice — float
- serviceTotalCost — float
- serviceSellingPrice — float
- quantity — integer
- subtotal — float
- totalProfit — float

**Relationships:**
- Customer 1 → 0..* Transaction
- Transaction 1 → 0..* Transaction_Item
- (Connection lines go to Stock_Out from Transaction and Transaction_Item)

---

### 5.5 Business Expense

**Expense table (shown large/bold):**
- expenseID PK — integer
- userD FK — integer (note: appears as "userD" not "userID" in the paper — likely a typo in the original)
- expenseCategory — string
- description — string
- expenseAmount — float
- expenseDate — timestamp

**Relationships:**
- User 1 → 0..* Expense (from userD FK)
- Expense 1 → connection line going right (toward financial report tables)

---

### 5.6 Financial Report

**Daily_Transaction table:**
- dailyTransactionID PK — integer
- dailySalesReportID FK — integer
- transactionID FK — integer
- userID — integer
- customerID — integer
- transactionDate — (date/time)
- itemCount — integer
- revenue — float
- profit — float

**Daily_Sales_Report table:**
- dailySalesReportID PK — integer
- monthlyReportID FK — integer
- reportDate — date
- totalRevenue — float
- totalExpenses — float
- netProfit — float
- totalProfit — float
- netProfit (duplicate field visible) — float
- transactionCount — integer

**Monthly_Report table:**
- monthlyReportID PK — integer
- yearlyReportID FK — integer
- reportMonth — integer
- reportYear — string
- totalRevenue — float
- totalTransactionProfit — float
- totalExpenses — float
- netProfit — float
- transactionCount — integer
- avgMonthlyRevenue — float
- avgDailyRevenue — float

**Yearly_Report table:**
- yearlyReportID PK — integer
- reportYear — integer
- totalRevenue — float
- totalTransactionProfit — float
- totalExpenses — float
- netProfit — float
- transactionCount — integer
- avgMonthlyRevenue — float
- bestMonth — string
- worstMonth — string

**Relationships:**
- Daily_Transaction 0..* → 1 Daily_Sales_Report
- Daily_Sales_Report 0..* → 1 Monthly_Report
- Monthly_Report 0..* → 1 Yearly_Report
- Daily_Transaction 0..* → (connection to Transaction/Customer from 5.4)

---

## SECTION 6: UI/UX DESIGN

All screenshots show the actual running Flutter application. The sidebar shows "PrintSari Corner" brand name with a store icon and printer icon at the top.

### 6.1 Login Page

**What the screenshot shows:**
- Full-screen light blue/lavender background
- Centered white card with rounded corners
- Top of card: Two icons side by side (shopping bag icon + printer icon)
- Title: **"PrintSari Corner"** (bold)
- Subtitle: **"Retail & Print Services Management System"**
- **Username** label with text field ("Enter your username")
- **Password** label with text field ("Enter your password")
- Dark/black **Login** button spanning full width of card
- Below button: **"Demo Credentials:"** section showing:
  - Owner: owner / owner123
  - Cashier: cashier / cashier123

---

### 6.2 Owner Dashboard

#### Dashboard (Main)
**Sidebar (left):**
- "PrintSari Corner" brand + icon pair
- "Owner Dashboard" subtitle
- Menu items: Dashboard (highlighted/active), Products & Services, Sales Transaction, Inventory, Expenses, Financial Reports, User Management
- At bottom: Logout button

**Main content area:**
- Header: **"Welcome, Dennis Lupase"** / "Here's your business overview for today"
- 4 stat cards in a row:
  - "Today's Sales" — ₱48.00, 1 transaction (with upward trend arrow icon)
  - "Store Sales" — ₱45.00, "Store & items" (with shopping bag icon)
  - "Printing Sales" — ₱3.00, "Print & lamination" (with printer icon)
  - "Today's Expenses" — ₱0.00, "Business costs" (with dollar sign icon)
- 2 wide cards below:
  - "Recent Transactions" — shows "2 items, 12:40:11 AM, Dennis Lupase, ₱48.00"
  - "Low Stock Alert" — shows "All items are well-stocked"

---

#### Products & Services
**What the screenshot shows:**
- Header: **"Products & Services"** / "Manage your store items and printing services"
- Top right: "+ Add Product/Service" button
- Tab bar: "All (9)", "Store Products (3)", "Printing Services (8)"
- "All" tab active
- **Store Products** section:
  - Coke 1L — ₱15.00 • Stock: 50 — edit + delete icons
  - Instant Noodles — ₱15.00 • Stock: 100 — edit + delete icons
  - Bread — ₱25.00 • Stock: 30 — edit + delete icons
- **Printing Services** section (scrolled):
  - Black & White Print (Short) — ₱3.00 • Stock: 1000 • 1 type: print — edit + delete icons
  - (more items below fold)

---

#### Sales Transaction (Owner view)
**What the screenshot shows:**
- Header: **"Sales Transaction"** / "Process customer purchases"
- Top right: "History" button + "+ New Transaction" button
- **Add Items** section:
  - Dropdown showing "Colored Print (Short) — ₱15.00, 500 available"
  - Quantity field showing "1"
  - "+ Add" button
- **Cart Items** section:
  - Instant Noodles — Store — quantity control (−, 1, +) — ₱15.00 — delete icon
- **Order Summary** (right panel):
  - Items: 1
  - Quantity: 1
  - Total: **₱15.00**
  - "Process Transaction" button (dark)
  - Cashier: Dennis Lupase
- Toast notification at bottom right: "Item added to cart" (green check)

---

#### Inventory Management (Owner view)
**What the screenshot shows:**
- Header: **"Inventory Management"** / "Manage and track your inventory"
- Top right: "Stock In - Store" button + "Stock In - Printing" button
- Tab bar: All Products, Store Products, Printing Supplies, Stock History
- **Store Products** section:
  - Coke 1L — ₱42.00 — 59 units — edit icon
  - Instant Noodles — ₱15.00 — 97 units — edit icon
  - Bread — ₱25.00 — 30 units — edit icon
- **Printing Supplies** section:
  - Black & White Print (Short) — ₱3.00 • print — 999 units — edit icon
  - (more items below)

---

#### Expenses
**What the screenshot shows:**
- Header: **"Expense Management"** / "Track and manage business expenses"
- Top right: "+ Record Expense" button
- 3 stat cards:
  - "Today's Expenses" — ₱1500.00, 1 expense (dollar icon, red)
  - "This Month" — ₱1500.00, 1 expense (calendar icon, blue)
  - "Total Expenses" — ₱1500.00, 1 total records (dollar icon)
- **Expense Records** section:
  - "Electricity for month of november" — 11/11/2025 • Electricity — ₱1500.00 (red) — delete icon
- Toast: "Expense recorded successfully" (green check)

---

#### Financial Reports
**What the screenshot shows:**
- Header: **"Financial Reports"** / "View business performance and analytics"
- Top right: "Export Report" button
- Tab bar: Daily, Weekly, Monthly
- 3 stat cards (top row):
  - "Total Sales" — ₱48.00, 1 transaction (trend arrow, blue)
  - "Store Revenue" — ₱45.00, "93.8% of Total" (store icon, blue)
  - "Printing Revenue" — ₱3.00, "6.3% of total" (printer icon, blue)
- 3 stat cards (bottom row):
  - "Total Expenses" — ₱1500.00, 1 expense records (dollar icon, red)
  - "Net Profit" — ₱-1452.00, "-3037.0% margin" (trend arrow, red)
  - "Transactions" — 1, "Avg ₱48.00" (transactions icon)
- **Revenue Breakdown** section:
  - "Store Products" — blue progress bar — ₱45.00
  - "Printing Services" — thin bar — ₱3.00

---

#### User Management
**What the screenshot shows:**
- Header: **"User Management"** / "Manage user accounts and permissions"
- Top right: "+ Add User" button
- 3 stat cards:
  - "Total Users" — 2, "All accounts" (person icon)
  - "Owners" — 1, "Full access" (crown icon)
  - "Cashiers" — 1, "Limited access" (person icon)
- **Owner Accounts** section:
  - Dennis Lupase — @owner — edit + delete icons (light background)
- **Cashier Accounts** section:
  - Zimon Catipay — @cashier — edit + delete icons (light background)
- **Access Permissions** section:
  - "Owner (Full Access):" with bullet list:
    - View Dashboard
    - Manage Products & Services
    - Process Sales Transactions
    - Manage inventory (Add/Edit Stock)
    - Record Business Expenses
    - View Expense Reports
    - (more items cut off)

---

### 6.3 Cashier Dashboard

#### Dashboard (Cashier)
**Sidebar (left):**
- "PrintSari Corner" brand + icon pair
- "Cashier Dashboard" subtitle
- Menu items: Dashboard (highlighted), Sales Transaction, Inventory
- At bottom: Logout button

**Main content area:**
- Header: **"Welcome, Zimon Catipay"** / "Here's your business overview for today"
- 4 stat cards (same layout as owner):
  - "Today's Sales" — ₱48.00, 1 transaction
  - "Store Sales" — ₱45.00, "Store sell items"
  - "Printing Sales" — ₱3.00, "Print & lamination"
  - "Today's Expenses" — ₱1500.00, "Business costs"
- 2 wide cards:
  - "Recent Transactions" — "2 items, 12:08:11 AM, Dennis Lupase, ₱48.00"
  - "Low Stock Alert" — "All items are well-stocked"

---

#### Sales Transaction (Cashier view)
**What the screenshot shows:**
- Same layout as owner POS but cashier name shown
- Header: **"Sales Transaction"** / "Process customer purchases"
- Cashier shown as: "Cashier: Zimon Catipay"
- **Cart Items**:
  - Black & White Print (Short) — Printing — qty: 1 — ₱3.00 — delete
  - Bread — Store — qty: 6 — ₱150.00 — delete
- **Order Summary**:
  - Items: 2
  - Quantity: 7
  - Total: **₱153.00**
  - "Process Transaction" button

---

#### Inventory View (Cashier)
**What the screenshot shows:**
- Same inventory layout but read-only (no "Stock In" buttons visible)
- Header: **"Inventory Management"** / "View current stock levels"
- Sidebar shows only: Dashboard, Sales Transaction, Inventory
- Same tab bar: All Products, Store Products, Printing Supplies, Stock History
- **Store Products**:
  - Coke 1L — ₱43.00 — 50 units
  - Instant Noodles — ₱15.00 — 97 units
  - Bread — ₱25.00 — 30 units
- **Printing Supplies**:
  - Black & White Print (Short) — ₱3.00 • print — 999 units

---

## KEY DESIGN DECISIONS TO REPLICATE

1. **Color scheme**: Light blue/lavender background (`#EEF2FF` range), white cards, dark navy sidebar, blue accent for active states, red for financial losses/expenses
2. **Brand identity**: Two icons side by side (shopping bag + printer) represent the dual nature of the business
3. **Sidebar**: 250px wide, dark background, role-aware menu items
4. **Typography**: Clean sans-serif, "Welcome, [Name]" greeting pattern on dashboard
5. **Card layout**: Stat cards in rows of 4 (top) and 2 (bottom) on dashboard
6. **Table rows**: Product/inventory items shown as rows with name, price, stock count, and action icons aligned right
7. **Role differentiation**: Owner sees all 7 menu items; Cashier sees only 3 (Dashboard, Sales Transaction, Inventory)

---

## STRUCTURAL NOTES FOR PAPER REPRODUCTION

- Page numbers run 1–49, with each major section starting at roughly:
  - PIR: pages 1–7
  - Events Tables: pages 8–17
  - Use Case List: pages 18–24
  - Use Case Diagrams: pages 25–32
  - Use Case Descriptions: pages 33–38
  - Domain Class Diagram: page 39
  - Design Class Diagrams: pages 40–43
  - UI/UX Design: pages 44–49
- All body text uses justified alignment, Times New Roman or similar serif font, 12pt, double-spaced
- Section headings are bold, centered
- Subsection headings are bold, left-aligned
- All tables have bold header row
- Diagrams are centered on the page with white backgrounds
