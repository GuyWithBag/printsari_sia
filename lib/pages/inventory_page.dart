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
import 'package:supabase_flutter/supabase_flutter.dart';

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

    void editItem(InventoryItem item) =>
        _showEditInventoryDialog(context, item, hardRefresh);

    final dataFuture = useMemoized(
      () => Future.wait([
        inventory.getItems(),
        productProvider.getProducts(),
        inventory.getServiceSupplies(),
      ]),
      [refreshKey.value],
    );
    final snapshot = useFuture(dataFuture);

    List<InventoryItem> allItems = [];
    List<Product> allProducts = [];
    List<ServiceSupply> allServiceSupplies = [];

    if (snapshot.hasData) {
      allItems = snapshot.data![0] as List<InventoryItem>;
      allProducts = snapshot.data![1] as List<Product>;
      allServiceSupplies = snapshot.data![2] as List<ServiceSupply>;
    }

    // Store product items (have a productId)
    final storeItems = allItems.where((item) {
      if (item.productId == null) return false;
      final product = allProducts.where((p) => p.id == item.productId).firstOrNull;
      return product != null;
    }).toList();

    // Supply items (have a serviceSupplyId)
    final supplyItems = allItems.where((item) => item.isSupplyItem).toList();

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
          if (snapshot.hasData && currentIndex.value == 0) ...[
            OutlinedButton.icon(
              onPressed: () => _showBulkStockInDialog(
                context,
                allProducts,
                hardRefresh,
              ),
              icon: const Icon(Icons.playlist_add_rounded, size: 16),
              label: Text('Bulk Stock In', style: GoogleFonts.outfit()),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
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
          ],
          if (snapshot.hasData && currentIndex.value == 1) ...[
            OutlinedButton.icon(
              onPressed: () => _showBulkSupplyStockInDialog(
                context,
                allServiceSupplies,
                hardRefresh,
              ),
              icon: const Icon(Icons.playlist_add_rounded, size: 16),
              label: Text('Bulk Stock In – Supplies', style: GoogleFonts.outfit()),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _showSupplyStockInDialog(
                context,
                allServiceSupplies,
                hardRefresh,
              ),
              icon: const Icon(Icons.add_box_outlined, size: 16),
              label: Text('Stock In – Supplies', style: GoogleFonts.outfit()),
              style: FilledButton.styleFrom(
                backgroundColor: posPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
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
                      onEdit: editItem,
                    ),
                    // Printing Supplies Tab — real supply inventory
                    _SupplyInventoryGrid(
                      items: supplyItems,
                      onStockIn: (supply) => _showSupplyStockInDialog(
                        context,
                        allServiceSupplies,
                        hardRefresh,
                        preselected: supply,
                      ),
                      onEdit: editItem,
                    ),
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
  final void Function(InventoryItem item) onEdit;

  const _InventoryGrid({
    required this.items,
    required this.products,
    required this.onStockIn,
    required this.onEdit,
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
            title: product?.name ?? 'Unknown Product',
            subtitle: product?.category?.categoryName ?? '',
            onEdit: () => onEdit(item),
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
  // Capture provider before showDialog — dialog's ctx lacks the provider tree
  final inventoryProvider = context.read<InventoryProvider>();

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
  // Capture provider before showDialog
  final inventoryProvider = context.read<InventoryProvider>();

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

Future<void> _showEditInventoryDialog(
  BuildContext context,
  InventoryItem item,
  VoidCallback onRefresh,
) async {
  final supabase = Supabase.instance.client;
  final priceController = TextEditingController(
    text: item.retailPrice.toStringAsFixed(2),
  );
  final reorderController = TextEditingController(
    text: (item.reorderLevel ?? 0).toStringAsFixed(0),
  );
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Inventory Item',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Retail Price (₱)',
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
              TextField(
                controller: reorderController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reorder Level',
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
            ],
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
                    final price = double.tryParse(priceController.text);
                    final reorder = double.tryParse(reorderController.text);
                    if (price == null || price <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter a valid price')),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      await supabase.from('inventory_items').update({
                        'retail_price': price,
                        if (reorder != null) 'reorder_level': reorder,
                      }).eq('id', item.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Edit inventory error: $e');
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
                : Text('Save', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

class _SupplyInventoryGrid extends StatelessWidget {
  final List<InventoryItem> items;
  final void Function(ServiceSupply supply) onStockIn;
  final void Function(InventoryItem item) onEdit;

  const _SupplyInventoryGrid({
    required this.items,
    required this.onStockIn,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No supply inventory yet',
              style: GoogleFonts.outfit(color: posTextMuted),
            ),
            const SizedBox(height: 12),
            Text(
              'Use "Stock In – Supplies" to add printing supply stock.',
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
          final supply = item.serviceSupply;
          return InventoryCard(
            item: item,
            title: supply?.name ?? 'Unknown Supply',
            subtitle: supply != null
                ? '${supply.supplyType}${supply.paperSize != null ? ' · ${supply.paperSize}' : ''}'
                : '',
            onEdit: () => onEdit(item),
            onStockIn: supply != null ? () => onStockIn(supply) : null,
          );
        }).toList(),
      ),
    );
  }
}

Future<void> _showSupplyStockInDialog(
  BuildContext context,
  List<ServiceSupply> supplies,
  VoidCallback onRefresh, {
  ServiceSupply? preselected,
}) async {
  final inventoryProvider = context.read<InventoryProvider>();

  if (supplies.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No service supplies found. Add supplies first.')),
    );
    return;
  }

  ServiceSupply? selectedSupply = preselected ?? supplies.first;
  final stockController = TextEditingController();
  final priceController = TextEditingController(
    text: (preselected ?? supplies.first).purchasePrice.toStringAsFixed(2),
  );
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Stock In – Printing Supply',
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
                // Supply selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<ServiceSupply>(
                    value: selectedSupply,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Service Supply',
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
                    items: supplies
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text('${s.name} (${s.supplyType})'),
                            ))
                        .toList(),
                    onChanged: (s) {
                      if (s != null) {
                        setDialogState(() {
                          selectedSupply = s;
                          priceController.text = s.purchasePrice.toStringAsFixed(2);
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
                        borderSide: const BorderSide(color: posPrimary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                // Purchase price
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Purchase price (₱)',
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
                    final qty = double.tryParse(stockController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Quantity must be greater than 0')),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      await inventoryProvider.stockInSupply(
                        serviceSupplyId: selectedSupply!.id,
                        quantity: qty,
                        purchasePrice: price > 0 ? price : selectedSupply!.purchasePrice,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Supply stock in error: $e');
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Stock In', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

// ── Bulk Stock In ─────────────────────────────────────────────────────────────

Future<void> _showBulkStockInDialog(
  BuildContext context,
  List<Product> products,
  VoidCallback onRefresh,
) async {
  final inventoryProvider = context.read<InventoryProvider>();
  final storeProducts = products.where((p) => p.categoryId == 1).toList();

  if (storeProducts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No store products found. Add products first.')),
    );
    return;
  }

  // Each row: {product, quantity, retailPrice, expiryDate}
  final rows = <Map<String, dynamic>>[
    {
      'product': storeProducts.first,
      'quantity': '',
      'retailPrice': storeProducts.first.purchasePrice.toStringAsFixed(2),
      'expiryDate': null,
    },
  ];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isSaving = false;

        void addRow() => setDialogState(() => rows.add({
              'product': storeProducts.first,
              'quantity': '',
              'retailPrice': storeProducts.first.purchasePrice.toStringAsFixed(2),
              'expiryDate': null,
            }));
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(
                'Bulk Stock In',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
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
            width: 750,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Product *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Quantity *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Retail Price', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Expiry Date', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
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
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: posSurfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Product>(
                                  value: row['product'] as Product,
                                  dropdownColor: posSurfaceLight,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                                  isExpanded: true,
                                  items: storeProducts
                                      .map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(p.name, overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (p) => setDialogState(() {
                                    row['product'] = p;
                                    row['retailPrice'] = (p?.purchasePrice ?? 0).toStringAsFixed(2);
                                  }),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _invBulkTextField(
                              hint: '0',
                              initialValue: row['quantity'] as String,
                              numeric: true,
                              onChanged: (v) => row['quantity'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _invBulkTextField(
                              hint: '0.00',
                              initialValue: row['retailPrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['retailPrice'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: DateTime.now().add(const Duration(days: 30)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                                );
                                if (picked != null) {
                                  setDialogState(() => row['expiryDate'] = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: posSurfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: row['expiryDate'] != null ? posPrimary : posTextMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        row['expiryDate'] != null
                                            ? DateFormat('MMM d, yy').format(row['expiryDate'] as DateTime)
                                            : 'Optional',
                                        style: GoogleFonts.outfit(
                                          color: row['expiryDate'] != null ? Colors.white : posTextMuted,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 18),
                            onPressed: rows.length > 1 ? () => removeRow(i) : null,
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
                      final validRows = rows.where((r) {
                        final qty = double.tryParse(r['quantity'] as String) ?? 0;
                        return qty > 0 && r['product'] != null;
                      }).toList();
                      if (validRows.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enter at least one row with quantity > 0')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        for (final row in validRows) {
                          final product = row['product'] as Product;
                          final qty = double.tryParse(row['quantity'] as String) ?? 0;
                          final price = double.tryParse(row['retailPrice'] as String) ?? 0;
                          await inventoryProvider.stockIn(
                            productId: product.id,
                            quantity: qty,
                            retailPrice: price > 0 ? price : product.purchasePrice,
                            expiryDate: row['expiryDate'] as DateTime?,
                          );
                          saved++;
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk stock in error: $e');
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error after $saved saved: $e')),
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Save All', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _showBulkSupplyStockInDialog(
  BuildContext context,
  List<ServiceSupply> supplies,
  VoidCallback onRefresh,
) async {
  final inventoryProvider = context.read<InventoryProvider>();

  if (supplies.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No service supplies found. Add supplies first.')),
    );
    return;
  }

  // Each row: {supply, quantity, purchasePrice}
  final rows = <Map<String, dynamic>>[
    {
      'supply': supplies.first,
      'quantity': '',
      'purchasePrice': supplies.first.purchasePrice.toStringAsFixed(2),
    },
  ];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isSaving = false;

        void addRow() => setDialogState(() => rows.add({
              'supply': supplies.first,
              'quantity': '',
              'purchasePrice': supplies.first.purchasePrice.toStringAsFixed(2),
            }));
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(
                'Bulk Stock In \u2013 Supplies',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
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
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Supply *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Quantity *', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: Text('Purchase Price', style: GoogleFonts.outfit(color: posTextMuted, fontSize: 12))),
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
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: posSurfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<ServiceSupply>(
                                  value: row['supply'] as ServiceSupply,
                                  dropdownColor: posSurfaceLight,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                                  isExpanded: true,
                                  items: supplies
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              '${s.name} (${s.supplyType})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (s) => setDialogState(() {
                                    row['supply'] = s;
                                    row['purchasePrice'] = (s?.purchasePrice ?? 0).toStringAsFixed(2);
                                  }),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _invBulkTextField(
                              hint: '0',
                              initialValue: row['quantity'] as String,
                              numeric: true,
                              onChanged: (v) => row['quantity'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _invBulkTextField(
                              hint: '0.00',
                              initialValue: row['purchasePrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['purchasePrice'] = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 18),
                            onPressed: rows.length > 1 ? () => removeRow(i) : null,
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
                      final validRows = rows.where((r) {
                        final qty = double.tryParse(r['quantity'] as String) ?? 0;
                        return qty > 0 && r['supply'] != null;
                      }).toList();
                      if (validRows.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enter at least one row with quantity > 0')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        for (final row in validRows) {
                          final supply = row['supply'] as ServiceSupply;
                          final qty = double.tryParse(row['quantity'] as String) ?? 0;
                          final price = double.tryParse(row['purchasePrice'] as String) ?? 0;
                          await inventoryProvider.stockInSupply(
                            serviceSupplyId: supply.id,
                            quantity: qty,
                            purchasePrice: price > 0 ? price : supply.purchasePrice,
                          );
                          saved++;
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        onRefresh();
                      } catch (e) {
                        debugPrint('Bulk supply stock in error: $e');
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error after $saved saved: $e')),
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Save All', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    ),
  );
}

Widget _invBulkTextField({
  required String hint,
  required String initialValue,
  required ValueChanged<String> onChanged,
  bool numeric = false,
}) {
  return TextFormField(
    initialValue: initialValue,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: posTextMuted, fontSize: 12),
      filled: true,
      fillColor: posSurfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: posPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      isDense: true,
    ),
  );
}
