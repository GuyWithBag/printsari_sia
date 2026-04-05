# Fix Problems

## Bug #1 — POS Checkout FK Violation (print services)

**Error:** `PostgrestException: insert or update on table "transaction_items" violates foreign key constraint "transaction_items_product_id_fkey", Key is not present in table "products".`

**Root cause:**
In `product_grid_panel.dart` (`_showPageCountDialog`), when a print service is added to the cart, `productId: service.id` is passed to `TransactionItem`. The `service.id` comes from the `print_services` table — it does NOT exist in the `products` table. When `transaction_items` is inserted, the FK constraint on `product_id` (which references `products.id`) fails.

**Fix:**
- Make `productId` nullable (`int?`) in `TransactionItem` model and everywhere it is used.
- Pass `productId: null` for print service cart items in `_showPageCountDialog`.
- Update the insert in `transaction_provider.dart` to only include `product_id` when it is non-null.

**Files:** `lib/shared/types/dtos/transaction_item.dart`, `lib/widgets/product_grid_panel.dart`, `lib/providers/transaction_provider.dart`

---

## Bug #2 — Store Products have no Quantity Dialog in POS

**Problem:**
In the Services tab, tapping a service opens a page-count dialog. In the Store tab, tapping a product immediately adds 1 unit with no prompt. Should show a quantity dialog so the cashier can select how many units to add.

**Fix:**
Add a `_showQuantityDialog(context, product, inventoryItem)` in `product_grid_panel.dart`, similar to `_showPageCountDialog`. On confirm, add the item with the chosen quantity.

**File:** `lib/widgets/product_grid_panel.dart`

---

## Bug #3 — Add User Error: Email Address Invalid

**Error:** `AuthApiException: Email address "asd@asd.com" is invalid, statusCode: 400, code: email_address_invalid`

**Root cause:**
`supabase.auth.signUp()` is used to create users from the admin UI. Supabase validates email deliverability (MX records), so non-real domains like `asd.com` (no MX) are rejected.

**Fix:**
Auto-generate an internal email from the username: `${username}@printsari.internal`. The user's display identity is their username + name; the email is just an auth credential. Remove the email field from the Add User dialog — the system generates the email automatically from the username.

> **Proper long-term fix:** Use a Supabase Edge Function or RPC with service-role key to call `supabase.auth.admin.createUser()`, which skips email validation entirely.

**File:** `lib/pages/user_management_page.dart`

---

## Feature #4 — Role-Based Access: Cashier Tab Restrictions

**Current state (wrong):**
Cashier can see: Dashboard, POS Terminal, Activity Log, Inventory.

**Required:**
- **Owner** — all 8 tabs (full access)
- **Cashier** — only 3 tabs: Dashboard (view only), Products & Services (view only), POS Terminal (full use)

**Fix:**
Update `lib/shared/data/sitemap_items.dart`:
- Remove `UserRoleType.cashier` from Activity Log and Inventory
- Add `UserRoleType.cashier` to Products & Services

**File:** `lib/shared/data/sitemap_items.dart`

---

## Feature #5 — Products & Services: View-Only Mode for Cashier

**Problem:**
When cashier accesses Products & Services (after fix #4 above), they can still see Add/Edit/Delete buttons.

**Fix:**
In `products_and_services_page.dart`, read the user's role from `AuthController`. If the role is cashier, hide the Add, Edit, and Delete buttons.

**File:** `lib/pages/products_and_services_page.dart`

---

## Feature #6 — Inventory: Add Stock In Button + Expiry Date per Batch

**Requirements:**
- Add a **Stock In** button for products in the Inventory page.
- The Stock In form must include an **expiry date** field.
- Each stock-in entry with a different expiry date = a **separate inventory card** (batch).
- On Products & Services page, all batches of the same product show **combined count**.

**Fix:**
1. Add `expiryDate` (`DateTime?`) field to `InventoryItem` model.
2. Add `_showStockInDialog(context, product)` in `inventory_page.dart` that inserts a new `inventory_items` row with `product_id`, `stock`, `retail_price`, and `expiry_date`.
3. Add a **Stock In** button per inventory card or per product group header.

> **DB change required:** Add `expiry_date DATE` column to the `inventory_items` table in Supabase.

**Files:** `lib/shared/types/dtos/inventory_item.dart`, `lib/pages/inventory_page.dart`, `lib/widgets/inventory_card.dart`

---

## Feature #7 — POS: Per-Batch Product Cards (separate card per expiry date)

**Requirements:**
In the POS Store tab, each inventory batch (different expiry date) should appear as a **separate card**, not grouped. The cashier selects the card matching the expiry date of the actual item being sold.

**Current behavior:**
POS store grid iterates over `products`, finds ONE `inventoryItem` per product (`.firstOrNull`), and shows one card per product.

**Fix:**
Change the POS store grid to iterate over **inventory items** (one card per batch), not products. Show the product name + expiry date on each card. Only show in-stock batches.

**File:** `lib/widgets/product_grid_panel.dart`
