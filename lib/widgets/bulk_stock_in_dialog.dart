import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:provider/provider.dart';

Future<void> showBulkStockInDialog(
  BuildContext context,
  List<Product> products,
  VoidCallback onRefresh, {
  Product? preselected,
}) async {
  final inventoryProvider = context.read<InventoryProvider>();

  if (products.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No store products found. Add products first.'),
      ),
    );
    return;
  }

  final initial = preselected ?? products.first;

  // Each row: {product, quantity, retailPrice, expiryDate}
  final rows = <Map<String, dynamic>>[
    {
      'product': initial,
      'quantity': '',
      'retailPrice': initial.purchasePrice.toStringAsFixed(2),
      'expiryDate': null,
    },
  ];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isSaving = false;

        void addRow() => setDialogState(
          () => rows.add({
            'product': products.first,
            'quantity': '',
            'retailPrice': products.first.purchasePrice.toStringAsFixed(2),
            'expiryDate': null,
          }),
        );
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                'Bulk Stock In',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: addRow,
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add Row', style: GoogleFonts.outfit()),
                style: TextButton.styleFrom(foregroundColor: posPrimary),
              ),
            ],
          ),
          content: SizedBox(
            width: 750,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Product *',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Quantity *',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Retail Price',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Expiry Date',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  ...rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: posSurfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Product>(
                                  value: row['product'] as Product,
                                  dropdownColor: posSurfaceLight,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  isExpanded: true,
                                  items: products
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(
                                            p.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (p) => setDialogState(() {
                                    row['product'] = p;
                                    row['retailPrice'] = (p?.purchasePrice ?? 0)
                                        .toStringAsFixed(2);
                                  }),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0',
                              initialValue: row['quantity'] as String,
                              numeric: true,
                              onChanged: (v) => row['quantity'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0.00',
                              initialValue: row['retailPrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['retailPrice'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: DateTime.now().add(
                                    const Duration(days: 30),
                                  ),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 10),
                                  ),
                                );
                                if (picked != null) {
                                  setDialogState(
                                    () => row['expiryDate'] = picked,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: posSurfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: row['expiryDate'] != null
                                          ? posPrimary
                                          : posTextMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        row['expiryDate'] != null
                                            ? DateFormat('MMM d, yy').format(
                                                row['expiryDate'] as DateTime,
                                              )
                                            : 'Optional',
                                        style: GoogleFonts.outfit(
                                          color: row['expiryDate'] != null
                                              ? Colors.white
                                              : posTextMuted,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                            onPressed: rows.length > 1
                                ? () => removeRow(i)
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final validRows = rows.where((r) {
                        final qty =
                            double.tryParse(r['quantity'] as String) ?? 0;
                        return qty > 0 && r['product'] != null;
                      }).toList();
                      if (validRows.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter at least one row with quantity > 0',
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        for (final row in validRows) {
                          final product = row['product'] as Product;
                          final qty =
                              double.tryParse(row['quantity'] as String) ?? 0;
                          final price =
                              double.tryParse(row['retailPrice'] as String) ??
                              0;
                          await inventoryProvider.stockIn(
                            productId: product.id,
                            quantity: qty,
                            retailPrice: price > 0
                                ? price
                                : product.purchasePrice,
                            expiryDate: row['expiryDate'] as DateTime?,
                          );
                          saved++;
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk stock in error: $e');
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text('Error after $saved saved: $e'),
                            ),
                          );
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: posPrimary,
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Save All', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    ),
  );
}

Widget bulkTextField({
  required String hint,
  required String initialValue,
  required ValueChanged<String> onChanged,
  bool numeric = false,
}) {
  return TextFormField(
    initialValue: initialValue,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
      filled: true,
      fillColor: posSurfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: posPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      isDense: true,
    ),
  );
}
