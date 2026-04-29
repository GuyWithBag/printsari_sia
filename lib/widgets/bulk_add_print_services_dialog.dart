import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/providers/activity_log_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/bulk_stock_in_dialog.dart';
import 'package:provider/provider.dart';

Future<void> showBulkAddPrintServicesDialog(
  BuildContext context,
  VoidCallback onRefresh,
) async {
  final productProviderRef =
      Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef =
      Provider.of<ActivityLogProvider>(context, listen: false);

  // Fetch lookup data before showing dialog
  final results = await Future.wait([
    productProviderRef.getServices(),
    productProviderRef.getMachines(),
    productProviderRef.getServiceSupplies(),
  ]);
  final services = results[0] as List<Service>;
  final machines = results[1] as List<Machine>;
  final supplies = results[2] as List<ServiceSupply>;

  if (!context.mounted) return;

  Map<String, dynamic> _newRow() => {
        'name': '',
        'paperSize': '',
        'colorMode': '',
        'serviceId': services.isNotEmpty ? services.first.id : null,
        'machineId': null,
        'serviceSupplyId': supplies.isNotEmpty ? supplies.first.id : null,
        'sellingPrice': '',
        'supplyCost': '',
        'inkCost': '',
        'electricityCost': '',
        'laborCost': '',
      };

  final rows = <Map<String, dynamic>>[_newRow()];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isSaving = false;

        void addRow() => setDialogState(() => rows.add(_newRow()));
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(
                'Bulk Add Service Types',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
            width: 1100,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 160, child: Text('Name *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 110, child: Text('Service', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 100, child: Text('Paper Size', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 100, child: Text('Color Mode', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 110, child: Text('Machine', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 110, child: Text('Supply', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 90, child: Text('Sell Price', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 80, child: Text('Supply ₱', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 80, child: Text('Ink ₱', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 80, child: Text('Electricity ₱', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        SizedBox(width: 80, child: Text('Labor ₱', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...rows.asMap().entries.map((entry) {
                      final i = entry.key;
                      final row = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 160,
                              child: bulkTextField(
                                hint: 'Type name',
                                initialValue: row['name'] as String,
                                onChanged: (v) => row['name'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 110,
                              child: _compactDropdown<int?>(
                                value: row['serviceId'] as int?,
                                items: [
                                  DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('None', style: GoogleFonts.outfit(color: posTextMuted))),
                                  ...services.map((s) => DropdownMenuItem<int?>(
                                      value: s.id,
                                      child: Text(s.name, overflow: TextOverflow.ellipsis))),
                                ],
                                onChanged: (v) => setDialogState(() => row['serviceId'] = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: bulkTextField(
                                hint: 'e.g. A4',
                                initialValue: row['paperSize'] as String,
                                onChanged: (v) => row['paperSize'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: bulkTextField(
                                hint: 'e.g. BW',
                                initialValue: row['colorMode'] as String,
                                onChanged: (v) => row['colorMode'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 110,
                              child: _compactDropdown<int?>(
                                value: row['machineId'] as int?,
                                items: [
                                  DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('None', style: GoogleFonts.outfit(color: posTextMuted))),
                                  ...machines.map((m) => DropdownMenuItem<int?>(
                                      value: m.id,
                                      child: Text(m.name, overflow: TextOverflow.ellipsis))),
                                ],
                                onChanged: (v) => setDialogState(() => row['machineId'] = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 110,
                              child: _compactDropdown<int?>(
                                value: row['serviceSupplyId'] as int?,
                                items: [
                                  DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('None', style: GoogleFonts.outfit(color: posTextMuted))),
                                  ...supplies.map((s) => DropdownMenuItem<int?>(
                                      value: s.id,
                                      child: Text(s.name, overflow: TextOverflow.ellipsis))),
                                ],
                                onChanged: (v) => setDialogState(() => row['serviceSupplyId'] = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: bulkTextField(
                                hint: '0.00',
                                initialValue: row['sellingPrice'] as String,
                                numeric: true,
                                onChanged: (v) => row['sellingPrice'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: bulkTextField(
                                hint: '0.00',
                                initialValue: row['supplyCost'] as String,
                                numeric: true,
                                onChanged: (v) => row['supplyCost'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: bulkTextField(
                                hint: '0.00',
                                initialValue: row['inkCost'] as String,
                                numeric: true,
                                onChanged: (v) => row['inkCost'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: bulkTextField(
                                hint: '0.00',
                                initialValue: row['electricityCost'] as String,
                                numeric: true,
                                onChanged: (v) => row['electricityCost'] = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: bulkTextField(
                                hint: '0.00',
                                initialValue: row['laborCost'] as String,
                                numeric: true,
                                onChanged: (v) => row['laborCost'] = v,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Color(0xFFEF4444), size: 18),
                              onPressed:
                                  rows.length > 1 ? () => removeRow(i) : null,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
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
                          const SnackBar(
                              content: Text('Enter at least one type name')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        final now = DateTime.now();
                        for (final row in validRows) {
                          final st = await productProviderRef.createServiceType(
                            ServiceType(
                              id: 0,
                              name: (row['name'] as String).trim(),
                              serviceId: row['serviceId'] as int?,
                              machineId: row['machineId'] as int?,
                              serviceSupplyId: row['serviceSupplyId'] as int?,
                              paperSize: (row['paperSize'] as String).isEmpty
                                  ? null
                                  : row['paperSize'] as String,
                              colorMode: (row['colorMode'] as String).isEmpty
                                  ? null
                                  : row['colorMode'] as String,
                              createdAt: now,
                              updatedAt: now,
                            ),
                          );
                          final sellingPrice =
                              double.tryParse(row['sellingPrice'] as String) ?? 0;
                          final supplyCost =
                              double.tryParse(row['supplyCost'] as String) ?? 0;
                          final inkCost =
                              double.tryParse(row['inkCost'] as String) ?? 0;
                          final electricityCost =
                              double.tryParse(row['electricityCost'] as String) ?? 0;
                          final laborCost =
                              double.tryParse(row['laborCost'] as String) ?? 0;
                          await productProviderRef.upsertServiceTypeCost(
                            st.id,
                            {
                              'service_supply_cost': supplyCost,
                              'ink_cost': inkCost,
                              'electricity_cost': electricityCost,
                              'labor_cost': laborCost,
                              'service_selling_price': sellingPrice,
                            },
                          );
                          saved++;
                        }
                        activityLogRef.log(
                          actionName: 'Service Type Added',
                          description: 'Bulk added $saved service types',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk add service types error: $e');
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Error after $saved saved: $e')),
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
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Save All', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    ),
  );
}

Widget _compactDropdown<T>({
  required T value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: posSurfaceLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        dropdownColor: posSurfaceLight,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}
