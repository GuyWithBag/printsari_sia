import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';

class PrintServiceCard extends StatelessWidget {
  final PrintService service;

  const PrintServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
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
                _badge(service.paperSize!.sizeName),
              if (service.paperSize != null && service.colorMode != null)
                const SizedBox(width: 4),
              if (service.colorMode != null)
                _badge(service.colorMode!.modeName),
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
          Text(
            'Cost: P${service.totalCostPerPage.toStringAsFixed(2)}/pg',
            style: GoogleFonts.outfit(
              color: warmGray.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'P${service.basePrice.toStringAsFixed(2)} / page',
            style: GoogleFonts.outfit(
              color: posPrimary,
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
