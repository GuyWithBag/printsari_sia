import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';

class PrintServiceCard extends StatelessWidget {
  final ServiceSupply supply;

  const PrintServiceCard({required this.supply});

  @override
  Widget build(BuildContext context) {
    final price = supply.sellingPrice;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              supply.supplyType,
              style: GoogleFonts.outfit(
                color: Colors.blue.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            supply.name,
            style: GoogleFonts.outfit(
              color: posTextMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (supply.paperSize != null) ...[
            const SizedBox(height: 2),
            Text(
              supply.paperSize!,
              style: GoogleFonts.outfit(
                color: warmGray,
                fontSize: 11,
              ),
            ),
          ],
          const Spacer(),
          Text(
            price > 0
                ? 'P${price.toStringAsFixed(2)} / page'
                : 'No price set',
            style: GoogleFonts.outfit(
              color: price > 0 ? posPrimary : warmGray,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
