import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/expense_provider.dart';
import 'package:printsari_sia/providers/transaction_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/widgets/selection_bar.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessExpensesPage extends HookWidget {
  const BusinessExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.read<ExpenseProvider>();
    // Watch TransactionProvider so that completing a sale auto-refreshes expenses.
    final completedTxCount = context
        .watch<TransactionProvider>()
        .completedTransactionCount;
    final refreshKey = useState(0);
    final selectionMode = useState(false);
    final selectedExpenseIds = useState(<int>{});

    final expensesFuture = useMemoized(
      () => expenseProvider.getExpenses(),
      [refreshKey.value, completedTxCount],
    );
    final snapshot = useFuture(expensesFuture);

    void refresh() => refreshKey.value++;
    void hardRefresh() => refreshKey.value++;

    final expenses = snapshot.data ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayExpenses =
        expenses.where((e) => e.date.isAfter(today.subtract(const Duration(seconds: 1))) && e.date.isBefore(today.add(const Duration(days: 1)))).toList();
    final thisMonthExpenses =
        expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();

    final todayTotal = todayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final monthTotal = thisMonthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final allTotal = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final currencyFormat =
        NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (final e in expenses) {
      final catName = e.category?.categoryName ?? 'Uncategorized';
      categoryTotals[catName] = (categoryTotals[catName] ?? 0) + e.amount;
    }

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh from server',
            onPressed: hardRefresh,
          ),
        ],
      ),
      body: Skeletonizer(
        enabled: !snapshot.hasData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Expenses',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track and manage your business costs',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: posTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.checklist_rounded,
                          color: selectionMode.value ? posPrimary : Colors.white,
                        ),
                        tooltip: selectionMode.value ? 'Exit selection mode' : 'Select expenses to delete',
                        onPressed: () {
                          selectionMode.value = !selectionMode.value;
                          if (!selectionMode.value) {
                            selectedExpenseIds.value = {};
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () =>
                            _showExpenseDialog(context, null, refresh),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Record Expense',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                        style: FilledButton.styleFrom(
                          backgroundColor: posPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary cards row
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.attach_money_rounded,
                      iconColor: const Color(0xFF22C55E),
                      title: "Today's Expenses",
                      amount: currencyFormat.format(todayTotal),
                      subtitle:
                          '${todayExpenses.length} transaction${todayExpenses.length == 1 ? '' : 's'}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.bar_chart_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'This Month',
                      amount: currencyFormat.format(monthTotal),
                      subtitle:
                          '${thisMonthExpenses.length} expense${thisMonthExpenses.length == 1 ? '' : 's'}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: posPrimary,
                      title: 'Total Expenses',
                      amount: currencyFormat.format(allTotal),
                      subtitle: 'All time',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Expenses by Category
              Text(
                'Expenses by Category',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (categoryTotals.isEmpty)
                _GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No expense categories yet',
                        style: GoogleFonts.outfit(color: posTextMuted),
                      ),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categoryTotals.entries.map((entry) {
                    return _GlassPanel(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: posTextMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currencyFormat.format(entry.value),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),

              // Recent Expenses
              Text(
                'Recent Expenses',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (selectedExpenseIds.value.isNotEmpty)
                SelectionBar(
                  count: selectedExpenseIds.value.length,
                  itemLabel: 'expense',
                  onClear: () => selectedExpenseIds.value = {},
                  onDelete: () async {
                    final ok = await confirmBulkDelete(
                      context,
                      selectedExpenseIds.value.length,
                      'expense',
                    );
                    if (!ok || !context.mounted) return;
                    final provider = context.read<ExpenseProvider>();
                    for (final id in selectedExpenseIds.value.toList()) {
                      try {
                        await provider.deleteExpense(id);
                      } catch (_) {}
                    }
                    selectedExpenseIds.value = {};
                    selectionMode.value = false;
                    refresh();
                  },
                ),
              if (expenses.isEmpty)
                _GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No expenses recorded yet',
                        style: GoogleFonts.outfit(color: posTextMuted),
                      ),
                    ),
                  ),
                )
              else
                ...expenses.map((expense) {
                  final isManual = expense.sourceId == 1;
                  final isSelected = selectedExpenseIds.value.contains(expense.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _GlassPanel(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            // Checkbox in selection mode (manual expenses only)
                            if (selectionMode.value && isManual) ...[
                              Checkbox(
                                value: isSelected,
                                activeColor: posPrimary,
                                checkColor: Colors.white,
                                onChanged: (v) {
                                  final s = Set<int>.from(selectedExpenseIds.value);
                                  v == true ? s.add(expense.id) : s.remove(expense.id);
                                  selectedExpenseIds.value = s;
                                },
                              ),
                              const SizedBox(width: 4),
                            ] else if (selectionMode.value) ...[
                              const SizedBox(width: 48),
                            ],
                            // Left side: description, category badge, date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.description,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              posPrimary.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          expense.category?.categoryName ??
                                              'Uncategorized',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: posPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        dateFormat.format(expense.date),
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: posTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Right side: amount + action buttons
                            Text(
                              currencyFormat.format(expense.amount),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (isManual) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: posAccent,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => _showExpenseDialog(
                                  context,
                                  expense,
                                  refresh,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                tooltip: 'Delete',
                                onPressed: () => _showDeleteExpenseDialog(
                                  context,
                                  expense,
                                  refresh,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Reusable widgets --

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;
  final String subtitle;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: posTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              amount,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: posTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: posSurfaceLight.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// -- Dialogs (kept as-is) --

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
  int selectedCategoryId = expense?.categoryId ?? 1;
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
                // Category dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FutureBuilder<List<ExpenseCategory>>(
                    future: Supabase.instance.client
                        .from('expense_categories')
                        .select()
                        .then((data) => (data as List)
                            .map((e) => ExpenseCategory.fromJson(
                                e as Map<String, dynamic>))
                            .toList()),
                    builder: (context, snap) {
                      final categories = snap.data ?? [];
                      return DropdownButtonFormField<int>(
                        value: categories.any((c) => c.id == selectedCategoryId)
                            ? selectedCategoryId
                            : (categories.isNotEmpty
                                ? categories.first.id
                                : null),
                        dropdownColor: posSurfaceLight,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle:
                              GoogleFonts.outfit(color: posTextMuted),
                          filled: true,
                          fillColor: posSurfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: posPrimary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.categoryName),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedCategoryId = val);
                          }
                        },
                      );
                    },
                  ),
                ),
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
                    'category_id': selectedCategoryId,
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
                    categoryId: selectedCategoryId,
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
                debugPrint('Error: $e');
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
              debugPrint('Error: $e');
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
