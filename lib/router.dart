import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printsari_sia/pages/pages.dart';
import 'package:printsari_sia/ui/sidebar.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Row(
          children: [
            SizedBox(width: 250, child: Sidebar()),
            Expanded(child: child),
          ],
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
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
);
