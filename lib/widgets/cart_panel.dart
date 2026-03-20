import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/providers/providers.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/widgets/cart_item_row.dart';
import 'package:provider/provider.dart';

class CartPanel extends HookWidget {
  final TransactionProvider transactionProvider;
  final ValueNotifier<int> selectedPaymentMethod;

  const CartPanel({
    required this.transactionProvider,
    required this.selectedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final cart = transactionProvider.cart;
    final isCheckingOut = useState(false);
    final checkoutSuccess = useState(false);

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
                      return CartItemRow(
                        item: item,
                        onIncrease: () => transactionProvider
                            .updateCartItemQuantity(index, item.quantity + 1),
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
                  const SizedBox(width: 6),
                  _PaymentChip(
                    label: 'GCash',
                    icon: Icons.phone_android_rounded,
                    methodId: 2,
                    selected: selectedPaymentMethod,
                  ),
                  const SizedBox(width: 6),
                  _PaymentChip(
                    label: 'Card',
                    icon: Icons.credit_card_rounded,
                    methodId: 3,
                    selected: selectedPaymentMethod,
                  ),
                  const SizedBox(width: 6),
                  _PaymentChip(
                    label: 'Credit',
                    icon: Icons.account_balance_rounded,
                    methodId: 4,
                    selected: selectedPaymentMethod,
                  ),
                ],
              ),
            ),

            // ── Order Now button with morph ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _CheckoutButton(
                isCheckingOut: isCheckingOut,
                checkoutSuccess: checkoutSuccess,
                onCheckout: () =>
                    _handleCheckout(context, isCheckingOut, checkoutSuccess),
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
  ) async {
    isCheckingOut.value = true;
    checkoutSuccess.value = false;
    try {
      final cashierId = context.read<AuthController>().userProfile!.id;
      final result = await transactionProvider.checkout(
        cashierId: cashierId,
        paymentMethodId: selectedPaymentMethod.value,
      );

      if (!context.mounted) return;

      if (result != null) {
        checkoutSuccess.value = true;
        await Future.delayed(const Duration(milliseconds: 1200));
        checkoutSuccess.value = false;

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Transaction ${result.transactionNumber} completed!',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
