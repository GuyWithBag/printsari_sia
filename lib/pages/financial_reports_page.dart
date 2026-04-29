import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
    final tabController = useTabController(initialLength: 4);
    final currentIndex = useState(0);
    final transactionProvider = context.read<TransactionProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final customDateRange = useState<DateTimeRange?>(null);

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
      body: snapshot.hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load financial data',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      style: GoogleFonts.outfit(
                          color: posTextMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : Skeletonizer(
              enabled: !snapshot.hasData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CircularTabBar(
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
                              CircularTab(
                                tabController: tabController,
                                index: 3,
                                label: 'Yearly',
                                icon: Icons.calendar_today_outlined,
                                indexState: currentIndex,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: now,
                              initialDateRange: customDateRange.value ??
                                  DateTimeRange(
                                    start: now.subtract(const Duration(days: 30)),
                                    end: now,
                                  ),
                              builder: (ctx, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: posPrimary,
                                    surface: posSurface,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              customDateRange.value = picked;
                            }
                          },
                          icon: Icon(
                            Icons.date_range,
                            size: 16,
                            color: customDateRange.value != null
                                ? posPrimary
                                : Colors.white,
                          ),
                          label: Text(
                            customDateRange.value != null
                                ? '${DateFormat('MMM d').format(customDateRange.value!.start)} – ${DateFormat('MMM d').format(customDateRange.value!.end)}'
                                : 'Date Range',
                            style: GoogleFonts.outfit(
                              color: customDateRange.value != null
                                  ? posPrimary
                                  : Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: customDateRange.value != null
                                  ? posPrimary
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        if (customDateRange.value != null) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: posTextMuted),
                            tooltip: 'Clear date range',
                            onPressed: () => customDateRange.value = null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
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
                                  expenses:
                                      snapshot.data![1] as List<Expense>,
                                  periodDays: 0,
                                  periodLabel: 'Today',
                                  customDateRange: customDateRange.value,
                                ),
                                _ReportView(
                                  transactions:
                                      snapshot.data![0] as List<Transaction>,
                                  expenses:
                                      snapshot.data![1] as List<Expense>,
                                  periodDays: 7,
                                  periodLabel: 'Last 7 Days',
                                  customDateRange: customDateRange.value,
                                ),
                                _ReportView(
                                  transactions:
                                      snapshot.data![0] as List<Transaction>,
                                  expenses:
                                      snapshot.data![1] as List<Expense>,
                                  periodDays: 30,
                                  periodLabel: 'Last 30 Days',
                                  customDateRange: customDateRange.value,
                                ),
                                _ReportView(
                                  transactions:
                                      snapshot.data![0] as List<Transaction>,
                                  expenses:
                                      snapshot.data![1] as List<Expense>,
                                  periodDays: 365,
                                  periodLabel: 'Last 12 Months',
                                  customDateRange: customDateRange.value,
                                ),
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                  color: posPrimary),
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
  final DateTimeRange? customDateRange;

  const _ReportView({
    required this.transactions,
    required this.expenses,
    required this.periodDays,
    required this.periodLabel,
    this.customDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    DateTime cutoff;
    DateTime? rangeEnd;

    if (customDateRange != null) {
      cutoff = DateTime(customDateRange!.start.year, customDateRange!.start.month, customDateRange!.start.day);
      rangeEnd = DateTime(customDateRange!.end.year, customDateRange!.end.month, customDateRange!.end.day, 23, 59, 59);
    } else if (periodDays == 0) {
      cutoff = startOfToday;
    } else {
      cutoff = startOfToday.subtract(Duration(days: periodDays));
    }

    final filteredTransactions = transactions.where((t) {
      if (!t.date.isAfter(cutoff)) return false;
      if (rangeEnd != null && t.date.isAfter(rangeEnd)) return false;
      return true;
    }).toList();
    final filteredExpenses = expenses.where((e) {
      if (!e.date.isAfter(cutoff)) return false;
      if (rangeEnd != null && e.date.isAfter(rangeEnd)) return false;
      return true;
    }).toList();

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
          Row(
            children: [
              Text(
                periodLabel,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _exportFinancialReport(
                  context,
                  periodLabel: periodLabel,
                  filteredTransactions: filteredTransactions,
                  filteredExpenses: filteredExpenses,
                  totalRevenue: totalRevenue,
                  storeRevenue: storeRevenue,
                  printingRevenue: printingRevenue,
                  totalExpenses: totalExpenses,
                  profit: profit,
                  profitMargin: profitMargin,
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: Text('Export PDF', style: GoogleFonts.outfit(fontSize: 13)),
                style: FilledButton.styleFrom(
                  backgroundColor: posPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
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
          _TrendChart(
            transactions: filteredTransactions,
            expenses: filteredExpenses,
            periodDays: customDateRange != null
                ? customDateRange!.end.difference(customDateRange!.start).inDays + 1
                : (periodDays == 0 ? 1 : periodDays),
            startDate: cutoff,
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
                              color: posPrimary.withValues(alpha: 0.15),
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

class _TrendChart extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Expense> expenses;
  final int periodDays;
  final DateTime startDate;

  const _TrendChart({
    required this.transactions,
    required this.expenses,
    required this.periodDays,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty && expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine bucket size: daily if period <= 90, weekly otherwise
    final bucketDays = periodDays <= 90 ? 1 : 7;
    final bucketCount = (periodDays / bucketDays).ceil().clamp(1, 365);

    // Build buckets
    final revenueByBucket = List.filled(bucketCount, 0.0);
    final expensesByBucket = List.filled(bucketCount, 0.0);

    for (final t in transactions) {
      final diff = t.date.difference(startDate).inDays;
      final idx = (diff / bucketDays).floor();
      if (idx >= 0 && idx < bucketCount) {
        revenueByBucket[idx] += t.total;
      }
    }
    for (final e in expenses) {
      final diff = e.date.difference(startDate).inDays;
      final idx = (diff / bucketDays).floor();
      if (idx >= 0 && idx < bucketCount) {
        expensesByBucket[idx] += e.amount;
      }
    }

    final profitByBucket = List.generate(
        bucketCount, (i) => revenueByBucket[i] - expensesByBucket[i]);

    double maxY = 0;
    for (int i = 0; i < bucketCount; i++) {
      maxY = [maxY, revenueByBucket[i], expensesByBucket[i], profitByBucket[i].abs()].reduce((a, b) => a > b ? a : b);
    }
    if (maxY == 0) maxY = 100;

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Trend Analysis',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _legendDot(posPrimary, 'Revenue'),
              const SizedBox(width: 12),
              _legendDot(const Color(0xFFEF4444), 'Expenses'),
              const SizedBox(width: 12),
              _legendDot(const Color(0xFF22C55E), 'Profit'),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Give each bucket at least 12 px so lines never overlap.
              // If the natural width is smaller, the chart fills the container.
              final minWidth = bucketCount * 12.0;
              final chartWidth = minWidth > constraints.maxWidth
                  ? minWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY * 1.1,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (_) => FlLine(
                          color: Colors.white.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (v, _) => Text(
                              v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0),
                              style: GoogleFonts.outfit(fontSize: 10, color: posTextMuted),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (bucketCount / 8).ceilToDouble().clamp(1, bucketCount.toDouble()),
                            getTitlesWidget: (v, _) {
                              final date = startDate.add(Duration(days: (v * bucketDays).toInt()));
                              return Text(
                                DateFormat('M/d').format(date),
                                style: GoogleFonts.outfit(fontSize: 10, color: posTextMuted),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => posSurfaceLight,
                          getTooltipItems: (spots) => spots.map((s) {
                            final colors = [posPrimary, const Color(0xFFEF4444), const Color(0xFF22C55E)];
                            final labels = ['Rev', 'Exp', 'Profit'];
                            final idx = s.barIndex;
                            return LineTooltipItem(
                              '${labels[idx]}: ₱${s.y.toStringAsFixed(0)}',
                              GoogleFonts.outfit(fontSize: 11, color: colors[idx], fontWeight: FontWeight.w600),
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        _buildLine(revenueByBucket, posPrimary),
                        _buildLine(expensesByBucket, const Color(0xFFEF4444)),
                        _buildLine(profitByBucket, const Color(0xFF22C55E)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.06),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: posTextMuted)),
      ],
    );
  }
}

Future<void> _exportFinancialReport(
  BuildContext context, {
  required String periodLabel,
  required List<Transaction> filteredTransactions,
  required List<Expense> filteredExpenses,
  required double totalRevenue,
  required double storeRevenue,
  required double printingRevenue,
  required double totalExpenses,
  required double profit,
  required double profitMargin,
}) async {
  final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  final dateFormat = DateFormat('MMM dd, yyyy');
  final generatedAt = DateFormat('MMM dd, yyyy · h:mm a').format(DateTime.now());

  Future<pw.Document> buildDoc() async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    pw.TextStyle s(double size, {bool isBold = false, PdfColor? color}) =>
        pw.TextStyle(
          font: isBold ? bold : regular,
          fontSize: size,
          color: color ?? PdfColors.white,
        );

    final headerBg = PdfColor.fromHex('1E293B');
    final rowBg = PdfColor.fromHex('0F172A');
    final altRowBg = PdfColor.fromHex('162032');
    final accentColor = PdfColor.fromHex('6366F1');
    final mutedColor = PdfColor.fromHex('94A3B8');
    final redColor = PdfColor.fromHex('EF4444');
    final greenColor = PdfColor.fromHex('22C55E');

    final doc = pw.Document();

    // ── Helpers ──
    pw.Widget metricCell(String label, String value, {PdfColor? valueColor}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: rowBg,
          border: pw.Border.all(color: PdfColor.fromHex('334155'), width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: s(8, color: mutedColor)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: s(11, isBold: true, color: valueColor ?? PdfColors.white)),
          ],
        ),
      );
    }

    pw.Widget headerCell(String text) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          color: headerBg,
          child: pw.Text(text, style: s(8, isBold: true, color: mutedColor)),
        );

    pw.Widget dataCell(String text, {bool isRight = false, PdfColor? color}) =>
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: pw.Text(
            text,
            style: s(8, color: color ?? PdfColors.white),
            textAlign: isRight ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
          buildBackground: (ctx) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColor.fromHex('0F172A')),
          ),
        ),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PrintSari Corner', style: s(16, isBold: true, color: accentColor)),
                    pw.Text('Financial Report · $periodLabel', style: s(10, color: mutedColor)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated', style: s(8, color: mutedColor)),
                    pw.Text(generatedAt, style: s(8, color: PdfColors.white)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColor.fromHex('334155'), thickness: 0.5),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (ctx) => [
          // ── Summary metrics grid ──
          pw.Text('Summary', style: s(12, isBold: true)),
          pw.SizedBox(height: 8),
          pw.GridView(
            crossAxisCount: 4,
            childAspectRatio: 2.2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            children: [
              metricCell('Total Revenue', currency.format(totalRevenue), valueColor: accentColor),
              metricCell('Store Revenue', currency.format(storeRevenue)),
              metricCell('Printing Revenue', currency.format(printingRevenue)),
              metricCell('Total Expenses', currency.format(totalExpenses), valueColor: redColor),
              metricCell('Net Profit', currency.format(profit), valueColor: profit >= 0 ? greenColor : redColor),
              metricCell('Profit Margin', '${profitMargin.toStringAsFixed(1)}%', valueColor: profit >= 0 ? greenColor : redColor),
              metricCell('Transactions', '${filteredTransactions.length}'),
              metricCell('Expenses Recorded', '${filteredExpenses.length}'),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Transactions table ──
          pw.Text('Transactions (${filteredTransactions.length})', style: s(12, isBold: true)),
          pw.SizedBox(height: 8),
          if (filteredTransactions.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: rowBg,
                border: pw.Border.all(color: PdfColor.fromHex('334155'), width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text('No transactions for this period.', style: s(9, color: mutedColor), textAlign: pw.TextAlign.center),
            )
          else
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1.8),
                1: const pw.FlexColumnWidth(2.2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.4),
                4: const pw.FlexColumnWidth(1.4),
                5: const pw.FlexColumnWidth(1.4),
                6: const pw.FlexColumnWidth(1.4),
              },
              border: pw.TableBorder.all(color: PdfColor.fromHex('334155'), width: 0.3),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerBg),
                  children: [
                    headerCell('Date'),
                    headerCell('Transaction #'),
                    headerCell('Total'),
                    headerCell('Store Rev.'),
                    headerCell('Print Rev.'),
                    headerCell('Cost'),
                    headerCell('Profit'),
                  ],
                ),
                ...filteredTransactions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  final txProfit = t.grossProfit ?? 0;
                  final bg = i.isEven ? rowBg : altRowBg;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      dataCell(dateFormat.format(t.date)),
                      dataCell(t.transactionNumber),
                      dataCell(currency.format(t.total), isRight: true),
                      dataCell(currency.format(t.storeRevenue), isRight: true),
                      dataCell(currency.format(t.printingRevenue), isRight: true),
                      dataCell(currency.format(t.totalCost ?? 0), isRight: true),
                      dataCell(currency.format(txProfit), isRight: true, color: txProfit >= 0 ? greenColor : redColor),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 20),

          // ── Expenses table ──
          pw.Text('Expenses (${filteredExpenses.length})', style: s(12, isBold: true)),
          pw.SizedBox(height: 8),
          if (filteredExpenses.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: rowBg,
                border: pw.Border.all(color: PdfColor.fromHex('334155'), width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text('No expenses for this period.', style: s(9, color: mutedColor), textAlign: pw.TextAlign.center),
            )
          else
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(3.0),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(1.8),
              },
              border: pw.TableBorder.all(color: PdfColor.fromHex('334155'), width: 0.3),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerBg),
                  children: [
                    headerCell('Date'),
                    headerCell('Description'),
                    headerCell('Category'),
                    headerCell('Amount'),
                  ],
                ),
                ...filteredExpenses.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final bg = i.isEven ? rowBg : altRowBg;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      dataCell(dateFormat.format(e.date)),
                      dataCell(e.description),
                      dataCell(e.category?.categoryName ?? 'Uncategorized'),
                      dataCell(currency.format(e.amount), isRight: true, color: redColor),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );

    return doc;
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 700,
        height: 760,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Text(
                    'Export — $periodLabel',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: posTextMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PdfPreview(
                build: (_) async {
                  final doc = await buildDoc();
                  return doc.save();
                },
                canChangePageFormat: false,
                canChangeOrientation: false,
                allowPrinting: true,
                allowSharing: true,
                initialPageFormat: PdfPageFormat.a4,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
