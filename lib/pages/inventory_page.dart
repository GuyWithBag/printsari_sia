import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:printsari_sia/widgets/inventory_card.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InventoryPage extends HookWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabController = useTabController(initialLength: 2);
    final currentIndex = useState(0);
    final refreshKey = useState(0);

    final inventory = context.read<InventoryProvider>();
    final productProvider = context.read<ProductProvider>();

    // Start realtime subscriptions once
    useEffect(() {
      inventory.subscribeToChanges();
      productProvider.subscribeToChanges();
      return () {
        inventory.unsubscribe();
        productProvider.unsubscribe();
      };
    }, []);

    // Reactive: rebuilds when hasPendingChanges changes
    final hasPendingChanges =
        context.select<InventoryProvider, bool>((p) => p.hasPendingChanges) ||
        context.select<ProductProvider, bool>((p) => p.hasPendingChanges);

    void hardRefresh() {
      inventory.clearCache();
      productProvider.clearAllCache();
      refreshKey.value++;
    }

    final dataFuture = useMemoized(
      () => Future.wait([
        inventory.getItems(),
        productProvider.getProducts(),
        productProvider.getPrintServices(),
      ]),
      [refreshKey.value],
    );
    final snapshot = useFuture(dataFuture);

    List<InventoryItem> allItems = [];
    List<Product> allProducts = [];
    List<PrintService> allServices = [];

    if (snapshot.hasData) {
      allItems = snapshot.data![0] as List<InventoryItem>;
      allProducts = snapshot.data![1] as List<Product>;
      allServices = snapshot.data![2] as List<PrintService>;
    }

    // Store products: category_id == 1
    final storeItems = allItems.where((item) {
      final product = allProducts.where((p) => p.id == item.productId).firstOrNull;
      return product != null && product.categoryId == 1;
    }).toList();

    // Printing products: category_id == 2
    final printItems = allItems.where((item) {
      final product = allProducts.where((p) => p.id == item.productId).firstOrNull;
      return product != null && product.categoryId == 2;
    }).toList();

    if (snapshot.hasError) {
      return AppPage(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Inventory Management',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Retry',
              onPressed: hardRefresh,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load inventory',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${snapshot.error}',
                style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Inventory Management',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (snapshot.hasData)
            FilledButton.icon(
              onPressed: () => _showNewStockInDialog(
                context,
                allProducts,
                hardRefresh,
              ),
              icon: const Icon(Icons.add_box_outlined, size: 16),
              label: Text('Stock In', style: GoogleFonts.outfit()),
              style: FilledButton.styleFrom(
                backgroundColor: posPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: hasPendingChanges ? Colors.orange : Colors.white,
                ),
                tooltip: hasPendingChanges
                    ? 'Changes detected — tap to sync'
                    : 'Refresh from server',
                onPressed: hardRefresh,
              ),
              if (hasPendingChanges)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
                'Monitor and manage stock levels for both business segments',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
                  label: 'Printing Supplies',
                  icon: Icons.print_outlined,
                  indexState: currentIndex,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Skeletonizer(
                enabled: !snapshot.hasData,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Store Products Tab
                    _InventoryGrid(
                      items: storeItems,
                      products: allProducts,
                      onStockIn: (product) => _showStockInDialog(
                        context,
                        product,
                        hardRefresh,
                      ),
                    ),
                    // Printing Supplies Tab — show print services with ink/paper levels
                    _PrintSuppliesGrid(services: allServices, items: printItems),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryGrid extends StatelessWidget {
  final List<InventoryItem> items;
  final List<Product> products;
  final void Function(Product product) onStockIn;

  const _InventoryGrid({
    required this.items,
    required this.products,
    required this.onStockIn,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No store inventory items',
              style: GoogleFonts.outfit(color: posTextMuted),
            ),
            const SizedBox(height: 12),
            Text(
              'Use "Stock In" on a product to add inventory batches.',
              style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: items.map((item) {
          final product = products.where((p) => p.id == item.productId).firstOrNull;
          return InventoryCard(
            item: item,
            onEdit: () {},
            onStockIn: product != null ? () => onStockIn(product) : null,
          );
        }).toList(),
      ),
    );
  }
}

Future<void> _showStockInDialog(
  BuildContext context,
  Product product,
  VoidCallback onRefresh,
) async {
  final stockController = TextEditingController();
  final priceController = TextEditingController(
    text: product.purchasePrice.toStringAsFixed(2),
  );
  DateTime? selectedExpiry;
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Stock In — ${product.name}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Quantity to add',
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                // Retail price
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Retail price (P)',
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                // Expiry date picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedExpiry = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: posSurfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16,
                            color: selectedExpiry != null
                                ? posPrimary
                                : posTextMuted),
                        const SizedBox(width: 10),
                        Text(
                          selectedExpiry != null
                              ? DateFormat('MMM d, yyyy').format(selectedExpiry!)
                              : 'Select expiry date (optional)',
                          style: GoogleFonts.outfit(
                            color: selectedExpiry != null
                                ? Colors.white
                                : posTextMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    final qty = double.tryParse(stockController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('Quantity must be greater than 0')),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      final inventoryProvider =
                          ctx.read<InventoryProvider>();
                      await inventoryProvider.stockIn(
                        productId: product.id,
                        quantity: qty,
                        retailPrice: price > 0 ? price : product.purchasePrice,
                        expiryDate: selectedExpiry,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Stock in error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
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
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Stock In', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showNewStockInDialog(
  BuildContext context,
  List<Product> products,
  VoidCallback onRefresh,
) async {
  final storeProducts = products.where((p) => p.categoryId == 1).toList();
  if (storeProducts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('No store products found. Add products first.')),
    );
    return;
  }

  Product? selectedProduct = storeProducts.first;
  final stockController = TextEditingController();
  final priceController = TextEditingController(
    text: storeProducts.first.purchasePrice.toStringAsFixed(2),
  );
  DateTime? selectedExpiry;
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Stock In',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Product',
                      labelStyle: GoogleFonts.outfit(color: posTextMuted),
                      filled: true,
                      fillColor: posSurfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: posPrimary, width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: storeProducts
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name),
                            ))
                        .toList(),
                    onChanged: (p) {
                      if (p != null) {
                        setDialogState(() {
                          selectedProduct = p;
                          priceController.text =
                              p.purchasePrice.toStringAsFixed(2);
                        });
                      }
                    },
                  ),
                ),
                // Quantity
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Quantity to add',
                      labelStyle: GoogleFonts.outfit(color: posTextMuted),
                      filled: true,
                      fillColor: posSurfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: posPrimary, width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                // Retail price
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Retail price (P)',
                      labelStyle: GoogleFonts.outfit(color: posTextMuted),
                      filled: true,
                      fillColor: posSurfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: posPrimary, width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                // Expiry date
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate:
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedExpiry = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: posSurfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16,
                            color: selectedExpiry != null
                                ? posPrimary
                                : posTextMuted),
                        const SizedBox(width: 10),
                        Text(
                          selectedExpiry != null
                              ? DateFormat('MMM d, yyyy').format(selectedExpiry!)
                              : 'Select expiry date (optional)',
                          style: GoogleFonts.outfit(
                            color: selectedExpiry != null
                                ? Colors.white
                                : posTextMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    final qty = double.tryParse(stockController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Quantity must be greater than 0')),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      final inventoryProvider = ctx.read<InventoryProvider>();
                      await inventoryProvider.stockIn(
                        productId: selectedProduct!.id,
                        quantity: qty,
                        retailPrice: price > 0
                            ? price
                            : selectedProduct!.purchasePrice,
                        expiryDate: selectedExpiry,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Stock in error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
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
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Stock In', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

class _PrintSuppliesGrid extends StatelessWidget {
  final List<PrintService> services;
  final List<InventoryItem> items;
  const _PrintSuppliesGrid({required this.services, required this.items});

  @override
  Widget build(BuildContext context) {
    // Show print service supply levels + any printing inventory items
    final hasContent = services.isNotEmpty || items.isNotEmpty;

    if (!hasContent) {
      return Center(
        child: Text(
          'No printing supplies data',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (services.isNotEmpty) ...[
            Text(
              'Print Service Supply Levels',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: services.map((svc) => _PrintServiceSupplyCard(service: svc)).toList(),
            ),
          ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Printing Inventory Items',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: items
                  .map((item) => InventoryCard(onEdit: () {}, item: item))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrintServiceSupplyCard extends StatelessWidget {
  final PrintService service;
  const _PrintServiceSupplyCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: posPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_rounded, color: posPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${service.paperSize?.sizeName ?? 'N/A'} · ${service.colorMode?.modeName ?? 'N/A'}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: posTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSupplyRow('Paper Stock', service.paperStock, 'sheets'),
              const SizedBox(height: 8),
              _buildSupplyRow('Ink Level', service.inkLevel, '%'),
              const SizedBox(height: 8),
              _buildCostRow('Cost/Page', service.totalCostPerPage),
              const SizedBox(height: 8),
              _buildCostRow('Base Price', service.basePrice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplyRow(String label, double? value, String unit) {
    final displayValue = value != null ? '${value.toStringAsFixed(0)} $unit' : 'N/A';
    final isLow = value != null && value < 20;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: posTextMuted),
        ),
        Text(
          displayValue,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isLow ? const Color(0xFFFBBF24) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: posTextMuted)),
        Text(
          '\u20B1${value.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
