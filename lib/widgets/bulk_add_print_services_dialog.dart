import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/providers/activity_log_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/bulk_stock_in_dialog.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showBulkAddPrintServicesDialog(
  BuildContext context,
  VoidCallback onRefresh,
) async {
  final productProviderRef =
      Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef =
      Provider.of<ActivityLogProvider>(context, listen: false);

  // Fetch lookup data before showing dialog
  final supabase = Supabase.instance.client;
  final results = await Future.wait([
    supabase.from('paper_sizes').select().order('id'),
    supabase.from('color_modes').select().order('id'),
    supabase.from('machines').select().order('name'),
  ]);
  final paperSizes = (results[0] as List)
      .map((r) => PaperSize.fromJson(r as Map<String, dynamic>))
      .toList();
  final colorModes = (results[1] as List)
      .map((r) => ColorMode.fromJson(r as Map<String, dynamic>))
      .toList();
  final machines = (results[2] as List)
      .map((r) => Machine.fromJson(r as Map<String, dynamic>))
      .toList();

  if (!context.mounted) return;

  if (paperSizes.isEmpty || colorModes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paper sizes or color modes not found.')),
    );
    return;
  }

  Map<String, dynamic> _newRow() => {
        'name': '',
        'basePrice': '',
        'paperSizeId': paperSizes.first.id,
        'colorModeId': colorModes.first.id,
        'machineId': null,
      };

  // Each row: {name, basePrice, paperSizeId, colorModeId, machineId}
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
                'Add Print Services',
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
            width: 820,
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
                        Expanded(flex: 2, child: Text('Base Price *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Paper Size', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Color Mode', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Machine', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
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
                              hint: 'Service name',
                              initialValue: row['name'] as String,
                              onChanged: (v) => row['name'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0.00',
                              initialValue: row['basePrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['basePrice'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _compactDropdown<int>(
                              value: row['paperSizeId'] as int,
                              items: paperSizes
                                  .map((ps) => DropdownMenuItem(
                                      value: ps.id,
                                      child: Text(ps.sizeName,
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) => setDialogState(
                                  () => row['paperSizeId'] = v ?? paperSizes.first.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _compactDropdown<int>(
                              value: row['colorModeId'] as int,
                              items: colorModes
                                  .map((cm) => DropdownMenuItem(
                                      value: cm.id,
                                      child: Text(cm.modeName,
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) => setDialogState(
                                  () => row['colorModeId'] = v ?? colorModes.first.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _compactDropdown<int?>(
                              value: row['machineId'] as int?,
                              items: [
                                DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('None',
                                        style: GoogleFonts.outfit(
                                            color: posTextMuted))),
                                ...machines.map((m) => DropdownMenuItem<int?>(
                                    value: m.id,
                                    child: Text(m.name,
                                        overflow: TextOverflow.ellipsis))),
                              ],
                              onChanged: (v) =>
                                  setDialogState(() => row['machineId'] = v),
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
                              content:
                                  Text('Enter at least one service name')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        final now = DateTime.now();
                        for (final row in validRows) {
                          final basePrice =
                              double.tryParse(row['basePrice'] as String) ?? 0;
                          await productProviderRef.createPrintService(
                            PrintService(
                              id: 0,
                              name: (row['name'] as String).trim(),
                              description: (row['name'] as String).trim(),
                              paperSizeId: row['paperSizeId'] as int,
                              colorModeId: row['colorModeId'] as int,
                              basePrice: basePrice,
                              inkCostPerPage: 0,
                              paperCostPerPage: 0,
                              electricityCostPerPage: 0,
                              maintenanceCostPerPage: 0,
                              totalCostPerPage: 0,
                              machineId: row['machineId'] as int?,
                              createdAt: now,
                              updatedAt: now,
                            ),
                          );
                          saved++;
                        }
                        activityLogRef.log(
                          actionName: 'Print Service Added',
                          description: 'Bulk added $saved print services',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk add print services error: $e');
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
