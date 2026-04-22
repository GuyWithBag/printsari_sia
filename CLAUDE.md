# PrintSari Corner — Developer Guide

## Project Overview

Flutter POS + management system for a sari-sari store + printing shop (PrintSari Corner, Magpet, North Cotabato). Two user roles: **Owner** (full access) and **Cashier** (POS + inventory view only).

Backend: Supabase (PostgreSQL + RLS). See the companion repo `printsari_sia_supabase/` for migrations and seed data.

## Tech Stack

- **Flutter** (Dart) — `flutter_hooks`, `provider`, `supabase_flutter`, `google_fonts`, `skeletonizer`
- **Supabase** — Auth, PostgreSQL, RLS, Realtime
- **State**: Provider + HookWidget (`useMemoized`, `useFuture`, `useState`)

## Common Commands

```bash
# Run the app
flutter run

# Supabase (run from printsari_sia_supabase/)
npx supabase db reset        # reset + run all migrations + seed
npx supabase start           # start local Supabase
```

## Key Patterns — READ BEFORE EDITING

See `ai references/IMPORTANT_AI.md` for the full details. Summary of the most important rules:

### 1. No Hive Cache
All disk cache is removed. Providers use in-memory lists only:
- `ProductProvider`, `InventoryProvider`: `clearCache()` nulls the list → next call re-fetches from DB
- `ExpenseProvider`: always fetches fresh (no in-memory list)
- `TransactionProvider`: in-memory list; exposes `completedTransactionCount` (int) for reactive re-fetching

### 2. useMemoized Keys — Stock Display
When re-fetching after a checkout, key the `inventoryFuture` on `completedTransactionCount`, not on the provider itself (which never changes):
```dart
final completedTxCount = transactionProvider.completedTransactionCount;
final inventoryFuture = useMemoized(() {
  inventoryProvider.clearCache();
  return inventoryProvider.getItems();
}, [completedTxCount]);
```

### 3. Provider Context Inside Dialogs
**Never** call `ctx.read<SomeProvider>()` inside a `showDialog` builder. Capture before `showDialog()`:
```dart
final provider = context.read<MyProvider>(); // ← before showDialog
await showDialog(builder: (ctx) => ... provider.doSomething() ...);
```

### 4. UUID Generation
Generate UUIDs on the client using the `uuid` package — never rely on the server:
```dart
import 'package:uuid/uuid.dart';
final id = const Uuid().v4();
```

### 5. Session Restoration After signUp
`supabase.auth.signUp()` replaces the current session. Always save and restore the owner's token after creating a new user. See `IMPORTANT_AI.md` for the exact pattern.

### 6. dashboard_page.dart hardRefresh
Only call `inventoryProvider.clearCache()` and `productProvider.clearAllCache()`. Do NOT call `transactionProvider.clearTransactionsCache()` or `expenseProvider.clearCache()` — those methods no longer exist.

### 7. Machine → Service Relationship
One machine can handle **many** print services. The FK is on `print_services.machine_id REFERENCES machines(id)` (NOT the other way around).

## Database: Key Tables

| Table | Description |
|---|---|
| `profiles` | Users (owner/cashier), `is_active`, `role` |
| `products` | Store products with categories |
| `print_services` | Printing service types; `machine_id` FK → `machines` |
| `machines` | Physical printers; one machine → many services |
| `inventory_items` | Current stock per product batch |
| `transactions` / `transaction_items` | Sales records |
| `expenses` | Business expense log |
| `activity_log` | Audit trail |
| `login_history` | Session tracking |

## Migrations Location

```
printsari_sia_supabase/supabase/migrations/
```

New migrations use timestamp format: `YYYYMMDDHHMMSS_description.sql`

## Project Structure (Flutter)

```
lib/
  controllers/      # AuthController
  pages/            # One file per screen
  providers/        # ProductProvider, InventoryProvider, TransactionProvider, ExpenseProvider
  shared/
    themes/         # colors.dart
    types/
      dtos/         # Data classes (Product, PrintService, Machine, etc.)
      types.dart    # Barrel export
  widgets/          # Reusable widgets (CartPanel, ProductGridPanel, etc.)
```
