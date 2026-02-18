import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/dtos/inventory_item.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onEdit;

  const InventoryCard({
    Key? key,

    required this.item,
    required this.onEdit,

  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final String title = item.;
  final String subtitle;
  final String stockLevel;
  final String price;
  final String? expiry;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
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

          // Data Rows
          _buildDataRow(context, 'Stock Level:', stockLevel),
          const SizedBox(height: 12),
          _buildDataRow(context, 'Price:', price),
          if (expiry != null) ...[
            const SizedBox(height: 12),
            _buildDataRow(context, 'Expiry:', expiry!),
          ],
        ],
      ),
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
