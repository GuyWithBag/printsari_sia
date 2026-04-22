import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:printsari_sia/providers/transaction_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionsPage extends HookWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionProvider = context.read<TransactionProvider>();
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final refreshKey = useState(0);

    final dataFuture = useMemoized(
      () => transactionProvider.getTransactions(),
      [refreshKey.value],
    );
    final snapshot = useFuture(dataFuture);

    void hardRefresh() {
      transactionProvider.clearTransactionsCache();
      refreshKey.value++;
    }

    List<Transaction> transactions = [];
    if (snapshot.hasData) {
      final q = searchQuery.value.toLowerCase();
      transactions = q.isEmpty
          ? snapshot.data!
          : snapshot.data!.where((t) {
              return t.transactionNumber.toLowerCase().contains(q) ||
                  (t.cashier?.name?.toLowerCase().contains(q) ?? false) ||
                  (t.customer?.name?.toLowerCase().contains(q) ?? false) ||
                  (t.paymentMethod?.methodName.toLowerCase().contains(q) ?? false);
            }).toList();
    }

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Transactions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: hardRefresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Complete history of all sales transactions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: searchController,
              onChanged: (v) => searchQuery.value = v,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by TXN #, cashier, customer, payment method...',
                hintStyle: GoogleFonts.outfit(color: posTextMuted),
                prefixIcon: const Icon(Icons.search, color: posTextMuted),
                filled: true,
                fillColor: posSurfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            if (snapshot.hasError)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load transactions',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}',
                          style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Skeletonizer(
                  enabled: !snapshot.hasData,
                  child: snapshot.hasData && transactions.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.value.isEmpty
                                ? 'No transactions yet'
                                : 'No transactions match your search',
                            style: GoogleFonts.outfit(color: posTextMuted),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: posSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SingleChildScrollView(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(posSurfaceLight),
                                  dataRowColor: WidgetStateProperty.all(posSurface),
                                  headingTextStyle: GoogleFonts.outfit(
                                      color: posTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
                                  dataTextStyle:
                                      GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                                  showCheckboxColumn: false,
                                  columns: const [
                                    DataColumn(label: Text('TXN #')),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Cashier')),
                                    DataColumn(label: Text('Customer')),
                                    DataColumn(label: Text('Payment')),
                                    DataColumn(label: Text('Store')),
                                    DataColumn(label: Text('Printing')),
                                    DataColumn(label: Text('Total')),
                                  ],
                                  rows: transactions.map((txn) {
                                    return DataRow(
                                      onSelectChanged: (_) =>
                                          _showTransactionDetail(context, txn),
                                      cells: [
                                        DataCell(Text(
                                          txn.transactionNumber,
                                          style: GoogleFonts.outfit(
                                              color: posPrimary, fontWeight: FontWeight.w600),
                                        )),
                                        DataCell(Text(
                                          DateFormat('MMM d, yyyy\nh:mm a').format(txn.date),
                                          style: GoogleFonts.outfit(fontSize: 12),
                                        )),
                                        DataCell(Text(txn.cashier?.name ?? '—')),
                                        DataCell(Text(txn.customer?.name ?? '—')),
                                        DataCell(_PaymentBadge(
                                            method: txn.paymentMethod?.methodName ?? '—')),
                                        DataCell(Text(
                                          txn.storeRevenue > 0
                                              ? '₱${txn.storeRevenue.toStringAsFixed(2)}'
                                              : '—',
                                          style: GoogleFonts.outfit(color: posTextMuted),
                                        )),
                                        DataCell(Text(
                                          txn.printingRevenue > 0
                                              ? '₱${txn.printingRevenue.toStringAsFixed(2)}'
                                              : '—',
                                          style: GoogleFonts.outfit(color: posTextMuted),
                                        )),
                                        DataCell(Text(
                                          '₱${txn.total.toStringAsFixed(2)}',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String method;
  const _PaymentBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final color = switch (method.toLowerCase()) {
      'cash' => const Color(0xFF22C55E),
      'gcash' => const Color(0xFF3B82F6),
      'card' => const Color(0xFFA78BFA),
      _ => posTextMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        method,
        style: GoogleFonts.outfit(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Future<void> _showTransactionDetail(BuildContext context, Transaction txn) async {
  // Fetch full transaction with items if not already joined
  final supabase = context.read<TransactionProvider>();
  Transaction full = txn;
  if (txn.items == null) {
    final fetched = await supabase.getTransaction(txn.id);
    if (fetched != null) full = fetched;
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              decoration: const BoxDecoration(
                color: posSurfaceLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: posPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          full.transactionNumber,
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy  h:mm a').format(full.date),
                          style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: posTextMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta row
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        _metaChip(Icons.person_outline, full.cashier?.name ?? '—', 'Cashier'),
                        _metaChip(Icons.face_outlined,
                            full.customer?.name ?? 'Walk-in', 'Customer'),
                        _metaChip(Icons.payment_outlined,
                            full.paymentMethod?.methodName ?? '—', 'Payment'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 8),

                    // Items
                    Text('Items',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    if (full.items == null || full.items!.isEmpty)
                      Text('No items', style: GoogleFonts.outfit(color: posTextMuted))
                    else
                      ...full.items!.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: item.categoryId == 2
                                        ? Colors.blue.withValues(alpha: 0.15)
                                        : posPrimary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    item.categoryId == 2
                                        ? Icons.print_rounded
                                        : Icons.storefront_rounded,
                                    size: 14,
                                    color: item.categoryId == 2
                                        ? Colors.blue.shade300
                                        : posPrimary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName,
                                          style: GoogleFonts.outfit(
                                              color: Colors.white, fontSize: 13)),
                                      Text(
                                        '×${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)}  ·  ₱${item.unitPrice.toStringAsFixed(2)} each',
                                        style: GoogleFonts.outfit(
                                            color: posTextMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₱${item.subtotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )),

                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF334155)),

                    // Totals
                    if (full.storeRevenue > 0)
                      _totalRow('Store Subtotal', full.storeRevenue, muted: true),
                    if (full.printingRevenue > 0)
                      _totalRow('Printing Subtotal', full.printingRevenue, muted: true),
                    const SizedBox(height: 4),
                    _totalRow('TOTAL', full.total, bold: true),
                    if (full.grossProfit != null) ...[
                      const SizedBox(height: 4),
                      _totalRow('Gross Profit', full.grossProfit!, muted: true),
                    ],

                    if (full.notes != null && full.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Notes', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(full.notes!, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: posSurfaceLight,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: posTextMuted,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Close', style: GoogleFonts.outfit()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _printTransactionReceipt(ctx, full),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text('Print Receipt', style: GoogleFonts.outfit()),
                      style: FilledButton.styleFrom(
                        backgroundColor: posPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _printTransactionReceipt(BuildContext context, Transaction txn) async {
  final dateStr = DateFormat('MMM d, yyyy  h:mm a').format(txn.date);

  Future<pw.Document> buildDoc() async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    pw.TextStyle style(double size, {bool isBold = false}) =>
        pw.TextStyle(font: isBold ? bold : regular, fontSize: size);

    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity,
          marginAll: 8 * PdfPageFormat.mm),
      build: (pw.Context ctx) {
        final items = txn.items ?? [];
        final storeRevenue = txn.storeRevenue;
        final printingRevenue = txn.printingRevenue;

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('PrintSari Corner', style: style(14, isBold: true))),
            pw.Center(child: pw.Text('Magpet, North Cotabato', style: style(10))),
            pw.Center(child: pw.Text(dateStr, style: style(10))),
            pw.SizedBox(height: 6),
            pw.Center(child: pw.Text(txn.transactionNumber, style: style(11, isBold: true))),
            if (txn.cashier?.name != null)
              pw.Center(child: pw.Text('Cashier: ${txn.cashier!.name}', style: style(9))),
            if (txn.paymentMethod?.methodName != null)
              pw.Center(child: pw.Text('Payment: ${txn.paymentMethod!.methodName}', style: style(9))),
            pw.Divider(),
            ...items.map((item) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${item.productName}\n  \u00d7${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} @ \u20b1${item.unitPrice.toStringAsFixed(2)}',
                    style: style(10),
                  ),
                ),
                pw.Text('\u20b1${item.subtotal.toStringAsFixed(2)}', style: style(10)),
              ],
            )),
            pw.Divider(),
            if (storeRevenue > 0)
              _txnPdfRow('Store Subtotal', storeRevenue, regular: regular, bold: bold),
            if (printingRevenue > 0)
              _txnPdfRow('Printing Subtotal', printingRevenue, regular: regular, bold: bold),
            pw.SizedBox(height: 4),
            _txnPdfRow('TOTAL', txn.total, isBold: true, regular: regular, bold: bold),
            if (txn.notes != null && txn.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text('Notes: ${txn.notes}', style: style(9)),
            ],
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text('Thank you!', style: style(11))),
          ],
        );
      },
    ));
    return doc;
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 480,
        height: 680,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Text('Print Preview',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                initialPageFormat: const PdfPageFormat(
                    80 * PdfPageFormat.mm, double.infinity,
                    marginAll: 8 * PdfPageFormat.mm),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

pw.Widget _txnPdfRow(
  String label,
  double value, {
  bool isBold = false,
  required pw.Font regular,
  required pw.Font bold,
}) {
  final style = pw.TextStyle(font: isBold ? bold : regular, fontSize: isBold ? 11 : 10);
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: style),
      pw.Text('\u20b1${value.toStringAsFixed(2)}', style: style),
    ],
  );
}

Widget _metaChip(IconData icon, String value, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.outfit(color: posTextMuted, fontSize: 11)),
      const SizedBox(height: 2),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: posTextMuted),
          const SizedBox(width: 4),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
        ],
      ),
    ],
  );
}

Widget _totalRow(String label, double value, {bool muted = false, bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: muted ? posTextMuted : Colors.white,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          '₱${value.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            color: muted ? posTextMuted : Colors.white,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
