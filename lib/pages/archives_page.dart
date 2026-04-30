import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/pages/products_and_services_page.dart';
import 'package:printsari_sia/providers/customer_provider.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:provider/provider.dart';

class ArchivesPage extends HookWidget {
  const ArchivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 5);
    final currentIndex = useState(0);
    final refreshKey = useState(0);

    final productProvider = context.read<ProductProvider>();
    final inventoryProvider = context.read<InventoryProvider>();

    void hardRefresh() {
      productProvider.clearAllCache();
      inventoryProvider.clearCache();
      refreshKey.value++;
    }

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Archives',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: hardRefresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Restore archived products, machines, supplies, vendors, and customers',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularTabBar(
              tabController: tabController,
              children: [
                CircularTab(
                  tabController: tabController,
                  index: 0,
                  label: 'Products',
                  icon: Icons.inventory_2_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 1,
                  label: 'Machines',
                  icon: Icons.computer_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 2,
                  label: 'Supplies',
                  icon: Icons.science_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 3,
                  label: 'Vendors',
                  icon: Icons.store_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 4,
                  label: 'Customers',
                  icon: Icons.people_outline,
                  indexState: currentIndex,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  ArchivedProductsTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                  ),
                  ArchivedMachinesTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                  ),
                  ArchivedServiceSuppliesTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                  ),
                  ArchivedVendorsTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                  ),
                  _ArchivedCustomersTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Archived Customers Tab ────────────────────────────────────────────────────

class _ArchivedCustomersTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;

  const _ArchivedCustomersTab({
    required this.refreshKey,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.read<CustomerProvider>();
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final archivedFuture = useMemoized(
      () => customerProvider.getArchivedCustomers(),
      [refreshKey],
    );
    final snapshot = useFuture(archivedFuture);

    List<Customer> customers = [];
    if (snapshot.hasData) {
      final q = searchQuery.value.toLowerCase();
      customers = q.isEmpty
          ? snapshot.data!
          : snapshot.data!.where((c) {
              return (c.name?.toLowerCase().contains(q) ?? false) ||
                  c.email.toLowerCase().contains(q);
            }).toList();
    }

    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (v) => searchQuery.value = v,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search archived customers...',
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
        const SizedBox(height: 12),
        Expanded(
          child: !snapshot.hasData
              ? const Center(
                  child: CircularProgressIndicator(color: posPrimary))
              : customers.isEmpty
                  ? Center(
                      child: Text('No archived customers',
                          style: GoogleFonts.outfit(color: posTextMuted)))
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
                                  color: Colors.white, fontSize: 13),
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: customers.map((c) {
                                return DataRow(cells: [
                                  DataCell(Text(c.name ?? '—')),
                                  DataCell(Text(c.email)),
                                  DataCell(FilledButton.icon(
                                    onPressed: () => _restore(
                                        context, c, customerProvider),
                                    icon: const Icon(Icons.restore, size: 16),
                                    label: Text('Restore',
                                        style: GoogleFonts.outfit()),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: posPrimary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                    ),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Future<void> _restore(
    BuildContext context,
    Customer customer,
    CustomerProvider customerProvider,
  ) async {
    try {
      await customerProvider.restoreCustomer(customer.id);
      onRefresh();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}
