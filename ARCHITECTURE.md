# PrintSari SIA - Architecture Guide

A Point of Sale (POS) system for a combined Sari-Sari store and printing business, built with Flutter.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Routing | `go_router` |
| State Management | `provider` + `flutter_hooks` |
| Backend / Database | Supabase (PostgreSQL + Auth) |
| Desktop Window | `window_manager` |
| UI Extras | `skeletonizer`, `flutter_animate`, `particles_flutter` |

---

## Folder Structure

```
lib/
├── main.dart                  # Entry point - Supabase init, URL strategy
├── app.dart                   # Root MaterialApp with theme and router
├── router.dart                # All route definitions (go_router)
│
├── controllers/               # App-wide business logic (ChangeNotifiers)
│   ├── auth_controller.dart   # Auth state, session, role checks
│   └── controllers.dart       # Barrel export
│
├── providers/                 # Data-fetching providers
│   ├── inventory_provider.dart
│   └── providers.dart         # Barrel export
│
├── pages/                     # One file per screen
│   ├── login_page.dart
│   ├── dashboard_page.dart
│   ├── pos_terminal_page.dart
│   ├── activity_log_page.dart
│   ├── inventory_page.dart
│   ├── financial_reports_page.dart
│   ├── products_and_services_page.dart
│   ├── business_expenses_page.dart
│   ├── user_management_page.dart
│   └── pages.dart             # Barrel export
│
├── widgets/                   # Reusable UI components
│   ├── app_page.dart          # Base page wrapper
│   ├── sidebar.dart           # Navigation sidebar
│   ├── inventory_card.dart
│   ├── circular_tab.dart
│   ├── circular_tab_bar.dart
│   └── widgets.dart           # Barrel export
│
└── shared/                    # Shared resources used across the app
    ├── data/
    │   └── sitemap_items.dart # Route definitions with role access
    ├── page_transitions/
    │   └── slide_transition.dart
    ├── themes/
    │   ├── main_theme.dart    # Global ThemeData
    │   ├── colors.dart
    │   └── theme_constants.dart
    └── types/
        ├── sitemap_item.dart  # SiteMapItem model
        ├── types.dart         # Barrel export for all types
        └── dtos/              # 36+ Data Transfer Objects
            ├── product.dart
            ├── inventory_item.dart
            ├── transaction.dart
            ├── profile.dart
            ├── expense.dart
            ├── print_order.dart
            └── ...            # See types.dart for full list
```

### Other top-level folders

| Folder | Purpose |
|--------|---------|
| `assets/` | SVG icons used in the sidebar |
| `linux/`, `macos/`, `windows/`, `web/` | Platform-specific runner code |
| `test/` | Test files |

### Barrel exports

Every module folder has a barrel file (e.g. `pages.dart`, `widgets.dart`, `types.dart`) that re-exports everything in that folder. This keeps imports clean — you only need one import per module:

```dart
import 'package:printsari_sia/pages/pages.dart';
```

---

## Navigation & Routing

Routing is defined in `lib/router.dart` using **go_router** with nested `ShellRoute`s.

### Route Map

```
ShellRoute                          ← Wraps everything with providers
│                                     (AuthController, InventoryProvider)
│
└── ShellRoute                      ← Scaffold wrapper
    │
    ├── /login          → LoginPage           (no sidebar)
    │
    └── ShellRoute                  ← Adds the Sidebar layout
        │
        ├── /                → DashboardPage
        ├── /pos             → POSTerminalPage
        ├── /activity-log    → ActivityLogPage
        ├── /inventory       → InventoryPage
        ├── /financial-reports → FinancialReportsPage
        ├── /products-services → ProductsAndServicesPage
        ├── /expenses        → BusinessExpensesPage
        └── /users           → UserManagementPage
```

### How it works

1. The **outermost ShellRoute** injects providers (`MultiProvider`) so all child routes have access to `AuthController` and `InventoryProvider`.
2. The **middle ShellRoute** wraps everything in a `Scaffold`.
3. The **login route** sits outside the sidebar shell, so it renders full-screen.
4. The **innermost ShellRoute** renders a `Row` with a fixed-width `Sidebar` (250px) on the left and the page content on the right via `Expanded`.

### Adding a new page

1. Create the page file in `lib/pages/` (e.g. `settings_page.dart`).
2. Export it from `lib/pages/pages.dart`.
3. Add a `GoRoute` inside the sidebar `ShellRoute`'s `routes` list in `lib/router.dart`.
4. Add a `SiteMapItem` entry in `lib/shared/data/sitemap_items.dart` so it shows up in the sidebar.

---

## Role-Based Access

There are two roles: **owner** and **cashier**.

Access is controlled in `lib/shared/data/sitemap_items.dart`. Each `SiteMapItem` has a `roles` list that determines which roles can see and access that page.

| Page | Cashier | Owner |
|------|---------|-------|
| Dashboard | Yes | Yes |
| POS Terminal | Yes | Yes |
| Activity Log | Yes | Yes |
| Inventory | Yes | Yes |
| Financial Reports | No | Yes |
| Products & Services | No | Yes |
| Business Expenses | No | Yes |
| User Management | No | Yes |

The `Sidebar` widget filters menu items based on the current user's role via `AuthController.hasRoles()`.

---

## State Management

The project uses two patterns depending on scope:

### App-wide state → Provider + ChangeNotifier

- **AuthController** — manages auth session, user profile, and role. Injected at the router level so every page can access it via `Provider.of<AuthController>(context)`.
- **InventoryProvider** — fetches inventory data from Supabase.

### Local/page-level state → flutter_hooks

Pages use `HookWidget` instead of `StatefulWidget` for cleaner local state:

```dart
class LoginPage extends HookWidget {
  final email = useTextEditingController();
  final password = useTextEditingController();
  final isLoading = useState(false);
  // ...
}
```

---

## Data Layer (DTOs)

All data models live in `lib/shared/types/dtos/`. They follow a consistent pattern:

```dart
class Product {
  final String id;
  final String name;
  // ...

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() => { ... };
  Map<String, dynamic> toInsertJson() => { ... };  // Without id, for inserts
}
```

Enum-backed types (e.g. `UserRoleType`, `PaymentMethodType`) use string values and provide a `fromString()` factory for safe parsing from the database.

### Data flow

```
Supabase DB  →  Provider.getItems()  →  DTO.fromJson()  →  UI (FutureBuilder)
```

Pages typically use `FutureBuilder` combined with `Skeletonizer` for loading states:

```dart
FutureBuilder(
  future: inventory.getItems(),
  builder: (context, snapshot) {
    return Skeletonizer(
      enabled: !snapshot.hasData,
      child: // actual UI
    );
  },
)
```

---

## Theming

The global theme is in `lib/shared/themes/main_theme.dart`.

- Light mode, grey[200] page background, white cards
- Rounded corners (8-12px)
- Clean, minimal business-focused design
- Colors and constants are split into `colors.dart` and `theme_constants.dart`

---

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Pages | `*_page.dart` | `dashboard_page.dart` |
| DTOs | `snake_case.dart` | `inventory_item.dart` |
| Enum types | `*_type.dart` | `user_role_type.dart` |
| Barrel exports | module name `.dart` | `pages.dart`, `types.dart` |
| Widgets | descriptive snake_case | `inventory_card.dart` |

---

## Quick Reference

| What | Where |
|------|-------|
| App entry point | `lib/main.dart` |
| Root widget | `lib/app.dart` |
| Route definitions | `lib/router.dart` |
| Sidebar menu items | `lib/shared/data/sitemap_items.dart` |
| Auth logic | `lib/controllers/auth_controller.dart` |
| Theme | `lib/shared/themes/main_theme.dart` |
| All data models | `lib/shared/types/types.dart` (barrel) |
| Supabase config | `lib/main.dart` (top of file) |
