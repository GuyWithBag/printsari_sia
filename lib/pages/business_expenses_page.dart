import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/expense_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BusinessExpensesPage extends HookWidget {
  const BusinessExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final refreshKey = useState(0);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final sourceFilter = useState<String>('All');

    final expensesFuture = useMemoized(
      () => expenseProvider.getExpenses(),
      [refreshKey.value],
    );
    final snapshot = useFuture(expensesFuture);

    void refresh() => refreshKey.value++;

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Business Expenses',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Track manual and auto-generated business expenses',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
          ),
        ),
      ),
      body: Skeletonizer(
        enabled: !snapshot.hasData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filter row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => searchQuery.value = value,
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        hintStyle: GoogleFonts.outfit(color: posTextMuted),
                        prefixIcon:
                            const Icon(Icons.search, color: posTextMuted),
                        filled: true,
                        fillColor: posSurfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: posSurfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sourceFilter.value,
                        dropdownColor: posSurfaceLight,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        items: ['All', 'Manual', 'Auto-generated']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) sourceFilter.value = val;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () =>
                        _showExpenseDialog(context, null, refresh),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add Expense', style: GoogleFonts.outfit()),
                    style: FilledButton.styleFrom(
                      backgroundColor: posPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Expense table
              Expanded(
                child: snapshot.hasData
                    ? _ExpenseTable(
                        expenses: snapshot.data!,
                        searchQuery: searchQuery.value,
                        sourceFilter: sourceFilter.value,
                        onRefresh: refresh,
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: posPrimary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTable extends StatelessWidget {
  final List<Expense> expenses;
  final String searchQuery;
  final String sourceFilter;
  final VoidCallback onRefresh;

  const _ExpenseTable({
    required this.expenses,
    required this.searchQuery,
    required this.sourceFilter,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    var filtered = expenses.where((e) {
      // Source filter
      if (sourceFilter == 'Manual' && e.sourceId != 1) return false;
      if (sourceFilter == 'Auto-generated' && e.sourceId != 2) return false;
      // Search filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return e.description.toLowerCase().contains(q) ||
            (e.vendor?.toLowerCase().contains(q) ?? false) ||
            (e.category?.categoryName.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No expenses found',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(posSurfaceLight),
              dataRowColor: WidgetStateProperty.all(posSurface),
              headingTextStyle: GoogleFonts.outfit(
                color: posTextMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              dataTextStyle: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
              ),
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Amount'), numeric: true),
                DataColumn(label: Text('Source')),
                DataColumn(label: Text('Vendor')),
                DataColumn(label: Text('Actions')),
              ],
              rows: filtered.map((expense) {
                final isAuto = expense.sourceId == 2;
                return DataRow(cells: [
                  DataCell(Text(dateFormat.format(expense.date))),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        expense.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(expense.category?.categoryName ?? 'N/A'),
                  ),
                  DataCell(Text(currencyFormat.format(expense.amount))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAuto
                            ? posPrimary.withOpacity(0.15)
                            : const Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAuto ? 'Auto' : 'Manual',
                        style: GoogleFonts.outfit(
                          color: isAuto
                              ? posPrimary
                              : const Color(0xFF3B82F6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(expense.vendor ?? '-')),
                  DataCell(
                    isAuto
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: posAccent,
                                ),
                                onPressed: () => _showExpenseDialog(
                                  context,
                                  expense,
                                  onRefresh,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                onPressed: () => _showDeleteExpenseDialog(
                                  context,
                                  expense,
                                  onRefresh,
                                ),
                              ),
                            ],
                          ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showExpenseDialog(
  BuildContext context,
  Expense? expense,
  VoidCallback onRefresh,
) async {
  final isEditing = expense != null;
  final descController =
      TextEditingController(text: expense?.description ?? '');
  final amountController =
      TextEditingController(text: expense?.amount.toString() ?? '');
  final categoryIdController = TextEditingController(
    text: expense?.categoryId.toString() ?? '1',
  );
  final vendorController =
      TextEditingController(text: expense?.vendor ?? '');
  final receiptController =
      TextEditingController(text: expense?.receiptNumber ?? '');
  final notesController =
      TextEditingController(text: expense?.notes ?? '');
  final selectedDate = ValueNotifier<DateTime>(expense?.date ?? DateTime.now());

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: posSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Edit Expense' : 'Add Expense',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _expenseField('Description', descController),
                _expenseField('Amount', amountController,
                    keyboardType: TextInputType.number),
                _expenseField('Category ID', categoryIdController,
                    keyboardType: TextInputType.number),
                // Date picker row
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (_, date, __) => InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: posPrimary,
                                surface: posSurface,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) selectedDate.value = picked;
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: posSurfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: posTextMuted),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('MMM dd, yyyy').format(date),
                              style: GoogleFonts.outfit(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _expenseField('Vendor', vendorController),
                _expenseField('Receipt Number', receiptController),
                _expenseField('Notes', notesController),
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
            onPressed: () async {
              final provider =
                  Provider.of<ExpenseProvider>(ctx, listen: false);
              try {
                if (isEditing) {
                  await provider.updateExpense(expense.id, {
                    'description': descController.text,
                    'amount':
                        double.tryParse(amountController.text) ?? 0,
                    'category_id':
                        int.tryParse(categoryIdController.text) ?? 1,
                    'date': selectedDate.value.toIso8601String(),
                    'vendor': vendorController.text.isEmpty
                        ? null
                        : vendorController.text,
                    'receipt_number': receiptController.text.isEmpty
                        ? null
                        : receiptController.text,
                    'notes': notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  });
                } else {
                  final now = DateTime.now();
                  await provider.createExpense(Expense(
                    id: 0,
                    description: descController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    categoryId:
                        int.tryParse(categoryIdController.text) ?? 1,
                    date: selectedDate.value,
                    receiptNumber: receiptController.text.isEmpty
                        ? null
                        : receiptController.text,
                    vendor: vendorController.text.isEmpty
                        ? null
                        : vendorController.text,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    sourceId: 1, // manual
                    createdAt: now,
                    updatedAt: now,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
                onRefresh();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: posPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              isEditing ? 'Update' : 'Create',
              style: GoogleFonts.outfit(),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showDeleteExpenseDialog(
  BuildContext context,
  Expense expense,
  VoidCallback onRefresh,
) async {
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Expense',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this expense? This action cannot be undone.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child:
              Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () async {
            final provider =
                Provider.of<ExpenseProvider>(ctx, listen: false);
            try {
              await provider.deleteExpense(expense.id);
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          child: Text('Delete', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
}

Widget _expenseField(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: posTextMuted),
        filled: true,
        fillColor: posSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: posPrimary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}
