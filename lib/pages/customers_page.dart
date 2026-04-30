import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/customer_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomersPage extends HookWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.read<CustomerProvider>();
    final refreshKey = useState(0);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final dataFuture = useMemoized(
      () {
        customerProvider.clearCache();
        return customerProvider.getCustomers();
      },
      [refreshKey.value],
    );
    final snapshot = useFuture(dataFuture);

    List<Customer> customers = [];
    if (snapshot.hasData) {
      final q = searchQuery.value.toLowerCase();
      customers = q.isEmpty
          ? snapshot.data!
          : snapshot.data!.where((c) {
              return (c.name?.toLowerCase().contains(q) ?? false) ||
                  c.email.toLowerCase().contains(q) ||
                  (c.phone?.contains(q) ?? false);
            }).toList();
    }

    void refresh() {
      customerProvider.clearCache();
      refreshKey.value++;
    }

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Customers',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: refresh,
          ),
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            tooltip: 'Add Customer',
            onPressed: () => _showAddEditDialog(context, null, customerProvider, refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'View and manage your customer list',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (v) => searchQuery.value = v,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                hintStyle: GoogleFonts.outfit(color: posTextMuted),
                prefixIcon: const Icon(Icons.search, color: posTextMuted),
                filled: true,
                fillColor: posSurfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              Expanded(
                child: Center(
                  child: Text(
                    'Failed to load customers',
                    style: GoogleFonts.outfit(color: Colors.redAccent),
                  ),
                ),
              )
            else
              Expanded(
                child: Skeletonizer(
                  enabled: !snapshot.hasData,
                  child: snapshot.hasData && customers.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.value.isEmpty
                                ? 'No customers yet'
                                : 'No customers match your search',
                            style: GoogleFonts.outfit(color: posTextMuted),
                          ),
                        )
                      : Container(
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
                                  headingRowColor:
                                      WidgetStateProperty.all(posSurfaceLight),
                                  dataRowColor:
                                      WidgetStateProperty.all(posSurface),
                                  headingTextStyle: GoogleFonts.outfit(
                                    color: posTextMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  dataTextStyle: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  showCheckboxColumn: false,
                                  columns: const [
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Email')),
                                    DataColumn(label: Text('Phone')),
                                    DataColumn(label: Text('Registered')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: customers.map((c) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(c.name ?? '—')),
                                        DataCell(Text(c.email)),
                                        DataCell(Text(c.phone ?? '—')),
                                        DataCell(Text(
                                          DateFormat('MMM d, yyyy')
                                              .format(c.registeredDate),
                                          style: GoogleFonts.outfit(
                                              color: posTextMuted,
                                              fontSize: 12),
                                        )),
                                        DataCell(Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_rounded,
                                                  size: 16),
                                              color: posTextMuted,
                                              tooltip: 'Edit',
                                              onPressed: () =>
                                                  _showAddEditDialog(
                                                      context,
                                                      c,
                                                      customerProvider,
                                                      refresh),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.archive_rounded,
                                                  size: 16),
                                              color: Colors.orange.shade400,
                                              tooltip: 'Archive',
                                              onPressed: () =>
                                                  _showArchiveDialog(
                                                      context,
                                                      c,
                                                      customerProvider,
                                                      refresh),
                                            ),
                                          ],
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddEditDialog(
  BuildContext context,
  Customer? existing,
  CustomerProvider customerProvider,
  VoidCallback onRefresh,
) async {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final emailController = TextEditingController(text: existing?.email ?? '');
  final phoneController = TextEditingController(text: existing?.phone ?? '');
  final addressController =
      TextEditingController(text: existing?.address ?? '');
  final notesController = TextEditingController(text: existing?.notes ?? '');
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existing == null ? 'Add Customer' : 'Edit Customer',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Name', nameController),
                _field('Email', emailController,
                    keyboardType: TextInputType.emailAddress),
                _field('Phone', phoneController,
                    keyboardType: TextInputType.phone),
                _field('Address', addressController),
                _field('Notes', notesController, maxLines: 3),
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
                    final email = emailController.text.trim();
                    if (email.isEmpty) return;
                    setDialogState(() => isSaving = true);
                    try {
                      final fields = {
                        'name': nameController.text.trim().isEmpty
                            ? null
                            : nameController.text.trim(),
                        'email': email,
                        'phone': phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                        'address': addressController.text.trim().isEmpty
                            ? null
                            : addressController.text.trim(),
                        'notes': notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      };
                      if (existing == null) {
                        await customerProvider.createCustomer(fields);
                      } else {
                        await customerProvider.updateCustomer(
                            existing.id, fields);
                      }
                      onRefresh();
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red.shade700,
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
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Save', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showArchiveDialog(
  BuildContext context,
  Customer customer,
  CustomerProvider customerProvider,
  VoidCallback onRefresh,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Archive Customer',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(
        'Archive "${customer.name ?? customer.email}"? They will be hidden from the customer list but can be restored from Archives.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child:
              Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white),
          child: Text('Archive', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;
  try {
    await customerProvider.archiveCustomer(customer.id);
    onRefresh();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700),
    );
  }
}

Widget _field(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
