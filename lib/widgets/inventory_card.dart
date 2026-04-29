import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/dtos/inventory_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback? onStockIn;
  final VoidCallback? onStockOut;
  final bool isSelected;
  final bool isSelecting;

  const InventoryCard({
    super.key,
    required this.item,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    this.onStockIn,
    this.onStockOut,
    this.isSelected = false,
    this.isSelecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isOutOfStock = item.stock <= 0;
    final bool isLowStock = !isOutOfStock &&
        item.reorderLevel != null &&
        item.stock <= item.reorderLevel!;
    final String stockLevel = item.stock.toStringAsFixed(0);
    final String price = '₱${item.retailPrice.toStringAsFixed(2)}';
    final expiryDate = item.expiryDate;
    final String expiry = expiryDate != null
        ? DateFormat('MMM d, yyyy').format(expiryDate)
        : 'No expiry';

    return Skeletonizer(
      enabled: false,
      child: SizedBox(
        width: 320,
        child: Card(
          color: isSelected
              ? posPrimary.withValues(alpha: 0.08)
              : null,
          shape: isSelected
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: posPrimary, width: 2),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row: Titles + Edit/Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelecting)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? posPrimary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? posPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      )
                    else
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_square),
                        iconSize: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status badges
                if (isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 14, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Out of Stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_outlined, size: 14, color: Colors.orange.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Low Stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isOutOfStock || isLowStock) const SizedBox(height: 12),

                // Data Rows
                _buildDataRow(
                  context,
                  'Stock Level:',
                  stockLevel,
                  valueColor: isOutOfStock
                      ? Colors.red.shade400
                      : isLowStock
                          ? Colors.orange.shade400
                          : null,
                ),
                const SizedBox(height: 12),
                _buildDataRow(context, 'Price:', price),
                const SizedBox(height: 12),
                _buildDataRow(context, 'Expiry:', expiry),
                if (onStockIn != null || onStockOut != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onStockIn != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onStockIn,
                            icon: const Icon(Icons.add_box_outlined, size: 16),
                            label: Text('Stock In', style: GoogleFonts.outfit(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: posPrimary,
                              side: BorderSide(color: posPrimary.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      if (onStockIn != null && onStockOut != null)
                        const SizedBox(width: 8),
                      if (onStockOut != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onStockOut,
                            icon: const Icon(Icons.remove_circle_outline, size: 16),
                            label: Text('Stock Out', style: GoogleFonts.outfit(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade400,
                              side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
