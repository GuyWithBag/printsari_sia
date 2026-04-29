# IMPORTANT — Read before making any changes

## Supabase

- Reset command: `npx supabase db reset` (run from the supabase repo root)
- Migrations go in: `printsari_sia_supabase/supabase/migrations/`
- Seed file: `printsari_sia_supabase/supabase/seed.sql`

## UUID Generation

**Always generate UUIDs locally in Dart/Flutter — never rely on the server to generate them before insert.**

When inserting records that need a UUID (e.g. `transaction_number`, any client-generated ID), generate it on the client side using the `uuid` package:

```dart
import 'package:uuid/uuid.dart';
const _uuid = Uuid();
final id = _uuid.v4(); // e.g. '110e8400-e29b-41d4-a716-446655440000'
```

This avoids race conditions and lets you reference the ID immediately after insert without waiting for a server round-trip.

## RLS — User Creation Flow

`supabase.auth.signUp()` in Flutter **automatically signs in the new user**, replacing the current session. This means:

- After `signUp()`, `auth.uid()` = the **new user's** UUID, not the owner's.
- The new user has no profile row yet, so `is_owner()` returns false.
- Any INSERT policy that calls `is_owner()` will block the profile creation.

**Fix (already applied in migration `20260422020000_rewrite_all_rls.sql`):**
The `profiles` INSERT policy uses `WITH CHECK (user_id = auth.uid())` — the newly-signed-in user inserts their own profile row. Owner-gating for auth user creation is enforced in the Flutter UI only.

## Session Restoration After signUp

After `signUp()` completes and the new user's profile is inserted, **always restore the owner's session** so subsequent operations (add product, deactivate user, etc.) run under the correct identity.

**Fix applied in `_showAddUserDialog` (user_management_page.dart):**

```dart
// 1. Capture the auth controller BEFORE showDialog (valid context)
final authController = context.read<AuthController>();

// 2. Save owner's REFRESH token BEFORE signUp
//    ⚠️  Do NOT save the access token — setSession(accessToken) will fail.
//    In supabase_flutter 2.x, setSession() internally refreshes using the
//    in-memory refresh token, which is replaced by signUp(). Use
//    refreshSession(refreshToken:) instead, which bypasses in-memory state.
final ownerRefreshToken = supabase.auth.currentSession?.refreshToken;

// 3. signUp — this replaces the current session with the new user's session
final authResponse = await supabase.auth.signUp(email: ..., password: ...);

// 4. Insert new user's profile (new user's session is active, RLS allows it)
await supabase.from('profiles').insert({...});

// 5. Restore owner's session using the saved refresh token
if (ownerRefreshToken != null) {
  await supabase.auth.refreshSession(ownerRefreshToken); // positional, not named
  await authController.restoreSession(); // syncs AuthController's local state
}
```

Without step 5, the owner is invisibly logged in as the new cashier. This causes:
- Products INSERT to fail with RLS error (cashier can't add products)
- Deactivate button to silently fail (wrong user identity)
- Inventory stock-in to fail
- Any owner-gated operation to break

**Why `setSession(accessToken)` fails (do not revert to it):**
`setSession` in gotrue-dart v2 validates by calling the refresh endpoint using the **currently stored** refresh token. After `signUp()`, the stored refresh token is the new user's — not the owner's. Passing the owner's access token with the new user's refresh token returns HTTP 400 "Refresh token is not valid". Using `refreshSession(refreshToken: ownerRefreshToken)` skips the in-memory state entirely and works correctly.

## No Hive Cache

All Hive disk cache has been **completely removed** from all providers (inventory, product, expense, transaction). Do not re-add it.

- `InventoryProvider`, `ProductProvider`: use in-memory `_items`/`_products`/`_services` lists. `clearCache()` sets the list to null so the next call re-fetches.
- `ExpenseProvider`: **no in-memory list at all** — `getExpenses()` always hits the DB fresh. This is intentional so POS-generated expenses are immediately visible on the Business Expenses page.
- `TransactionProvider`: uses in-memory `_transactions` list but no Hive. Also exposes `completedTransactionCount` (int, incremented on each successful `checkout()`) so `BusinessExpensesPage` can watch it and auto-refresh.

Stale Hive cache was causing: inventory stock appearing unchanged after POS sales, expense totals not updating, old product data after edits.

## Provider Context Inside Dialogs

**Never call `ctx.read<SomeProvider>()` inside a `showDialog` builder.** The dialog's `ctx` does not carry the app's provider tree.

**Always capture the provider reference BEFORE `showDialog()`:**

```dart
// ✅ Correct — captured from the page's valid context
final inventoryProvider = context.read<InventoryProvider>();

await showDialog(
  builder: (ctx) => StatefulBuilder(
    builder: (ctx, setState) {
      // Use the captured reference, NOT ctx.read<InventoryProvider>()
      await inventoryProvider.stockIn(...);
    },
  ),
);
```

This pattern is required in `_showStockInDialog`, `_showNewStockInDialog`, and any other dialog that needs provider access.

## AuthController — capture before showDialog

Same rule applies to `AuthController`. If you need it inside a dialog's `onPressed`, capture it before `showDialog()`:

```dart
final authController = context.read<AuthController>(); // before showDialog
await showDialog(
  builder: (ctx) => ...,
);
```

## Business Expenses Auto-refresh After POS Sale

`BusinessExpensesPage` watches `TransactionProvider.completedTransactionCount` as a `useMemoized` key. When a checkout completes, `completedTransactionCount` increments → `notifyListeners()` fires → the page rebuilds → `getExpenses()` fetches fresh data.

Do not remove this dependency from the `useMemoized` call.

## dashboard_page.dart — hardRefresh

`dashboard_page.dart::hardRefresh()` must NOT call `transactionProvider.clearTransactionsCache()` or `expenseProvider.clearCache()` — those methods no longer exist. Only call `inventoryProvider.clearCache()` and `productProvider.clearAllCache()` before incrementing `refreshKey`.

## Activity Log Filters

The filter dropdown labels (e.g. "Transactions", "Inventory Restock") do **not** match the exact `action_name` strings stored in the DB. Filtering uses `_matchesActionFilter(log, filter)` in `activity_log_page.dart`, which maps each label to a category check + case-insensitive partial name match. Do not revert to exact `actionName ==` matching.
