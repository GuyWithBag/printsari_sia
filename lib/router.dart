import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printsari_sia/controllers/auth_controller.dart';
import 'package:printsari_sia/pages/login_page.dart';
import 'package:printsari_sia/pages/pages.dart';
import 'package:printsari_sia/providers/providers.dart';
import 'package:printsari_sia/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isOnLogin = state.uri.toString() == '/login';

    if (session == null && !isOnLogin) return '/login';
    if (session != null && isOnLogin) return '/';
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => InventoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => ActivityLogProvider()),
        ],
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
