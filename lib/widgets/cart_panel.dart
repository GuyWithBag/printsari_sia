import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/providers/providers.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/cart_item_row.dart';
import 'package:provider/provider.dart';

class CartPanel extends HookWidget {
  final TransactionProvider transactionProvider;
  final ValueNotifier<int> selectedPaymentMethod;
  final List<InventoryItem> inventory;

  const CartPanel({
    required this.transactionProvider,
    required this.selectedPaymentMethod,
    required this.inventory,
  });

  @override
  Widget build(BuildContext context) {
    final cart = transactionProvider.cart;
    final isCheckingOut = useState(false);
    final checkoutSuccess = useState(false);
    final cashTenderedController = useTextEditingController();

    // Keep cash tendered in sync with the total whenever payment is Cash
    final total = transactionProvider.cartSubtotal;
    useEffect(() {
      if (selectedPaymentMethod.value == 1) {
        cashTenderedController.text = total > 0 ? total.toStringAsFixed(2) : '';
      }
      return null;
    }, [total, selectedPaymentMethod.value]);

    // Animated list key for smooth insert/remove
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());
    final prevCartLength = useRef(cart.length);

    // Trigger AnimatedList insert when cart grows
    useEffect(() {
      final key = listKey.currentState;
      if (key != null && cart.length > prevCartLength.value) {
        for (var i = prevCartLength.value; i < cart.length; i++) {
          key.insertItem(i, duration: const Duration(milliseconds: 250));
        }
      }
      prevCartLength.value = cart.length;
      return null;
    }, [cart.length]);

    return Container(
      decoration: BoxDecoration(
        color: posCream,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: posPrimary.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Order',
                  style: GoogleFonts.outfit(
                    color: posTextMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: posPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${cart.length}',
                      style: GoogleFonts.outfit(
                        color: posPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (cart.isNotEmpty)
                  InkWell(
                    onTap: () => transactionProvider.clearCart(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_sweep_rounded,
                            size: 14,
                            color: warmGray.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: GoogleFonts.outfit(
                              color: warmGray.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(
            color: Colors.black.withValues(alpha: 0.08),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // ── Cart Items ──
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: warmGray.withValues(alpha: 0.2),
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Cart is empty',
                          style: GoogleFonts.outfit(
                            color: warmGray.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap a product to add it',
                          style: GoogleFonts.outfit(
                            color: warmGray.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.black.withValues(alpha: 0.06),
                      height: 14,
                    ),
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      // For store items, cap at available inventory stock.
                      VoidCallback? increaseCallback;
                      if (item.inventoryId != null) {
                        final invItem = inventory
                            .where((i) => i.id == item.inventoryId)
                            .firstOrNull;
                        final totalInCart = cart
                            .where((c) => c.inventoryId == item.inventoryId)
                            .fold(0.0, (sum, c) => sum + c.quantity);
                        final available =
                            (invItem?.stock ?? 0) - totalInCart + item.quantity;
                        if (item.quantity < available) {
                          increaseCallback = () => transactionProvider
                              .updateCartItemQuantity(index, item.quantity + 1);
                        }
                      } else {
                        // Print services have no stock limit.
                        increaseCallback = () => transactionProvider
                            .updateCartItemQuantity(index, item.quantity + 1);
                      }

                      return CartItemRow(
                        item: item,
                        onIncrease: increaseCallback,
                        onDecrease: () {
                          if (item.quantity > 1) {
                            transactionProvider.updateCartItemQuantity(
                              index,
                              item.quantity - 1,
                            );
                          }
                        },
                        onRemove: () =>
                            transactionProvider.removeFromCart(index),
                      );
                    },
                  ),
          ),

          // ── Summary + Checkout ──
          if (cart.isNotEmpty) ...[
            // Dotted divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DottedLinePainter(
                  color: Colors.black.withValues(alpha: 0.15),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  // Store Subtotal
                  _SummaryRow(
                    label: 'Store Subtotal',
                    value: transactionProvider.cartStoreRevenue,
                    muted: true,
                    icon: Icons.storefront_rounded,
                    iconColor: posPrimary,
                  ),
                  const SizedBox(height: 6),
                  // Printing Subtotal
                  _SummaryRow(
                    label: 'Printing Subtotal',
                    value: transactionProvider.cartPrintingRevenue,
                    muted: true,
                    icon: Icons.print_rounded,
                    iconColor: Colors.blue.shade400,
                  ),

                  const SizedBox(height: 10),
                  // Solid divider
                  Divider(
                    color: Colors.black.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  const SizedBox(height: 10),

                  // Total with rolling animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.outfit(
                          color: posTextMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _RollingPrice(
                        value: transactionProvider.cartSubtotal,
                        style: GoogleFonts.outfit(
                          color: posPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment method chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  _PaymentChip(
                    label: 'Cash',
                    icon: Icons.money_rounded,
                    methodId: 1,
                    selected: selectedPaymentMethod,
                  ),
                ],
              ),
            ),

            // ── Cash tendered field (Cash only) ──
            if (selectedPaymentMethod.value == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  controller: cashTenderedController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.outfit(color: posTextMain, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Cash Tendered (₱)',
                    labelStyle: GoogleFonts.outfit(
                      color: posTextMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.money_rounded,
                      color: posTextMuted,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: posPrimary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

            // ── Order Now button with morph ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _CheckoutButton(
                isCheckingOut: isCheckingOut,
                checkoutSuccess: checkoutSuccess,
                onCheckout: () => _handleCheckout(
                  context,
                  isCheckingOut,
                  checkoutSuccess,
                  cashTenderedController,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    ValueNotifier<bool> isCheckingOut,
    ValueNotifier<bool> checkoutSuccess,
    TextEditingController cashTenderedController,
  ) async {
    isCheckingOut.value = true;
    checkoutSuccess.value = false;

    // Snapshot cart BEFORE checkout clears it
    final cartSnapshot = List<TransactionItem>.from(transactionProvider.cart);
    final total = transactionProvider.cartSubtotal;
    final storeRevenue = transactionProvider.cartStoreRevenue;
    final printingRevenue = transactionProvider.cartPrintingRevenue;
    final isCash = selectedPaymentMethod.value == 1;
    final cashTendered = double.tryParse(cashTenderedController.text) ?? 0.0;

    try {
      final cashierId = context.read<AuthController>().userProfile!.id;
      final activityLog = context.read<ActivityLogProvider>();
      final result = await transactionProvider.checkout(
        cashierId: cashierId,
        paymentMethodId: selectedPaymentMethod.value,
        activityLog: activityLog,
      );

      if (!context.mounted) return;

      if (result != null) {
        checkoutSuccess.value = true;
        cashTenderedController.clear();
        await Future.delayed(const Duration(milliseconds: 800));
        checkoutSuccess.value = false;

        if (!context.mounted) return;

        final customerProvider = context.read<CustomerProvider>();
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _ReceiptDialog(
            transaction: result,
            cartItems: cartSnapshot,
            total: total,
            storeRevenue: storeRevenue,
            printingRevenue: printingRevenue,
            isCash: isCash,
            cashTendered: cashTendered,
            customerProvider: customerProvider,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Checkout failed. Please try again.',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      isCheckingOut.value = false;
    }
  }
}

// ── Receipt Dialog ─────────────────────────────────────────────────────────────

class _ReceiptDialog extends StatelessWidget {
  final Transaction transaction;
  final List<TransactionItem> cartItems;
  final double total;
  final double storeRevenue;
  final double printingRevenue;
  final bool isCash;
  final double cashTendered;
  final CustomerProvider customerProvider;

  const _ReceiptDialog({
    required this.transaction,
    required this.cartItems,
    required this.total,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.isCash,
    required this.cashTendered,
    required this.customerProvider,
  });

  double get change =>
      isCash ? (cashTendered - total).clamp(0, double.infinity) : 0;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy  h:mm a').format(transaction.date);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: posSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: posPrimary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order Complete',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.transactionNumber,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Receipt body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store info
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PrintSari Corner',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Magpet, North Cotabato',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF334155)),

                    // Items
                    ...cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '×${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)}  @  ₱${item.unitPrice.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      color: posTextMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₱${item.subtotal.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(color: Color(0xFF334155)),

                    // Subtotals
                    if (storeRevenue > 0)
                      _receiptRow('Store', storeRevenue, muted: true),
                    if (printingRevenue > 0)
                      _receiptRow('Printing', printingRevenue, muted: true),
                    const SizedBox(height: 4),
                    _receiptRow('TOTAL', total, bold: true, large: true),

                    if (isCash) ...[
                      const SizedBox(height: 4),
                      _receiptRow('Cash Tendered', cashTendered, muted: true),
                      _receiptRow('Change', change, muted: true),
                    ],

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Thank you for your purchase!',
                        style: GoogleFonts.outfit(
                          color: posTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TagCustomerSection(
                      transactionId: transaction.id,
                      customerProvider: customerProvider,
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: posTextMuted,
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Close', style: GoogleFonts.outfit()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _printReceipt(context),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text('Print', style: GoogleFonts.outfit()),
                      style: FilledButton.styleFrom(
                        backgroundColor: posPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    );
  }

  Widget _receiptRow(
    String label,
    double value, {
    bool muted = false,
    bool bold = false,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: muted ? posTextMuted : Colors.white,
              fontSize: large ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            '₱${value.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: muted ? posTextMuted : Colors.white,
              fontSize: large ? 16 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    final dateStr = DateFormat('MMM d, yyyy  h:mm a').format(transaction.date);

    Future<pw.Document> buildDoc() async {
      final regular = await PdfGoogleFonts.notoSansRegular();
      final bold = await PdfGoogleFonts.notoSansBold();

      pw.TextStyle style(double size, {bool isBold = false}) =>
          pw.TextStyle(font: isBold ? bold : regular, fontSize: size);

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            80 * PdfPageFormat.mm,
            double.infinity,
            marginAll: 8 * PdfPageFormat.mm,
          ),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'PrintSari Corner',
                    style: style(14, isBold: true),
                  ),
                ),
                pw.Center(
                  child: pw.Text('Magpet, North Cotabato', style: style(10)),
                ),
                pw.Center(child: pw.Text(dateStr, style: style(10))),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    transaction.transactionNumber,
                    style: style(11, isBold: true),
                  ),
                ),
                pw.Divider(),
                ...cartItems.map(
                  (item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${item.productName}\n  \u00d7${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} @ \u20b1${item.unitPrice.toStringAsFixed(2)}',
                          style: style(10),
                        ),
                      ),
                      pw.Text(
                        '\u20b1${item.subtotal.toStringAsFixed(2)}',
                        style: style(10),
                      ),
                    ],
                  ),
                ),
                pw.Divider(),
                if (storeRevenue > 0)
                  _pdfRow(
                    'Store Subtotal',
                    storeRevenue,
                    regular: regular,
                    bold: bold,
                  ),
                if (printingRevenue > 0)
                  _pdfRow(
                    'Printing Subtotal',
                    printingRevenue,
                    regular: regular,
                    bold: bold,
                  ),
                pw.SizedBox(height: 4),
                _pdfRow(
                  'TOTAL',
                  total,
                  isBold: true,
                  regular: regular,
                  bold: bold,
                ),
                if (isCash) ...[
                  _pdfRow(
                    'Cash Tendered',
                    cashTendered,
                    regular: regular,
                    bold: bold,
                  ),
                  _pdfRow('Change', change, regular: regular, bold: bold),
                ],
                pw.SizedBox(height: 8),
                pw.Center(child: pw.Text('Thank you!', style: style(11))),
              ],
            );
          },
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
          width: 480,
          height: 680,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Text(
                      'Print Preview',
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
                  initialPageFormat: const PdfPageFormat(
                    80 * PdfPageFormat.mm,
                    double.infinity,
                    marginAll: 8 * PdfPageFormat.mm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pw.Widget _pdfRow(
    String label,
    double value, {
    bool isBold = false,
    required pw.Font regular,
    required pw.Font bold,
  }) {
    final style = pw.TextStyle(
      font: isBold ? bold : regular,
      fontSize: isBold ? 11 : 10,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text('\u20b1${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

// ── Tag Customer Section ────────────────────────────────────────────────────

class _TagCustomerSection extends StatefulWidget {
  final int transactionId;
  final CustomerProvider customerProvider;

  const _TagCustomerSection({
    required this.transactionId,
    required this.customerProvider,
  });

  @override
  State<_TagCustomerSection> createState() => _TagCustomerSectionState();
}

class _TagCustomerSectionState extends State<_TagCustomerSection> {
  Customer? _taggedCustomer;
  bool _isTagging = false;

  Future<void> _tag() async {
    final customerProvider = widget.customerProvider;
    setState(() => _isTagging = true);
    List<Customer> customers;
    try {
      customers = await customerProvider.getCustomers();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTagging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customers: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isTagging = false);

    final selected = await showDialog<Customer>(
      context: context,
      builder: (ctx) => _CustomerPickerDialog(customers: customers),
    );

    if (selected == null || !mounted) return;
    await customerProvider.tagTransactionCustomer(
      widget.transactionId,
      selected.id,
    );
    if (!mounted) return;
    setState(() => _taggedCustomer = selected);
  }

  @override
  Widget build(BuildContext context) {
    if (_taggedCustomer != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_rounded, size: 14, color: posAccent),
          const SizedBox(width: 6),
          Text(
            _taggedCustomer!.name ?? _taggedCustomer!.email,
            style: GoogleFonts.outfit(color: posAccent, fontSize: 12),
          ),
        ],
      );
    }
    if (_isTagging) {
      return const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: posTextMuted),
        ),
      );
    }
    return Center(
      child: TextButton.icon(
        onPressed: _tag,
        icon: const Icon(
          Icons.person_add_rounded,
          size: 14,
          color: posTextMuted,
        ),
        label: Text(
          'Tag Customer',
          style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
        ),
      ),
    );
  }
}

// ── Customer Picker Dialog ──────────────────────────────────────────────────

class _CustomerPickerDialog extends StatefulWidget {
  final List<Customer> customers;
  const _CustomerPickerDialog({required this.customers});

  @override
  State<_CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<_CustomerPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (c.name?.toLowerCase().contains(q) ?? false) ||
          c.email.toLowerCase().contains(q) ||
          (c.phone?.contains(q) ?? false);
    }).toList();

    return AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      title: Text(
        'Select Customer',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                hintStyle: GoogleFonts.outfit(
                  color: posTextMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: posTextMuted,
                  size: 18,
                ),
                filled: true,
                fillColor: posSurfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No customers found',
                        style: GoogleFonts.outfit(color: posTextMuted),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(c),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: posSurfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name ?? c.email,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (c.name != null)
                                  Text(
                                    c.email,
                                    style: GoogleFonts.outfit(
                                      color: posTextMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool muted;
  final IconData? icon;
  final Color? iconColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.muted = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: iconColor ?? posTextMuted),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: GoogleFonts.outfit(
            color: muted ? warmGray.withValues(alpha: 0.5) : posTextMain,
            fontSize: muted ? 12 : 13,
          ),
        ),
        const Spacer(),
        _RollingPrice(
          value: value,
          style: GoogleFonts.outfit(
            color: muted ? warmGray.withValues(alpha: 0.5) : posTextMain,
            fontSize: muted ? 12 : 13,
            fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RollingPrice extends StatelessWidget {
  final double value;
  final TextStyle style;

  const _RollingPrice({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text('P${animatedValue.toStringAsFixed(2)}', style: style);
      },
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final ValueNotifier<bool> isCheckingOut;
  final ValueNotifier<bool> checkoutSuccess;
  final VoidCallback onCheckout;

  const _CheckoutButton({
    required this.isCheckingOut,
    required this.checkoutSuccess,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: checkoutSuccess.value
              ? LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade700],
                )
              : const LinearGradient(
                  colors: [posPrimary, posPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (checkoutSuccess.value ? Colors.green : posPrimary)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isCheckingOut.value ? null : onCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isCheckingOut.value
                ? (checkoutSuccess.value
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('success'),
                          color: Colors.white,
                          size: 28,
                        )
                      : const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ))
                : Row(
                    key: const ValueKey('idle'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_checkout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Order Now',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int methodId;
  final ValueNotifier<int> selected;

  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.methodId,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected.value == methodId;
    return Expanded(
      child: InkWell(
        onTap: () => selected.value = methodId,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? posPrimary.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? posPrimary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? posPrimary : warmGray),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSelected ? posPrimary : warmGray,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
