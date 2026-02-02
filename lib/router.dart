import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printsari_sia/controllers/auth_controller.dart';
import 'package:printsari_sia/pages/login_page.dart';
import 'package:printsari_sia/pages/pages.dart'; // ← assuming LoginPage is here
import 'package:printsari_sia/ui/sidebar.dart';
import 'package:provider/provider.dart';

final router = GoRouter(
  initialLocation: '/login', // ← optional but often useful
  routes: [
    ShellRoute(
      builder: (context, state, child) => MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthController())],
        child: child,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginPage(),
            ),
            ShellRoute(
              builder: (context, state, child) {
                return Row(
                  children: [
                    const SizedBox(width: 250, child: Sidebar()),
                    Expanded(child: child),
                  ],
                );
              },
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DashboardPage(),
                ),
                GoRoute(
                  path: '/pos',
                  builder: (context, state) => const POSTerminalPage(),
                ),
                GoRoute(
                  path: '/activity-log',
                  builder: (context, state) => const ActivityLogPage(),
                ),
                GoRoute(
                  path: '/inventory',
                  builder: (context, state) => const InventoryPage(),
                ),
                GoRoute(
                  path: '/financial-reports',
                  builder: (context, state) => const FinancialReportsPage(),
                ),
                GoRoute(
                  path: '/products-services',
                  builder: (context, state) => const ProductsAndServicesPage(),
                ),
                GoRoute(
                  path: '/expenses',
                  builder: (context, state) => const BusinessExpensesPage(),
                ),
                GoRoute(
                  path: '/users',
                  builder: (context, state) => const UserManagementPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Public routes — no sidebar

    // All authenticated / main app routes — wrapped with sidebar
  ],
);
