import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductsAndServicesPage extends HookWidget {
  const ProductsAndServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final currentIndex = useState(0);
    final refreshKey = useState(0);

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
                'Manage store products and print service offerings',
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
                  ),
                  _PrintServicesTab(
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

class _StoreProductsTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;

  const _StoreProductsTab({
    required this.refreshKey,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

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
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _showProductDialog(context, null, onRefresh),
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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: snapshot.hasData
                ? _buildProductTable(
                    context,
                    snapshot.data![0] as List<Product>,
                    snapshot.data![1] as List<InventoryItem>,
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
  ) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products yet',
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
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Purchase Price'), numeric: true),
                DataColumn(label: Text('Stock'), numeric: true),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('Actions')),
              ],
              rows: products.map((product) {
                final stock = inventory
                    .where((i) => i.productId == product.id)
                    .fold(0.0, (sum, i) => sum + i.stock);
                return DataRow(cells: [
                  DataCell(Text(product.name)),
                  DataCell(Text(product.category?.categoryName ?? 'N/A')),
                  DataCell(
                    Text(currencyFormat.format(product.purchasePrice)),
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
    text: product?.purchasePrice.toString() ?? '',
  );
  final skuController = TextEditingController(text: product?.sku ?? '');
  final supplierController =
      TextEditingController(text: product?.supplier ?? '');
  final categoryIdController = TextEditingController(
    text: product?.categoryId.toString() ?? '1',
  );

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
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
              _dialogField('Category ID', categoryIdController,
                  keyboardType: TextInputType.number),
              _dialogField('SKU', skuController),
              _dialogField('Supplier', supplierController),
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
            final provider =
                Provider.of<ProductProvider>(ctx, listen: false);
            try {
              if (isEditing) {
                await provider.updateProduct(product.id, {
                  'name': nameController.text,
                  'description': descController.text,
                  'purchase_price':
                      double.tryParse(priceController.text) ?? 0,
                  'category_id':
                      int.tryParse(categoryIdController.text) ?? 1,
                  'sku': skuController.text.isEmpty
                      ? null
                      : skuController.text,
                  'supplier': supplierController.text.isEmpty
                      ? null
                      : supplierController.text,
                });
              } else {
                final now = DateTime.now();
                await provider.createProduct(Product(
                  id: 0,
                  name: nameController.text,
                  description: descController.text,
                  categoryId:
                      int.tryParse(categoryIdController.text) ?? 1,
                  purchasePrice:
                      double.tryParse(priceController.text) ?? 0,
                  sku: skuController.text.isEmpty
                      ? null
                      : skuController.text,
                  supplier: supplierController.text.isEmpty
                      ? null
                      : supplierController.text,
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
  );
}

Future<void> _showDeleteProductDialog(
  BuildContext context,
  Product product,
  VoidCallback onRefresh,
) async {
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
            final provider =
                Provider.of<ProductProvider>(ctx, listen: false);
            try {
              await provider.deleteProduct(product.id);
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

class _PrintServicesTab extends HookWidget {
  final int refreshKey;
  final VoidCallback onRefresh;

  const _PrintServicesTab({
    required this.refreshKey,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final servicesFuture = useMemoized(
      () => productProvider.getPrintServices(),
      [refreshKey],
    );
    final snapshot = useFuture(servicesFuture);

    return Skeletonizer(
      enabled: !snapshot.hasData,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () =>
                  _showPrintServiceDialog(context, null, onRefresh),
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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: snapshot.hasData
                ? _buildServiceTable(context, snapshot.data!)
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
  ) {
    if (services.isEmpty) {
      return Center(
        child: Text(
          'No print services yet',
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
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Paper Size')),
                DataColumn(label: Text('Color Mode')),
                DataColumn(label: Text('Base Price'), numeric: true),
                DataColumn(label: Text('Cost/Page'), numeric: true),
                DataColumn(label: Text('Actions')),
              ],
              rows: services.map((svc) {
                return DataRow(cells: [
                  DataCell(Text(svc.name)),
                  DataCell(Text(svc.paperSize?.sizeName ?? 'N/A')),
                  DataCell(Text(svc.colorMode?.modeName ?? 'N/A')),
                  DataCell(Text(currencyFormat.format(svc.basePrice))),
                  DataCell(
                    Text(currencyFormat.format(svc.totalCostPerPage)),
                  ),
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
  final basePriceController =
      TextEditingController(text: service?.basePrice.toString() ?? '');
  final inkCostController =
      TextEditingController(text: service?.inkCostPerPage.toString() ?? '');
  final paperCostController =
      TextEditingController(text: service?.paperCostPerPage.toString() ?? '');
  final electricityCostController = TextEditingController(
    text: service?.electricityCostPerPage.toString() ?? '',
  );
  final maintenanceCostController = TextEditingController(
    text: service?.maintenanceCostPerPage.toString() ?? '',
  );
  final paperSizeIdController = TextEditingController(
    text: service?.paperSizeId.toString() ?? '1',
  );
  final colorModeIdController = TextEditingController(
    text: service?.colorModeId.toString() ?? '1',
  );

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
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
              _dialogField('Paper Size ID', paperSizeIdController,
                  keyboardType: TextInputType.number),
              _dialogField('Color Mode ID', colorModeIdController,
                  keyboardType: TextInputType.number),
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
            final provider =
                Provider.of<ProductProvider>(ctx, listen: false);
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
              if (isEditing) {
                await provider.updatePrintService(service.id, {
                  'name': nameController.text,
                  'description': descController.text,
                  'base_price':
                      double.tryParse(basePriceController.text) ?? 0,
                  'paper_size_id':
                      int.tryParse(paperSizeIdController.text) ?? 1,
                  'color_mode_id':
                      int.tryParse(colorModeIdController.text) ?? 1,
                  'ink_cost_per_page': inkCost,
                  'paper_cost_per_page': paperCost,
                  'electricity_cost_per_page': elecCost,
                  'maintenance_cost_per_page': maintCost,
                  'total_cost_per_page': totalCost,
                });
              } else {
                final now = DateTime.now();
                await provider.createPrintService(PrintService(
                  id: 0,
                  name: nameController.text,
                  description: descController.text,
                  paperSizeId:
                      int.tryParse(paperSizeIdController.text) ?? 1,
                  colorModeId:
                      int.tryParse(colorModeIdController.text) ?? 1,
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
  );
}

Future<void> _showDeleteServiceDialog(
  BuildContext context,
  PrintService service,
  VoidCallback onRefresh,
) async {
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
            final provider =
                Provider.of<ProductProvider>(ctx, listen: false);
            try {
              await provider.deletePrintService(service.id);
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
