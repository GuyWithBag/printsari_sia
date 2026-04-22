import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';

class SelectionBar extends StatelessWidget {
  final int count;
  final String itemLabel;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  const SelectionBar({
    super.key,
    required this.count,
    required this.itemLabel,
    required this.onClear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final plural = count == 1 ? itemLabel : '${itemLabel}s';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: posPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: posPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_box_rounded, color: posPrimary, size: 18),
          const SizedBox(width: 8),
          Text(
            '$count $plural selected',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: Text('Delete Selected', style: GoogleFonts.outfit()),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: posTextMuted, size: 18),
            onPressed: onClear,
            tooltip: 'Deselect all',
          ),
        ],
      ),
    );
  }
}

Future<bool> confirmBulkDelete(
  BuildContext context,
  int count,
  String label,
) async {
  final plural = count == 1 ? label : '${label}s';
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete $count $plural?',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'This will permanently delete $count $plural. This action cannot be undone.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          child: Text('Delete All', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
  return result ?? false;
}
