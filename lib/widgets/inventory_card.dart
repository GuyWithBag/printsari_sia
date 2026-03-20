import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/inventory_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onEdit;

  const InventoryCard({super.key, required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: InventoryItem.getProduct(item),
      builder: (context, asyncSnapshot) {
        final data = asyncSnapshot.data;
        final String title = data?.name ?? "";
        final String subtitle = data?.category?.categoryName ?? "";
        final bool isOutOfStock = item.stock <= 0;
        final String stockLevel = item.stock.toString();
        final String price = item.retailPrice.toString();
        final String expiry = data?.expiryDate?.toString() ?? "";
        return Skeletonizer(
          enabled: asyncSnapshot.data == null,
          child: SizedBox(
            width: 320,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row: Titles + Edit IconButton
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

                    // Out of stock badge
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
                    if (isOutOfStock) const SizedBox(height: 12),

                    // Data Rows
                    _buildDataRow(context, 'Stock Level:', stockLevel),
                    const SizedBox(height: 12),
                    _buildDataRow(context, 'Price:', price),
                    ...[
                      const SizedBox(height: 12),
                      _buildDataRow(context, 'Expiry:', expiry),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
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
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
