import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/expense_provider.dart';
import 'package:printsari_sia/providers/transaction_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FinancialReportsPage extends HookWidget {
  const FinancialReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 3);
    final currentIndex = useState(0);
    final transactionProvider = context.watch<TransactionProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final dataFuture = useMemoized(
      () => Future.wait([
        transactionProvider.getTransactions(),
        expenseProvider.getExpenses(),
      ]),
      [],
    );
    final snapshot = useFuture(dataFuture);

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Financial Reports',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Track revenue, expenses, and profit across time periods',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
          ),
        ),
      ),
      body: Skeletonizer(
        enabled: !snapshot.hasData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularTabBar(
                tabController: tabController,
                children: [
                  CircularTab(
                    tabController: tabController,
                    index: 0,
                    label: 'Daily',
                    icon: Icons.today_outlined,
                    indexState: currentIndex,
                  ),
                  CircularTab(
                    tabController: tabController,
                    index: 1,
                    label: 'Weekly',
                    icon: Icons.date_range_outlined,
                    indexState: currentIndex,
                  ),
                  CircularTab(
                    tabController: tabController,
                    index: 2,
                    label: 'Monthly',
                    icon: Icons.calendar_month_outlined,
                    indexState: currentIndex,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: snapshot.hasData
                    ? TabBarView(
                        controller: tabController,
                        children: [
                          _ReportView(
                            transactions:
                                snapshot.data![0] as List<Transaction>,
                            expenses: snapshot.data![1] as List<Expense>,
                            periodDays: 0,
                            periodLabel: 'Today',
                          ),
                          _ReportView(
                            transactions:
                                snapshot.data![0] as List<Transaction>,
                            expenses: snapshot.data![1] as List<Expense>,
                            periodDays: 7,
                            periodLabel: 'Last 7 Days',
                          ),
                          _ReportView(
                            transactions:
                                snapshot.data![0] as List<Transaction>,
                            expenses: snapshot.data![1] as List<Expense>,
                            periodDays: 30,
                            periodLabel: 'Last 30 Days',
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: posPrimary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Expense> expenses;
  final int periodDays;
  final String periodLabel;

  const _ReportView({
    required this.transactions,
    required this.expenses,
    required this.periodDays,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime cutoff;
    if (periodDays == 0) {
      cutoff = startOfToday;
    } else {
      cutoff = startOfToday.subtract(Duration(days: periodDays));
    }

    final filteredTransactions =
        transactions.where((t) => t.date.isAfter(cutoff)).toList();
    final filteredExpenses =
        expenses.where((e) => e.date.isAfter(cutoff)).toList();

    final totalRevenue =
        filteredTransactions.fold(0.0, (sum, t) => sum + t.total);
    final storeRevenue =
        filteredTransactions.fold(0.0, (sum, t) => sum + t.storeRevenue);
    final printingRevenue =
        filteredTransactions.fold(0.0, (sum, t) => sum + t.printingRevenue);
    final totalExpenses =
        filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final profit = totalRevenue - totalExpenses;
    final profitMargin =
        totalRevenue > 0 ? (profit / totalRevenue * 100) : 0.0;

    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            periodLabel,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: 'Total Revenue',
                value: currencyFormat.format(totalRevenue),
                icon: Icons.trending_up,
                color: posPrimary,
              ),
              _MetricCard(
                label: 'Store Revenue',
                value: currencyFormat.format(storeRevenue),
                icon: Icons.store_outlined,
                color: posAccent,
              ),
              _MetricCard(
                label: 'Printing Revenue',
                value: currencyFormat.format(printingRevenue),
                icon: Icons.print_outlined,
                color: const Color(0xFF60A5FA),
              ),
              _MetricCard(
                label: 'Total Expenses',
                value: currencyFormat.format(totalExpenses),
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFFEF4444),
              ),
              _MetricCard(
                label: 'Profit',
                value: currencyFormat.format(profit),
                icon: Icons.account_balance_wallet_outlined,
                color: profit >= 0
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
              ),
              _MetricCard(
                label: 'Transactions',
                value: '${filteredTransactions.length}',
                icon: Icons.receipt_outlined,
                color: posTextMuted,
              ),
              _MetricCard(
                label: 'Profit Margin',
                value: '${profitMargin.toStringAsFixed(1)}%',
                icon: Icons.pie_chart_outline,
                color: posPrimary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Transactions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (filteredTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: posSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No transactions for this period',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: posSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(posSurfaceLight),
                    dataRowColor: WidgetStateProperty.all(posSurface),
                    headingTextStyle: GoogleFonts.outfit(
                      color: posTextMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    dataTextStyle: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Transaction #')),
                      DataColumn(label: Text('Total'), numeric: true),
                      DataColumn(label: Text('Store Rev.'), numeric: true),
                      DataColumn(label: Text('Print Rev.'), numeric: true),
                      DataColumn(label: Text('Cost'), numeric: true),
                      DataColumn(label: Text('Profit'), numeric: true),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: filteredTransactions.map((t) {
                      return DataRow(cells: [
                        DataCell(
                          Text(DateFormat('MMM dd, yyyy').format(t.date)),
                        ),
                        DataCell(Text(t.transactionNumber)),
                        DataCell(Text(currencyFormat.format(t.total))),
                        DataCell(Text(currencyFormat.format(t.storeRevenue))),
                        DataCell(
                          Text(currencyFormat.format(t.printingRevenue)),
                        ),
                        DataCell(
                          Text(currencyFormat.format(t.totalCost ?? 0)),
                        ),
                        DataCell(
                          Text(currencyFormat.format(t.grossProfit ?? 0)),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: posPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.status?.statusName ?? 'N/A',
                              style: GoogleFonts.outfit(
                                color: posPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: posSurfaceLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: posTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
