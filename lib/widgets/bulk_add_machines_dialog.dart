import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/providers/activity_log_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/bulk_stock_in_dialog.dart';
import 'package:provider/provider.dart';

Future<void> showBulkAddMachinesDialog(
  BuildContext context,
  VoidCallback onRefresh,
) async {
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);

  // Each row: {name, isActive}
  final rows = <Map<String, dynamic>>[
    {'name': '', 'isActive': true},
  ];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isSaving = false;

        void addRow() =>
            setDialogState(() => rows.add({'name': '', 'isActive': true}));
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(
                'Add Machines',
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
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text('Machine Name *',
                              style: GoogleFonts.outfit(
                                  color: posTextMuted, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 72,
                          child: Text('Active',
                              style: GoogleFonts.outfit(
                                  color: posTextMuted, fontSize: 12)),
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
                            flex: 4,
                            child: bulkTextField(
                              hint: 'Machine name',
                              initialValue: row['name'] as String,
                              onChanged: (v) => row['name'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 72,
                            child: Checkbox(
                              value: row['isActive'] as bool,
                              activeColor: posPrimary,
                              checkColor: Colors.white,
                              onChanged: (v) => setDialogState(
                                  () => row['isActive'] = v ?? true),
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
                          const SnackBar(
                              content: Text('Enter at least one machine name')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        final now = DateTime.now();
                        for (final row in validRows) {
                          await productProviderRef.createMachine(Machine(
                            id: 0,
                            name: (row['name'] as String).trim(),
                            isActive: row['isActive'] as bool,
                            createdAt: now,
                            updatedAt: now,
                          ));
                          saved++;
                        }
                        activityLogRef.log(
                          actionName: 'Machine Added',
                          description: 'Bulk added $saved machines',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk add machines error: $e');
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
