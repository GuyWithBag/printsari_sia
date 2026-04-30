import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/dtos/service.dart';

class PrintServiceCard extends StatelessWidget {
  final Service service;
  final double? minPrice;

  const PrintServiceCard({required this.service, this.minPrice});

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Print Service',
              style: GoogleFonts.outfit(
                color: Colors.blue.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
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
            minPrice != null && minPrice! > 0
                ? 'From P${minPrice!.toStringAsFixed(2)} / page'
                : 'Tap to view types',
            style: GoogleFonts.outfit(
              color: minPrice != null && minPrice! > 0 ? posPrimary : warmGray,
              fontSize: minPrice != null && minPrice! > 0 ? 15 : 12,
              fontWeight: minPrice != null && minPrice! > 0
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
