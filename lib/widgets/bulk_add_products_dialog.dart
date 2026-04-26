import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/providers/activity_log_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/bulk_stock_in_dialog.dart';
import 'package:provider/provider.dart';

Future<void> showBulkAddProductsDialog(
  BuildContext context,
  VoidCallback onRefresh,
) async {
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);

  // Each row: {name, purchasePrice, sellingPrice, categoryId, perishable}
  final rows = <Map<String, dynamic>>[
    {'name': '', 'purchasePrice': '', 'sellingPrice': '', 'categoryId': 1, 'perishable': true},
  ];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isSaving = false;

        void addRow() => setDialogState(() => rows.add(
            {'name': '', 'purchasePrice': '', 'sellingPrice': '', 'categoryId': 1, 'perishable': true}));
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(
                'Bulk Add Products',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
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
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Name *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Purchase Price *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Selling Price', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Category', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 80, child: Text('Perishable', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
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
                            child: bulkTextField(
                              hint: 'Product name',
                              initialValue: row['name'] as String,
                              onChanged: (v) => row['name'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0.00',
                              initialValue: row['purchasePrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['purchasePrice'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0.00 (opt)',
                              initialValue: row['sellingPrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['sellingPrice'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: posSurfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: row['categoryId'] as int,
                                  dropdownColor: posSurfaceLight,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 1, child: Text('Store')),
                                    DropdownMenuItem(value: 2, child: Text('Printing')),
                                  ],
                                  onChanged: (v) => setDialogState(() => row['categoryId'] = v ?? 1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Checkbox(
                              value: row['perishable'] as bool,
                              activeColor: posPrimary,
                              checkColor: Colors.white,
                              onChanged: (v) => setDialogState(() => row['perishable'] = v ?? true),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 18),
                            onPressed: rows.length > 1 ? () => removeRow(i) : null,
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
              child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final validRows = rows
                          .where((r) => (r['name'] as String).isNotEmpty)
                          .toList();
                      if (validRows.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enter at least one product name')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        final now = DateTime.now();
                        for (final row in validRows) {
                          final name = row['name'] as String;
                          final purchasePrice =
                              double.tryParse(row['purchasePrice'] as String) ?? 0;
                          final sellingPrice = (row['sellingPrice'] as String).isEmpty
                              ? null
                              : double.tryParse(row['sellingPrice'] as String);
                          await productProviderRef.createProduct(Product(
                            id: 0,
                            name: name,
                            description: name,
                            categoryId: row['categoryId'] as int,
                            purchasePrice: purchasePrice,
                            sellingPrice: sellingPrice,
                            perishable: row['perishable'] as bool,
                            createdAt: now,
                            updatedAt: now,
                          ));
                          saved++;
                        }
                        activityLogRef.log(
                          actionName: 'Product Added',
                          description: 'Bulk added $saved products',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk add error: $e');
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error after $saved saved: $e')),
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Save All', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    ),
  );
}
