import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';

class CartItemRow extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback? onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemRow({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isPrint = item.categoryId == 2;

    return Row(
      children: [
        // Type icon
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isPrint
                ? Colors.blue.withValues(alpha: 0.1)
                : posPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPrint ? Icons.print_rounded : Icons.shopping_bag_outlined,
            color: isPrint ? Colors.blue.shade400 : posPrimary,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),

        // Name + price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: GoogleFonts.outfit(
                  color: posTextMain,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                'P${item.unitPrice.toStringAsFixed(2)}${isPrint ? '/pg' : ''}',
                style: GoogleFonts.outfit(
                  color: warmGray.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // Quantity controls
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyBtn(Icons.remove, onDecrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  item.quantity.toStringAsFixed(0),
                  style: GoogleFonts.outfit(
                    color: posTextMain,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _qtyBtn(Icons.add, onIncrease),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Subtotal
        SizedBox(
          width: 60,
          child: Text(
            'P${item.subtotal.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: posPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 2),

        // Remove
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: warmGray.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 12,
          color: enabled ? warmGray : warmGray.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
