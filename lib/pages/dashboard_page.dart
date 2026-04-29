import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/providers/transaction_provider.dart';
import 'package:printsari_sia/providers/expense_provider.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';

// '/'

class DashboardPage extends HookWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final refreshKey = useState(0);

    final transactionProvider = context.read<TransactionProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final productProvider = context.read<ProductProvider>();

    void hardRefresh() {
      inventoryProvider.clearCache();
      productProvider.clearAllCache();
      refreshKey.value++;
    }

    final dataFuture = useMemoized(
      () => Future.wait([
        transactionProvider.getTransactions(),
        expenseProvider.getExpenses(),
        inventoryProvider.getItems(),
        productProvider.getProducts(),
        productProvider.getServiceTypes(),
      ]),
      [refreshKey.value],
    );

    final snapshot = useFuture(dataFuture);

    final isLoading = snapshot.connectionState == ConnectionState.waiting;
    final hasError = snapshot.hasError;

    final now = DateTime.now();
    List<Transaction> todayTransactions = [];
    List<Expense> todayExpenses = [];
    List<InventoryItem> inventoryItems = [];
    List<Product> products = [];
    List<ServiceType> printServices = [];
    List<Transaction> recentTransactions = [];

    if (snapshot.hasData) {
      final data = snapshot.data!;
      final allTransactions = data[0] as List<Transaction>;
      final allExpenses = data[1] as List<Expense>;
      inventoryItems = data[2] as List<InventoryItem>;
      products = data[3] as List<Product>;
      printServices = data[4] as List<ServiceType>;

      todayTransactions = allTransactions.where((t) {
        return t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day;
      }).toList();

      todayExpenses = allExpenses.where((e) {
        return e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day;
      }).toList();

      recentTransactions = allTransactions.take(5).toList();
    }

    final todayRevenue =
        todayTransactions.fold(0.0, (sum, t) => sum + t.total);
    final storeRevenue =
        todayTransactions.fold(0.0, (sum, t) => sum + t.storeRevenue);
    final printingRevenue =
        todayTransactions.fold(0.0, (sum, t) => sum + t.printingRevenue);
    final todayProfit = todayRevenue -
        todayExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final currFmt =
        NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);

    // All products are store products now (no FK category)
    final storeProducts = products;
    // Map productId -> InventoryItem for stock lookup
    final inventoryByProduct = <int, InventoryItem>{};
    for (final item in inventoryItems) {
      if (item.productId != null) {
        inventoryByProduct[item.productId!] = item;
      }
    }

    return AppPage(
      body: Skeletonizer(
        enabled: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome back! Here's your business overview.",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: posTextMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Refresh from server',
                    onPressed: hardRefresh,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (hasError)
                _GlassPanel(
                  child: Center(
                    child: Text(
                      'Failed to load dashboard data: ${snapshot.error}',
                      style: GoogleFonts.outfit(color: Colors.redAccent),
                    ),
                  ),
                ),

              // Metric cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 500
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: crossCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.9,
                    children: [
                      _MetricCard(
                        icon: Icons.attach_money_rounded,
                        iconColor: const Color(0xFF4ADE80),
                        title: "Today's Revenue",
                        value: currFmt.format(todayRevenue),
                        subtitle:
                            '${todayTransactions.length} transactions',
                      ),
                      _MetricCard(
                        icon: Icons.store_rounded,
                        iconColor: const Color(0xFF60A5FA),
                        title: 'Store Revenue',
                        value: currFmt.format(storeRevenue),
                        subtitle: 'Sari-sari sales',
                      ),
                      _MetricCard(
                        icon: Icons.print_rounded,
                        iconColor: const Color(0xFFA78BFA),
                        title: 'Printing Revenue',
                        value: currFmt.format(printingRevenue),
                        subtitle: 'Printing services',
                      ),
                      _MetricCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: todayProfit >= 0
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFEF4444),
                        title: "Today's Profit",
                        value: currFmt.format(todayProfit),
                        subtitle: 'Revenue - Expenses',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              _RecentTransactionsPanel(transactions: recentTransactions),
              const SizedBox(height: 24),

              // Store Inventory + Printing Supplies
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _StoreInventoryPanel(
                            products: storeProducts,
                            inventoryByProduct: inventoryByProduct,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PrintingSuppliesPanel(
                            services: printServices,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _StoreInventoryPanel(
                        products: storeProducts,
                        inventoryByProduct: inventoryByProduct,
                      ),
                      const SizedBox(height: 16),
                      _PrintingSuppliesPanel(services: printServices),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Glass panel ----------

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassPanel({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

// ---------- Metric card ----------

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: posTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(fontSize: 11, color: posTextMuted),
          ),
        ],
      ),
    );
  }
}

// ---------- Recent Transactions panel ----------

class _RecentTransactionsPanel extends StatelessWidget {
  final List<Transaction> transactions;
  const _RecentTransactionsPanel({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No transactions yet.',
                  style: GoogleFonts.outfit(color: posTextMuted),
                ),
              ),
            )
          else
            ...transactions.map((t) {
              final dateStr =
                  DateFormat('M/d/yyyy, h:mm:ss a').format(t.date);
              final itemCount = t.items?.length ?? 0;
              final cashierName = t.cashier?.name;
              final currFmt = NumberFormat.currency(
                symbol: '\u20B1',
                decimalDigits: 2,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$itemCount items',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateStr${cashierName != null ? ' \u00B7 $cashierName' : ''}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: posTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currFmt.format(t.total),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Store: ${currFmt.format(t.storeRevenue)}  Print: ${currFmt.format(t.printingRevenue)}',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: posTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ---------- Store Inventory panel ----------

class _StoreInventoryPanel extends StatelessWidget {
  final List<Product> products;
  final Map<int, InventoryItem> inventoryByProduct;

  const _StoreInventoryPanel({
    required this.products,
    required this.inventoryByProduct,
  });

  @override
  Widget build(BuildContext context) {
    final currFmt =
        NumberFormat.currency(symbol: '\u20B1', decimalDigits: 0);

    final lowStockCount = products.where((p) {
      final inv = inventoryByProduct[p.id];
      if (inv == null || inv.reorderLevel == null) return false;
      return inv.stock > 0 && inv.stock <= inv.reorderLevel!;
    }).length;
    final outOfStockCount = products.where((p) {
      final inv = inventoryByProduct[p.id];
      return (inv?.stock ?? 0) <= 0;
    }).length;

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Store Inventory Status',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (outOfStockCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$outOfStockCount out of stock',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (lowStockCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$lowStockCount low stock',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.orange.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (products.isEmpty)
            Text(
              'No store products.',
              style: GoogleFonts.outfit(color: posTextMuted),
            )
          else
            ...products.map((p) {
              final inv = inventoryByProduct[p.id];
              final stock = inv?.stock.toInt() ?? 0;
              final price = inv?.retailPrice ?? 0;
              final isOutOfStock = stock <= 0;
              final isLowStock = !isOutOfStock &&
                  inv?.reorderLevel != null &&
                  (inv!.stock) <= inv.reorderLevel!;
              final stockColor = isOutOfStock
                  ? Colors.red.shade400
                  : isLowStock
                      ? Colors.orange.shade400
                      : Colors.white;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          if (isLowStock)
                            Text(
                              'Low stock',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.orange.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (isOutOfStock)
                            Text(
                              'Out of stock',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            Text(
                              p.productCategory,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: posTextMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$stock units',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: stockColor,
                          ),
                        ),
                        Text(
                          currFmt.format(price),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: posTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ---------- Printing Supplies panel ----------

class _PrintingSuppliesPanel extends StatelessWidget {
  final List<ServiceType> services;
  const _PrintingSuppliesPanel({required this.services});

  @override
  Widget build(BuildContext context) {
    final currFmt =
        NumberFormat.currency(symbol: '\u20B1', decimalDigits: 0);

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Printing Services',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (services.isEmpty)
            Text(
              'No service types.',
              style: GoogleFonts.outfit(color: posTextMuted),
            )
          else
            ...services.map((s) {
              final sellingPrice = s.cost?.serviceSellingPrice;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          if (s.service != null)
                            Text(
                              s.service!.name,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: posTextMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      sellingPrice != null
                          ? currFmt.format(sellingPrice)
                          : '—',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
