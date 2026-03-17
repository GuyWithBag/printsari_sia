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
import 'package:printsari_sia/providers/activity_log_provider.dart';

// '/'

class DashboardPage extends HookWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, MMMM d, yyyy').format(now);

    final transactionProvider = context.read<TransactionProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final activityLogProvider = context.read<ActivityLogProvider>();

    final dataFuture = useMemoized(
      () => Future.wait([
        transactionProvider.getTransactions(),
        expenseProvider.getExpenses(),
        inventoryProvider.getItems(),
        activityLogProvider.getLogs(limit: 5),
      ]),
      [],
    );

    final snapshot = useFuture(dataFuture);

    final isLoading = snapshot.connectionState == ConnectionState.waiting;
    final hasError = snapshot.hasError;

    List<Transaction> allTransactions = [];
    List<Transaction> todayTransactions = [];
    List<Expense> todayExpenses = [];
    List<InventoryItem> inventoryItems = [];
    List<ActivityLog> recentLogs = [];

    if (snapshot.hasData) {
      final data = snapshot.data!;
      allTransactions = data[0] as List<Transaction>;
      final allExpenses = data[1] as List<Expense>;
      inventoryItems = data[2] as List<InventoryItem>;
      recentLogs = data[3] as List<ActivityLog>;

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
    }

    final todayRevenue =
        todayTransactions.fold(0.0, (sum, t) => sum + t.total);
    final todayProfit = todayTransactions.fold(
            0.0, (sum, t) => sum + (t.grossProfit ?? 0)) -
        todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalProducts = inventoryItems.length;
    final recentTransactions = allTransactions.take(5).toList();

    return AppPage(
      body: Skeletonizer(
        enabled: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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
                dateLabel,
                style: GoogleFonts.outfit(fontSize: 14, color: posTextMuted),
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

              // Metric cards row
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
                    childAspectRatio: 2.2,
                    children: [
                      _MetricCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xFF4ADE80),
                        title: "Today's Revenue",
                        value: NumberFormat.currency(
                                symbol: '\u20B1', decimalDigits: 2)
                            .format(todayRevenue),
                        subtitle: '${todayTransactions.length} transactions',
                      ),
                      _MetricCard(
                        icon: Icons.receipt_long_rounded,
                        iconColor: const Color(0xFF60A5FA),
                        title: "Today's Transactions",
                        value: '${todayTransactions.length}',
                        subtitle: 'completed today',
                      ),
                      _MetricCard(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: posPrimary,
                        title: "Today's Profit",
                        value: NumberFormat.currency(
                                symbol: '\u20B1', decimalDigits: 2)
                            .format(todayProfit),
                        subtitle: 'after expenses',
                      ),
                      _MetricCard(
                        icon: Icons.inventory_2_rounded,
                        iconColor: posAccent,
                        title: 'Total Products',
                        value: '$totalProducts',
                        subtitle: 'in inventory',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Two columns: Recent Transactions + Alerts
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _RecentTransactionsPanel(
                              transactions: recentTransactions),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _AlertsPanel(items: inventoryItems),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _RecentTransactionsPanel(
                          transactions: recentTransactions),
                      const SizedBox(height: 16),
                      _AlertsPanel(items: inventoryItems),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Activity
              _RecentActivityPanel(logs: recentLogs),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Glass panel wrapper ----------

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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: posTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
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
              final dateStr = DateFormat('MMM d, h:mm a').format(t.date);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: posPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: posPrimary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.transactionNumber,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Store: ${NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2).format(t.storeRevenue)} | Print: ${NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2).format(t.printingRevenue)}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
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
                          NumberFormat.currency(
                                  symbol: '\u20B1', decimalDigits: 2)
                              .format(t.total),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4ADE80),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.outfit(
                              fontSize: 10, color: posTextMuted),
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

// ---------- Alerts panel ----------

class _AlertsPanel extends StatelessWidget {
  final List<InventoryItem> items;
  const _AlertsPanel({required this.items});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = items.where((i) => i.stock < 10).toList();

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Low stock alerts
          if (lowStockItems.isEmpty && items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No alerts at this time.',
                style: GoogleFonts.outfit(color: posTextMuted, fontSize: 13),
              ),
            ),
          ...lowStockItems.map((item) => _AlertItemTile(item: item)),

          // Expiring soon
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ExpiringSoonSection(items: items),
          ],
        ],
      ),
    );
  }
}

class _AlertItemTile extends StatelessWidget {
  final InventoryItem item;
  const _AlertItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: InventoryItem.getProduct(item),
      builder: (context, snap) {
        final name = snap.data?.name ?? 'Product #${item.productId}';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFBBF24), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$name - ${item.stock.toInt()} left',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Low Stock',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpiringSoonSection extends StatelessWidget {
  final List<InventoryItem> items;
  const _ExpiringSoonSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ExpiryInfo>>(
      future: _getExpiring(items),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snap.data!.map((info) {
            final daysLeft =
                info.expiryDate.difference(DateTime.now()).inDays;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: Color(0xFFF87171), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${info.name} - expires in $daysLeft days',
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Expiring',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF87171),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<_ExpiryInfo>> _getExpiring(List<InventoryItem> items) async {
    final results = <_ExpiryInfo>[];
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 7));

    for (final item in items) {
      try {
        final product = await InventoryItem.getProduct(item);
        if (product.expiryDate != null &&
            product.expiryDate!.isAfter(now) &&
            product.expiryDate!.isBefore(threshold)) {
          results.add(_ExpiryInfo(
              name: product.name, expiryDate: product.expiryDate!));
        }
      } catch (_) {
        // skip items whose products can't be fetched
      }
    }
    return results;
  }
}

class _ExpiryInfo {
  final String name;
  final DateTime expiryDate;
  _ExpiryInfo({required this.name, required this.expiryDate});
}

// ---------- Recent Activity panel ----------

class _RecentActivityPanel extends StatelessWidget {
  final List<ActivityLog> logs;
  const _RecentActivityPanel({required this.logs});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No recent activity.',
                  style: GoogleFonts.outfit(color: posTextMuted),
                ),
              ),
            )
          else
            ...logs.map((log) {
              final icon = _categoryIcon(log.action?.category);
              final timeStr =
                  DateFormat('MMM d, h:mm a').format(log.timestamp);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: posSurfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: posTextMuted, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.action?.actionName ?? 'Action',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.description,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: posTextMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeStr,
                          style: GoogleFonts.outfit(
                              fontSize: 10, color: posTextMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.performedBy,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: posAccent,
                            fontWeight: FontWeight.w500,
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

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'transaction':
        return Icons.receipt_long_rounded;
      case 'product':
        return Icons.inventory_2_rounded;
      case 'inventory':
        return Icons.all_inbox_rounded;
      case 'user':
        return Icons.person_rounded;
      case 'expense':
        return Icons.attach_money_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
