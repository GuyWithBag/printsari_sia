import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';

class PrintServiceCard extends StatelessWidget {
  final ServiceType service;

  const PrintServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final totalCost = service.cost?.serviceTotalCost;
    final sellingPrice = service.cost?.serviceSellingPrice;

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
          // Badges
          Row(
            children: [
              if (service.paperSize != null)
                _badge(service.paperSize!),
              if (service.paperSize != null && service.colorMode != null)
                const SizedBox(width: 4),
              if (service.colorMode != null)
                _badge(service.colorMode!),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            service.name,
            style: GoogleFonts.outfit(
              color: posTextMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (totalCost != null)
            Text(
              'Cost: P${totalCost.toStringAsFixed(2)}/pg',
              style: GoogleFonts.outfit(
                color: warmGray.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            sellingPrice != null
                ? 'P${sellingPrice.toStringAsFixed(2)} / page'
                : 'No price set',
            style: GoogleFonts.outfit(
              color: sellingPrice != null ? posPrimary : warmGray,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.blue.shade700,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
