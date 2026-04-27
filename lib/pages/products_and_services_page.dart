import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/controllers/auth_controller.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/widgets/bulk_add_machines_dialog.dart';
import 'package:printsari_sia/widgets/bulk_add_print_services_dialog.dart';
import 'package:printsari_sia/widgets/bulk_add_products_dialog.dart';
import 'package:printsari_sia/widgets/bulk_add_service_supplies_dialog.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:printsari_sia/widgets/selection_bar.dart';
import 'package:printsari_sia/providers/activity_log_provider.dart';
import 'package:printsari_sia/providers/vendor_provider.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsAndServicesPage extends HookWidget {
  const ProductsAndServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 5);
    final currentIndex = useState(0);
    final refreshKey = useState(0);

    final productProvider = context.read<ProductProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final auth = context.watch<AuthController>();
    final isReadOnly = auth.isRole(UserRoleType.cashier);

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
          'Products & Services',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh from server',
            onPressed: hardRefresh,
          ),
        ],
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
                isReadOnly
                    ? 'View store products and print service offerings'
                    : 'Manage store products and print service offerings',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularTabBar(
              tabController: tabController,
              children: [
                CircularTab(
                  tabController: tabController,
                  index: 0,
                  label: 'Store Products',
                  icon: Icons.inventory_2_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 1,
                  label: 'Print Services',
                  icon: Icons.print_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 2,
                  label: 'Machines',
                  icon: Icons.computer_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 3,
                  label: 'Service Supplies',
                  icon: Icons.science_outlined,
                  indexState: currentIndex,
                ),
                CircularTab(
                  tabController: tabController,
                  index: 4,
                  label: 'Vendors',
                  icon: Icons.store_outlined,
                  indexState: currentIndex,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _StoreProductsTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                    isReadOnly: isReadOnly,
                  ),
                  _PrintServicesTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                    isReadOnly: isReadOnly,
                  ),
                  _MachinesTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                    isReadOnly: isReadOnly,
                  ),
                  _ServiceSuppliesTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                    isReadOnly: isReadOnly,
                  ),
                  _VendorsTab(
                    refreshKey: refreshKey.value,
                    onRefresh: () => refreshKey.value++,
                    isReadOnly: isReadOnly,
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

class _StoreProductsTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;
  final bool isReadOnly;

  const _StoreProductsTab({
    required this.refreshKey,
    required this.onRefresh,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedProductIds = useState(<int>{});

    final dataFuture = useMemoized(
      () => Future.wait([
        productProvider.getProducts(),
        inventoryProvider.getItems(),
      ]),
      [refreshKey],
    );
    final snapshot = useFuture(dataFuture);

    return Skeletonizer(
      enabled: !snapshot.hasData,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => searchQuery.value = value,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: GoogleFonts.outfit(color: posTextMuted),
                    prefixIcon: const Icon(Icons.search, color: posTextMuted),
                    filled: true,
                    fillColor: posSurfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              if (!isReadOnly) ...[
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => showBulkAddProductsDialog(context, onRefresh),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add Product', style: GoogleFonts.outfit()),
                style: FilledButton.styleFrom(
                  backgroundColor: posPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (selectedProductIds.value.isNotEmpty && !isReadOnly)
            SelectionBar(
              count: selectedProductIds.value.length,
              itemLabel: 'product',
              onClear: () => selectedProductIds.value = {},
              onDelete: () async {
                final ok = await confirmBulkDelete(
                  context,
                  selectedProductIds.value.length,
                  'product',
                );
                if (!ok || !context.mounted) return;
                final provider = context.read<ProductProvider>();
                for (final id in selectedProductIds.value.toList()) {
                  try {
                    await provider.deleteProduct(id);
                  } catch (_) {}
                }
                selectedProductIds.value = {};
                onRefresh();
              },
            ),
          Expanded(
            child: snapshot.hasData
                ? _buildProductTable(
                    context,
                    snapshot.data![0] as List<Product>,
                    snapshot.data![1] as List<InventoryItem>,
                    searchQuery.value,
                    isReadOnly,
                    selectedProductIds.value,
                    (ids) => selectedProductIds.value = ids,
                  )
                : const Center(
                    child: CircularProgressIndicator(color: posPrimary),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(
    BuildContext context,
    List<Product> products,
    List<InventoryItem> inventory,
    String searchQuery,
    bool isReadOnly,
    Set<int> selectedIds,
    void Function(Set<int>) onSelectionChanged,
  ) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products yet',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final filteredProducts = searchQuery.isEmpty
        ? products
        : products.where((p) {
            final query = searchQuery.toLowerCase();
            return p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                (p.sku?.toLowerCase().contains(query) ?? false) ||
                (p.supplier?.toLowerCase().contains(query) ?? false);
          }).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'No products match your search',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);

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
              onSelectAll: isReadOnly
                  ? null
                  : (v) => onSelectionChanged(
                        v == true
                            ? filteredProducts.map((p) => p.id).toSet()
                            : {},
                      ),
              columns: [
                const DataColumn(label: Text('Name')),
                const DataColumn(label: Text('Category')),
                const DataColumn(label: Text('Purchase Price'), numeric: true),
                const DataColumn(label: Text('Selling Price'), numeric: true),
                const DataColumn(label: Text('Stock'), numeric: true),
                const DataColumn(label: Text('SKU')),
                const DataColumn(label: Text('Supplier')),
                if (!isReadOnly) const DataColumn(label: Text('Actions')),
              ],
              rows: filteredProducts.map((product) {
                final stock = inventory
                    .where((i) => i.productId == product.id)
                    .fold(0.0, (sum, i) => sum + i.stock);
                return DataRow(
                  selected: selectedIds.contains(product.id),
                  onSelectChanged: isReadOnly
                      ? null
                      : (v) {
                          final s = Set<int>.from(selectedIds);
                          v == true ? s.add(product.id) : s.remove(product.id);
                          onSelectionChanged(s);
                        },
                  cells: [
                  DataCell(Text(product.name)),
                  DataCell(Text(product.category?.categoryName ?? 'N/A')),
                  DataCell(
                    Text(currencyFormat.format(product.purchasePrice)),
                  ),
                  DataCell(
                    Text(product.sellingPrice != null
                        ? currencyFormat.format(product.sellingPrice)
                        : '-'),
                  ),
                  DataCell(
                    Text(
                      stock.toStringAsFixed(0),
                      style: GoogleFonts.outfit(
                        color: stock <= 0
                            ? const Color(0xFFEF4444)
                            : Colors.white,
                      ),
                    ),
                  ),
                  DataCell(Text(product.sku ?? '-')),
                  DataCell(Text(product.supplier ?? '-')),
                  if (!isReadOnly)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: posAccent,
                          ),
                          onPressed: () => _showProductDialog(
                            context,
                            product,
                            onRefresh,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                          onPressed: () => _showDeleteProductDialog(
                            context,
                            product,
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

Future<void> _showProductDialog(
  BuildContext context,
  Product? product,
  VoidCallback onRefresh,
) async {
  final isEditing = product != null;
  final nameController = TextEditingController(text: product?.name ?? '');
  final descController =
      TextEditingController(text: product?.description ?? '');
  final priceController = TextEditingController(
    text: isEditing ? product.purchasePrice.toString() : '',
  );
  final sellingPriceController = TextEditingController(
    text: isEditing && product.sellingPrice != null
        ? product.sellingPrice.toString()
        : '',
  );
  final skuController = TextEditingController(text: product?.sku ?? '');
  final supplierController =
      TextEditingController(text: product?.supplier ?? '');

  // Category dropdown: 1 = store, 2 = printing
  int selectedCategoryId = product?.categoryId ?? 1;
  bool isPerishable = product?.perishable ?? true;

  // Capture providers from the page context (which has access to the provider tree)
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Name', nameController),
                _dialogField('Description', descController),
                _dialogField('Purchase Price', priceController,
                    keyboardType: TextInputType.number),
                _dialogField('Selling Price (optional)', sellingPriceController,
                    keyboardType: TextInputType.number),
                // Category dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Category',
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
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Store')),
                      DropdownMenuItem(value: 2, child: Text('Printing')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedCategoryId = value);
                      }
                    },
                  ),
                ),
                _dialogField('SKU (optional)', skuController),
                _dialogField('Supplier (optional)', supplierController),
                // Perishable toggle
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perishable',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Has expiry date',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isPerishable,
                        activeColor: posPrimary,
                        onChanged: (v) =>
                            setDialogState(() => isPerishable = v),
                      ),
                    ],
                  ),
                ),
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
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }
              try {
                final productName = nameController.text;
                if (isEditing) {
                  await productProviderRef.updateProduct(product.id, {
                    'name': productName,
                    'description': descController.text,
                    'purchase_price':
                        double.tryParse(priceController.text) ?? 0,
                    'selling_price': sellingPriceController.text.isEmpty
                        ? null
                        : double.tryParse(sellingPriceController.text),
                    'category_id': selectedCategoryId,
                    'perishable': isPerishable,
                    'sku': skuController.text.isEmpty
                        ? null
                        : skuController.text,
                    'supplier': supplierController.text.isEmpty
                        ? null
                        : supplierController.text,
                  });
                  activityLogRef.log(
                    actionName: 'Product Updated',
                    description: 'Updated product: $productName',
                  );
                } else {
                  final now = DateTime.now();
                  await productProviderRef.createProduct(Product(
                    id: 0,
                    name: productName,
                    description: descController.text.isEmpty
                        ? productName
                        : descController.text,
                    categoryId: selectedCategoryId,
                    purchasePrice:
                        double.tryParse(priceController.text) ?? 0,
                    sellingPrice: sellingPriceController.text.isEmpty
                        ? null
                        : double.tryParse(sellingPriceController.text),
                    perishable: isPerishable,
                    sku: skuController.text.isEmpty
                        ? null
                        : skuController.text,
                    supplier: supplierController.text.isEmpty
                        ? null
                        : supplierController.text,
                    createdAt: now,
                    updatedAt: now,
                  ));
                  activityLogRef.log(
                    actionName: 'Product Added',
                    description: 'Added new product: $productName',
                  );
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

Future<void> _showDeleteProductDialog(
  BuildContext context,
  Product product,
  VoidCallback onRefresh,
) async {
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Product',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await productProviderRef.deleteProduct(product.id);
              activityLogRef.log(
                actionName: 'Product Deleted',
                description: 'Deleted product: ${product.name}',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              debugPrint('Delete product error: $e');
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

class _PrintServicesTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;
  final bool isReadOnly;

  const _PrintServicesTab({
    required this.refreshKey,
    required this.onRefresh,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedServiceIds = useState(<int>{});

    final servicesFuture = useMemoized(
      () => productProvider.getPrintServices(),
      [refreshKey],
    );
    final snapshot = useFuture(servicesFuture);

    return Skeletonizer(
      enabled: !snapshot.hasData,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => searchQuery.value = value,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    hintStyle: GoogleFonts.outfit(color: posTextMuted),
                    prefixIcon: const Icon(Icons.search, color: posTextMuted),
                    filled: true,
                    fillColor: posSurfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              if (!isReadOnly) ...[
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () =>
                    showBulkAddPrintServicesDialog(context, onRefresh),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add Print Service', style: GoogleFonts.outfit()),
                style: FilledButton.styleFrom(
                  backgroundColor: posPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (selectedServiceIds.value.isNotEmpty && !isReadOnly)
            SelectionBar(
              count: selectedServiceIds.value.length,
              itemLabel: 'print service',
              onClear: () => selectedServiceIds.value = {},
              onDelete: () async {
                final ok = await confirmBulkDelete(
                  context,
                  selectedServiceIds.value.length,
                  'print service',
                );
                if (!ok || !context.mounted) return;
                final provider = context.read<ProductProvider>();
                for (final id in selectedServiceIds.value.toList()) {
                  try {
                    await provider.deletePrintService(id);
                  } catch (_) {}
                }
                selectedServiceIds.value = {};
                onRefresh();
              },
            ),
          Expanded(
            child: snapshot.hasData
                ? _buildServiceTable(
                    context,
                    snapshot.data!,
                    searchQuery.value,
                    isReadOnly,
                    selectedServiceIds.value,
                    (ids) => selectedServiceIds.value = ids,
                  )
                : const Center(
                    child: CircularProgressIndicator(color: posPrimary),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTable(
    BuildContext context,
    List<PrintService> services,
    String searchQuery,
    bool isReadOnly,
    Set<int> selectedIds,
    void Function(Set<int>) onSelectionChanged,
  ) {
    if (services.isEmpty) {
      return Center(
        child: Text(
          'No print services yet',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final filteredServices = searchQuery.isEmpty
        ? services
        : services.where((s) {
            final query = searchQuery.toLowerCase();
            return s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query);
          }).toList();

    if (filteredServices.isEmpty) {
      return Center(
        child: Text(
          'No services match your search',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);

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
              onSelectAll: isReadOnly
                  ? null
                  : (v) => onSelectionChanged(
                        v == true
                            ? filteredServices.map((s) => s.id).toSet()
                            : {},
                      ),
              columns: [
                const DataColumn(label: Text('Name')),
                const DataColumn(label: Text('Machine')),
                const DataColumn(label: Text('Paper Size')),
                const DataColumn(label: Text('Color Mode')),
                const DataColumn(label: Text('Base Price'), numeric: true),
                const DataColumn(label: Text('Cost/Page'), numeric: true),
                if (!isReadOnly) const DataColumn(label: Text('Actions')),
              ],
              rows: filteredServices.map((svc) {
                return DataRow(
                  selected: selectedIds.contains(svc.id),
                  onSelectChanged: isReadOnly
                      ? null
                      : (v) {
                          final s = Set<int>.from(selectedIds);
                          v == true ? s.add(svc.id) : s.remove(svc.id);
                          onSelectionChanged(s);
                        },
                  cells: [
                  DataCell(Text(svc.name)),
                  DataCell(Text(svc.machine?.name ?? '—')),
                  DataCell(Text(svc.paperSize?.sizeName ?? 'N/A')),
                  DataCell(Text(svc.colorMode?.modeName ?? 'N/A')),
                  DataCell(Text(currencyFormat.format(svc.basePrice))),
                  DataCell(
                    Text(currencyFormat.format(svc.totalCostPerPage)),
                  ),
                  if (!isReadOnly)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: posAccent,
                          ),
                          onPressed: () => _showPrintServiceDialog(
                            context,
                            svc,
                            onRefresh,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                          onPressed: () => _showDeleteServiceDialog(
                            context,
                            svc,
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

Future<void> _showPrintServiceDialog(
  BuildContext context,
  PrintService? service,
  VoidCallback onRefresh,
) async {
  final isEditing = service != null;
  final nameController = TextEditingController(text: service?.name ?? '');
  final descController =
      TextEditingController(text: service?.description ?? '');
  final basePriceController = TextEditingController(
    text: isEditing ? service.basePrice.toString() : '',
  );
  final inkCostController = TextEditingController(
    text: isEditing ? service.inkCostPerPage.toString() : '',
  );
  final paperCostController = TextEditingController(
    text: isEditing ? service.paperCostPerPage.toString() : '',
  );
  final electricityCostController = TextEditingController(
    text: isEditing ? service.electricityCostPerPage.toString() : '',
  );
  final maintenanceCostController = TextEditingController(
    text: isEditing ? service.maintenanceCostPerPage.toString() : '',
  );

  // Fetch lookup data for dropdowns
  final supabase = Supabase.instance.client;
  final results = await Future.wait([
    supabase.from('paper_sizes').select().order('id'),
    supabase.from('color_modes').select().order('id'),
    supabase.from('machines').select().order('name'),
    supabase.from('service_supplies').select().order('name'),
  ]);
  final paperSizes = (results[0] as List).map((r) => PaperSize.fromJson(r as Map<String, dynamic>)).toList();
  final colorModes = (results[1] as List).map((r) => ColorMode.fromJson(r as Map<String, dynamic>)).toList();
  final machines = (results[2] as List).map((r) => Machine.fromJson(r as Map<String, dynamic>)).toList();
  final serviceSupplies = (results[3] as List).map((r) => ServiceSupply.fromJson(r as Map<String, dynamic>)).toList();

  int selectedPaperSizeId = service?.paperSizeId ?? (paperSizes.isNotEmpty ? paperSizes.first.id : 1);
  int selectedColorModeId = service?.colorModeId ?? (colorModes.isNotEmpty ? colorModes.first.id : 1);
  int? selectedMachineId = service?.machineId;
  int? selectedServiceSupplyId = service?.serviceSupplyId;

  // Capture providers from the page context
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Edit Print Service' : 'Add Print Service',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Name', nameController),
                _dialogField('Description', descController),
                _dialogField('Base Price', basePriceController,
                    keyboardType: TextInputType.number),
                // Machine dropdown (optional)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int?>(
                    value: selectedMachineId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Machine (optional)',
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
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None', style: GoogleFonts.outfit(color: posTextMuted)),
                      ),
                      ...machines.map((m) => DropdownMenuItem<int?>(
                            value: m.id,
                            child: Text(m.name),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedMachineId = value);
                    },
                  ),
                ),
                // Service Supply dropdown (optional)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int?>(
                    value: selectedServiceSupplyId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Service Supply (optional)',
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
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None', style: GoogleFonts.outfit(color: posTextMuted)),
                      ),
                      ...serviceSupplies.map((s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text('${s.name} (${s.supplyType})'),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedServiceSupplyId = value);
                    },
                  ),
                ),
                // Paper Size dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    value: selectedPaperSizeId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Paper Size',
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
                    items: paperSizes
                        .map((ps) => DropdownMenuItem(
                              value: ps.id,
                              child: Text(ps.sizeName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedPaperSizeId = value);
                      }
                    },
                  ),
                ),
                // Color Mode dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    value: selectedColorModeId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Color Mode',
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
                    items: colorModes
                        .map((cm) => DropdownMenuItem(
                              value: cm.id,
                              child: Text(cm.modeName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedColorModeId = value);
                      }
                    },
                  ),
                ),
                _dialogField('Ink Cost/Page', inkCostController,
                    keyboardType: TextInputType.number),
                _dialogField('Paper Cost/Page', paperCostController,
                    keyboardType: TextInputType.number),
                _dialogField('Electricity Cost/Page', electricityCostController,
                    keyboardType: TextInputType.number),
                _dialogField('Maintenance Cost/Page', maintenanceCostController,
                    keyboardType: TextInputType.number),
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
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }
              final provider = productProviderRef;
              final inkCost =
                  double.tryParse(inkCostController.text) ?? 0;
              final paperCost =
                  double.tryParse(paperCostController.text) ?? 0;
              final elecCost =
                  double.tryParse(electricityCostController.text) ?? 0;
              final maintCost =
                  double.tryParse(maintenanceCostController.text) ?? 0;
              final totalCost = inkCost + paperCost + elecCost + maintCost;

              try {
                final serviceName = nameController.text;
                if (isEditing) {
                  await provider.updatePrintService(service.id, {
                    'name': serviceName,
                    'description': descController.text,
                    'base_price':
                        double.tryParse(basePriceController.text) ?? 0,
                    'paper_size_id': selectedPaperSizeId,
                    'color_mode_id': selectedColorModeId,
                    'machine_id': selectedMachineId,
                    'service_supply_id': selectedServiceSupplyId,
                    'ink_cost_per_page': inkCost,
                    'paper_cost_per_page': paperCost,
                    'electricity_cost_per_page': elecCost,
                    'maintenance_cost_per_page': maintCost,
                    'total_cost_per_page': totalCost,
                  });
                  activityLogRef.log(
                    actionName: 'Print Service Updated',
                    description: 'Updated print service: $serviceName',
                  );
                } else {
                  final now = DateTime.now();
                  await provider.createPrintService(PrintService(
                    id: 0,
                    name: serviceName,
                    description: descController.text.isEmpty
                        ? serviceName
                        : descController.text,
                    paperSizeId: selectedPaperSizeId,
                    colorModeId: selectedColorModeId,
                    machineId: selectedMachineId,
                    serviceSupplyId: selectedServiceSupplyId,
                    basePrice:
                        double.tryParse(basePriceController.text) ?? 0,
                    inkCostPerPage: inkCost,
                    paperCostPerPage: paperCost,
                    electricityCostPerPage: elecCost,
                    maintenanceCostPerPage: maintCost,
                    totalCostPerPage: totalCost,
                    createdAt: now,
                    updatedAt: now,
                  ));
                  activityLogRef.log(
                    actionName: 'Print Service Added',
                    description: 'Added new print service: $serviceName',
                  );
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

Future<void> _showDeleteServiceDialog(
  BuildContext context,
  PrintService service,
  VoidCallback onRefresh,
) async {
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Print Service',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to delete "${service.name}"? This action cannot be undone.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await productProviderRef.deletePrintService(service.id);
              activityLogRef.log(
                actionName: 'Print Service Deleted',
                description: 'Deleted print service: ${service.name}',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              debugPrint('Delete service error: $e');
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

Widget _dialogField(
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

// ── Machines Tab ─────────────────────────────────────────────────────────────

class _MachinesTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;
  final bool isReadOnly;

  const _MachinesTab({
    required this.refreshKey,
    required this.onRefresh,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final machinesFuture = useMemoized(
      () => productProvider.getMachines(),
      [refreshKey],
    );
    final snapshot = useFuture(machinesFuture);

    return Skeletonizer(
      enabled: !snapshot.hasData,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => searchQuery.value = value,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search machines...',
                    hintStyle: GoogleFonts.outfit(color: posTextMuted),
                    prefixIcon: const Icon(Icons.search, color: posTextMuted),
                    filled: true,
                    fillColor: posSurfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              if (!isReadOnly) ...[
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => showBulkAddMachinesDialog(context, onRefresh),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add Machine', style: GoogleFonts.outfit()),
                  style: FilledButton.styleFrom(
                    backgroundColor: posPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: snapshot.hasData
                ? _buildMachineTable(context, snapshot.data!, searchQuery.value, isReadOnly)
                : const Center(child: CircularProgressIndicator(color: posPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineTable(
    BuildContext context,
    List<Machine> machines,
    String searchQuery,
    bool isReadOnly,
  ) {
    if (machines.isEmpty) {
      return Center(
        child: Text('No machines yet', style: GoogleFonts.outfit(color: posTextMuted)),
      );
    }

    final filtered = searchQuery.isEmpty
        ? machines
        : machines.where((m) => m.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('No machines match your search', style: GoogleFonts.outfit(color: posTextMuted)),
      );
    }

    return Container(
      decoration: BoxDecoration(color: posSurface, borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(posSurfaceLight),
              dataRowColor: WidgetStateProperty.all(posSurface),
              headingTextStyle: GoogleFonts.outfit(color: posTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
              dataTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              columns: [
                const DataColumn(label: Text('Name')),
                const DataColumn(label: Text('Status')),
                if (!isReadOnly) const DataColumn(label: Text('Actions')),
              ],
              rows: filtered.map((machine) {
                return DataRow(cells: [
                  DataCell(Text(machine.name)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: machine.isActive
                            ? const Color(0xFF22C55E).withOpacity(0.15)
                            : const Color(0xFFEF4444).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        machine.isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.outfit(
                          color: machine.isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!isReadOnly)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: posAccent),
                            onPressed: () => _showMachineDialog(context, machine, onRefresh),
                          ),
                          IconButton(
                            icon: Icon(
                              machine.isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                              size: 18,
                              color: machine.isActive ? const Color(0xFF22C55E) : posTextMuted,
                            ),
                            tooltip: machine.isActive ? 'Deactivate' : 'Activate',
                            onPressed: () async {
                              final provider = context.read<ProductProvider>();
                              await provider.updateMachine(machine.id, {'is_active': !machine.isActive});
                              onRefresh();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                            onPressed: () => _showDeleteMachineDialog(context, machine, onRefresh),
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

Future<void> _showMachineDialog(
  BuildContext context,
  Machine? machine,
  VoidCallback onRefresh,
) async {
  final isEditing = machine != null;
  final nameController = TextEditingController(text: machine?.name ?? '');
  bool isActive = machine?.isActive ?? true;

  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Edit Machine' : 'Add Machine',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField('Machine Name', nameController),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                    Switch(
                      value: isActive,
                      activeColor: posPrimary,
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }
              try {
                final machineName = nameController.text;
                if (isEditing) {
                  await productProviderRef.updateMachine(machine.id, {
                    'name': machineName,
                    'is_active': isActive,
                  });
                  activityLogRef.log(
                    actionName: 'Machine Updated',
                    description: 'Updated machine: $machineName',
                  );
                } else {
                  final now = DateTime.now();
                  await productProviderRef.createMachine(Machine(
                    id: 0,
                    name: machineName,
                    isActive: isActive,
                    createdAt: now,
                    updatedAt: now,
                  ));
                  activityLogRef.log(
                    actionName: 'Machine Added',
                    description: 'Added new machine: $machineName',
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                onRefresh();
              } catch (e) {
                debugPrint('Error: $e');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: posPrimary, foregroundColor: Colors.white),
            child: Text(isEditing ? 'Update' : 'Create', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showDeleteMachineDialog(
  BuildContext context,
  Machine machine,
  VoidCallback onRefresh,
) async {
  final productProviderRef = Provider.of<ProductProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Machine',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(
        'Are you sure you want to delete "${machine.name}"? Print services assigned to this machine will be unlinked.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await productProviderRef.deleteMachine(machine.id);
              activityLogRef.log(
                actionName: 'Machine Deleted',
                description: 'Deleted machine: ${machine.name}',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              debugPrint('Delete machine error: $e');
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
          child: Text('Delete', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
}

// ── Service Supplies Tab ──────────────────────────────────────────────────────

class _ServiceSuppliesTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;
  final bool isReadOnly;

  const _ServiceSuppliesTab({
    required this.refreshKey,
    required this.onRefresh,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedSupplyIds = useState(<int>{});

    final suppliesFuture = useMemoized(
      () => inventoryProvider.getServiceSupplies(),
      [refreshKey],
    );
    final snapshot = useFuture(suppliesFuture);

    return Skeletonizer(
      enabled: !snapshot.hasData,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => searchQuery.value = value,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search supplies...',
                    hintStyle: GoogleFonts.outfit(color: posTextMuted),
                    prefixIcon: const Icon(Icons.search, color: posTextMuted),
                    filled: true,
                    fillColor: posSurfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              if (!isReadOnly) ...[
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => showBulkAddServiceSuppliesDialog(context, onRefresh),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add Supply', style: GoogleFonts.outfit()),
                  style: FilledButton.styleFrom(
                    backgroundColor: posPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (selectedSupplyIds.value.isNotEmpty && !isReadOnly)
            SelectionBar(
              count: selectedSupplyIds.value.length,
              itemLabel: 'supply',
              onClear: () => selectedSupplyIds.value = {},
              onDelete: () async {
                final ok = await confirmBulkDelete(
                  context,
                  selectedSupplyIds.value.length,
                  'supply',
                );
                if (!ok || !context.mounted) return;
                final provider = context.read<InventoryProvider>();
                for (final id in selectedSupplyIds.value.toList()) {
                  try {
                    await provider.deleteServiceSupply(id);
                  } catch (_) {}
                }
                selectedSupplyIds.value = {};
                onRefresh();
              },
            ),
          Expanded(
            child: snapshot.hasData
                ? _buildSupplyTable(
                    context,
                    snapshot.data!,
                    searchQuery.value,
                    isReadOnly,
                    selectedSupplyIds.value,
                    (ids) => selectedSupplyIds.value = ids,
                  )
                : const Center(child: CircularProgressIndicator(color: posPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyTable(
    BuildContext context,
    List<ServiceSupply> supplies,
    String searchQuery,
    bool isReadOnly,
    Set<int> selectedIds,
    void Function(Set<int>) onSelectionChanged,
  ) {
    if (supplies.isEmpty) {
      return Center(
        child: Text('No service supplies yet', style: GoogleFonts.outfit(color: posTextMuted)),
      );
    }

    final filtered = searchQuery.isEmpty
        ? supplies
        : supplies
            .where((s) =>
                s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                s.supplyType.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('No supplies match your search', style: GoogleFonts.outfit(color: posTextMuted)),
      );
    }

    return Container(
      decoration: BoxDecoration(color: posSurface, borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(posSurfaceLight),
              dataRowColor: WidgetStateProperty.all(posSurface),
              headingTextStyle: GoogleFonts.outfit(color: posTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
              dataTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              onSelectAll: isReadOnly
                  ? null
                  : (v) => onSelectionChanged(
                        v == true
                            ? filtered.map((s) => s.id).toSet()
                            : {},
                      ),
              columns: [
                const DataColumn(label: Text('Name')),
                const DataColumn(label: Text('Type')),
                const DataColumn(label: Text('Paper Size')),
                const DataColumn(label: Text('Unit')),
                const DataColumn(label: Text('Purchase Price')),
                if (!isReadOnly) const DataColumn(label: Text('Actions')),
              ],
              rows: filtered.map((supply) {
                return DataRow(
                  selected: selectedIds.contains(supply.id),
                  onSelectChanged: isReadOnly
                      ? null
                      : (v) {
                          final s = Set<int>.from(selectedIds);
                          v == true ? s.add(supply.id) : s.remove(supply.id);
                          onSelectionChanged(s);
                        },
                  cells: [
                  DataCell(Text(supply.name)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: posPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        supply.supplyType,
                        style: GoogleFonts.outfit(color: posPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(Text(supply.paperSize ?? '—')),
                  DataCell(Text(supply.unit ?? '—')),
                  DataCell(Text('₱${supply.purchasePrice.toStringAsFixed(2)}')),
                  if (!isReadOnly)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: posAccent),
                            onPressed: () => _showServiceSupplyDialog(context, supply, onRefresh),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                            onPressed: () => _showDeleteServiceSupplyDialog(context, supply, onRefresh),
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

Future<void> _showServiceSupplyDialog(
  BuildContext context,
  ServiceSupply? supply,
  VoidCallback onRefresh,
) async {
  final isEditing = supply != null;
  final nameController = TextEditingController(text: supply?.name ?? '');
  final paperSizeController = TextEditingController(text: supply?.paperSize ?? '');
  final unitController = TextEditingController(text: supply?.unit ?? '');
  final priceController = TextEditingController(
    text: isEditing ? supply.purchasePrice.toStringAsFixed(2) : '',
  );
  String selectedType = supply?.supplyType ?? 'paper';

  final inventoryProviderRef = Provider.of<InventoryProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Edit Service Supply' : 'Add Service Supply',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Name', nameController),
                // Supply type dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Supply Type',
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: ['paper', 'ink', 'toner', 'other']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedType = v);
                    },
                  ),
                ),
                // Paper size — only relevant for paper type
                if (selectedType == 'paper')
                  _dialogField('Paper Size (e.g. short, long, a4)', paperSizeController),
                _dialogField('Unit (e.g. ream, bottle, cartridge)', unitController),
                _dialogField('Purchase Price (₱)', priceController,
                    keyboardType: TextInputType.number),
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
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }
              final price = double.tryParse(priceController.text) ?? 0;
              final paperSize = selectedType == 'paper' && paperSizeController.text.isNotEmpty
                  ? paperSizeController.text.trim()
                  : null;
              final unit = unitController.text.isNotEmpty ? unitController.text.trim() : null;
              try {
                final supplyName = nameController.text.trim();
                if (isEditing) {
                  await inventoryProviderRef.updateServiceSupply(supply.id, {
                    'name': supplyName,
                    'supply_type': selectedType,
                    'paper_size': paperSize,
                    'unit': unit,
                    'purchase_price': price,
                  });
                  activityLogRef.log(
                    actionName: 'Service Supply Updated',
                    description: 'Updated service supply: $supplyName',
                  );
                } else {
                  final now = DateTime.now();
                  await inventoryProviderRef.createServiceSupply(ServiceSupply(
                    id: 0,
                    name: supplyName,
                    supplyType: selectedType,
                    paperSize: paperSize,
                    unit: unit,
                    purchasePrice: price,
                    createdAt: now,
                    updatedAt: now,
                  ));
                  activityLogRef.log(
                    actionName: 'Service Supply Added',
                    description: 'Added new service supply: $supplyName',
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                onRefresh();
              } catch (e) {
                debugPrint('Error: $e');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: posPrimary, foregroundColor: Colors.white),
            child: Text(isEditing ? 'Update' : 'Create', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showDeleteServiceSupplyDialog(
  BuildContext context,
  ServiceSupply supply,
  VoidCallback onRefresh,
) async {
  final inventoryProviderRef = Provider.of<InventoryProvider>(context, listen: false);
  final activityLogRef = Provider.of<ActivityLogProvider>(context, listen: false);
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Service Supply',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(
        'Are you sure you want to delete "${supply.name}"? This will also delete its inventory record and unlink it from any print services.',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await inventoryProviderRef.deleteServiceSupply(supply.id);
              activityLogRef.log(
                actionName: 'Service Supply Deleted',
                description: 'Deleted service supply: ${supply.name}',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              debugPrint('Delete supply error: $e');
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
          child: Text('Delete', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
}

// ────────────────────────────────────────────────────────────────────────────
// Vendors Tab
// ────────────────────────────────────────────────────────────────────────────

class _VendorsTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;
  final bool isReadOnly;

  const _VendorsTab({
    required this.refreshKey,
    required this.onRefresh,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.read<VendorProvider>();
    final searchQuery = useState('');

    final vendorsFuture = useMemoized(
      () {
        vendorProvider.clearCache();
        return vendorProvider.getVendors();
      },
      [refreshKey],
    );
    final snapshot = useFuture(vendorsFuture);

    final vendors = snapshot.data ?? <Vendor>[];
    final filtered = searchQuery.value.isEmpty
        ? vendors
        : vendors
            .where((v) =>
                v.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                (v.contactNumber ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                (v.email ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isReadOnly)
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => searchQuery.value = v,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search vendors...',
                    hintStyle: GoogleFonts.outfit(color: posTextMuted),
                    prefixIcon: const Icon(Icons.search, color: posTextMuted, size: 20),
                    filled: true,
                    fillColor: posSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _showVendorDialog(context, null, onRefresh),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add Vendor', style: GoogleFonts.outfit()),
                style: FilledButton.styleFrom(
                  backgroundColor: posPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Skeletonizer(
            enabled: !snapshot.hasData && !snapshot.hasError,
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      snapshot.hasData ? 'No vendors found' : 'Loading...',
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
                            headingRowColor: WidgetStateProperty.all(posSurfaceLight),
                            dataRowColor: WidgetStateProperty.all(posSurface),
                            headingTextStyle: GoogleFonts.outfit(
                                color: posTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
                            dataTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                            columns: [
                              const DataColumn(label: Text('Name')),
                              const DataColumn(label: Text('Contact')),
                              const DataColumn(label: Text('Email')),
                              const DataColumn(label: Text('Address')),
                              if (!isReadOnly) const DataColumn(label: Text('Actions')),
                            ],
                            rows: filtered.map((vendor) {
                              return DataRow(cells: [
                                DataCell(Text(vendor.name)),
                                DataCell(Text(vendor.contactNumber ?? '—')),
                                DataCell(Text(vendor.email ?? '—')),
                                DataCell(Text(vendor.address ?? '—')),
                                if (!isReadOnly)
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 18, color: posAccent),
                                        tooltip: 'Edit',
                                        onPressed: () =>
                                            _showVendorDialog(context, vendor, onRefresh),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: Color(0xFFEF4444)),
                                        tooltip: 'Delete',
                                        onPressed: () =>
                                            _showDeleteVendorDialog(context, vendor, onRefresh),
                                      ),
                                    ],
                                  )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showVendorDialog(
  BuildContext context,
  Vendor? vendor,
  VoidCallback onRefresh,
) async {
  final isEditing = vendor != null;
  final nameController = TextEditingController(text: vendor?.name ?? '');
  final contactController = TextEditingController(text: vendor?.contactNumber ?? '');
  final emailController = TextEditingController(text: vendor?.email ?? '');
  final addressController = TextEditingController(text: vendor?.address ?? '');

  final vendorProvider = context.read<VendorProvider>();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEditing ? 'Edit Vendor' : 'Add Vendor',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField('Name', nameController),
              _dialogField('Contact Number (optional)', contactController,
                  keyboardType: TextInputType.phone),
              _dialogField('Email (optional)', emailController,
                  keyboardType: TextInputType.emailAddress),
              _dialogField('Address (optional)', addressController),
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
          onPressed: () async {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Name is required')),
              );
              return;
            }
            try {
              if (isEditing) {
                await vendorProvider.updateVendor(vendor.id, {
                  'name': nameController.text.trim(),
                  'contact_number': contactController.text.isEmpty ? null : contactController.text.trim(),
                  'email': emailController.text.isEmpty ? null : emailController.text.trim(),
                  'address': addressController.text.isEmpty ? null : addressController.text.trim(),
                });
              } else {
                final now = DateTime.now();
                await vendorProvider.createVendor(Vendor(
                  id: 0,
                  name: nameController.text.trim(),
                  contactNumber: contactController.text.isEmpty ? null : contactController.text.trim(),
                  email: emailController.text.isEmpty ? null : emailController.text.trim(),
                  address: addressController.text.isEmpty ? null : addressController.text.trim(),
                  createdAt: now,
                  updatedAt: now,
                ));
              }
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              debugPrint('Vendor dialog error: $e');
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          style: FilledButton.styleFrom(backgroundColor: posPrimary, foregroundColor: Colors.white),
          child: Text(isEditing ? 'Update' : 'Create', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
}

Future<void> _showDeleteVendorDialog(
  BuildContext context,
  Vendor vendor,
  VoidCallback onRefresh,
) async {
  final vendorProvider = context.read<VendorProvider>();
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Vendor',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(
        'Are you sure you want to delete "${vendor.name}"?',
        style: GoogleFonts.outfit(color: posTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await vendorProvider.deleteVendor(vendor.id);
              if (ctx.mounted) Navigator.pop(ctx);
              onRefresh();
            } catch (e) {
              debugPrint('Delete vendor error: $e');
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
          child: Text('Delete', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
}

