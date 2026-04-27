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
import 'package:printsari_sia/widgets/bulk_stock_in_dialog.dart';
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
      final product = allProducts
          .where((p) => p.id == item.productId)
          .firstOrNull;
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
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load inventory',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
            FilledButton.icon(
              onPressed: () =>
                  showBulkStockInDialog(context, allProducts, hardRefresh),
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
              label: Text(
                'Bulk Stock In – Supplies',
                style: GoogleFonts.outfit(),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                      onStockIn: (item, product) => _showQuickStockInDialog(
                        context,
                        item,
                        product,
                        hardRefresh,
                      ),
                      onStockOut: (item) => _showStockOutDialog(
                        context,
                        item,
                        hardRefresh,
                      ),
                      onEdit: editItem,
                    ),
                    // Printing Supplies Tab — real supply inventory
                    _SupplyInventoryGrid(
                      items: supplyItems,
                      onStockIn: (item, supply) => _showQuickSupplyStockInDialog(
                        context,
                        item,
                        supply,
                        hardRefresh,
                      ),
                      onStockOut: (item) => _showStockOutDialog(
                        context,
                        item,
                        hardRefresh,
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
  final void Function(InventoryItem item, Product product) onStockIn;
  final void Function(InventoryItem item) onStockOut;
  final void Function(InventoryItem item) onEdit;

  const _InventoryGrid({
    required this.items,
    required this.products,
    required this.onStockIn,
    required this.onStockOut,
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
          final product = products
              .where((p) => p.id == item.productId)
              .firstOrNull;
          return InventoryCard(
            item: item,
            title: product?.name ?? 'Unknown Product',
            subtitle: product?.category?.categoryName ?? '',
            onEdit: () => onEdit(item),
            onStockIn: product != null ? () => onStockIn(item, product) : null,
            onStockOut: () => onStockOut(item),
          );
        }).toList(),
      ),
    );
  }
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
                      borderSide: const BorderSide(
                        color: posPrimary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: posTextMuted),
            ),
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
                      await supabase
                          .from('inventory_items')
                          .update({
                            'retail_price': price,
                            if (reorder != null) 'reorder_level': reorder,
                          })
                          .eq('id', item.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Edit inventory error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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
  final void Function(InventoryItem item, ServiceSupply supply) onStockIn;
  final void Function(InventoryItem item) onStockOut;
  final void Function(InventoryItem item) onEdit;

  const _SupplyInventoryGrid({
    required this.items,
    required this.onStockIn,
    required this.onStockOut,
    required this.onEdit,
  });

  static const _typeIcons = <String, IconData>{
    'paper': Icons.description_outlined,
    'ink': Icons.opacity_outlined,
    'toner': Icons.lens_outlined,
    'other': Icons.inventory_2_outlined,
  };

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

    // Group by supply_type
    final grouped = <String, List<InventoryItem>>{};
    for (final item in items) {
      final type = item.serviceSupply?.supplyType ?? 'other';
      grouped.putIfAbsent(type, () => []).add(item);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          final type = entry.key;
          final typeItems = entry.value;
          final icon = _typeIcons[type] ?? Icons.inventory_2_outlined;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: posTextMuted),
                    const SizedBox(width: 8),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: posTextMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: typeItems.map((item) {
                  final supply = item.serviceSupply;
                  return _SupplyCard(
                    item: item,
                    supply: supply,
                    icon: icon,
                    onEdit: () => onEdit(item),
                    onStockIn: supply != null ? () => onStockIn(item, supply) : null,
                    onStockOut: () => onStockOut(item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SupplyCard extends StatelessWidget {
  final InventoryItem item;
  final ServiceSupply? supply;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback? onStockIn;
  final VoidCallback onStockOut;

  const _SupplyCard({
    required this.item,
    required this.supply,
    required this.icon,
    required this.onEdit,
    this.onStockIn,
    required this.onStockOut,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = item.stock <= 0;
    final isLowStock = !isOutOfStock &&
        item.reorderLevel != null &&
        item.stock <= item.reorderLevel!;

    final stockColor = isOutOfStock
        ? Colors.red.shade400
        : isLowStock
            ? Colors.orange.shade400
            : Colors.white;

    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: posSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOutOfStock
                ? Colors.red.withValues(alpha: 0.3)
                : isLowStock
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: icon + name + edit
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: posPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: posPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supply?.name ?? 'Unknown Supply',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (supply?.unit != null)
                        Text(
                          supply!.unit!,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: posTextMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_square, size: 16),
                  color: posTextMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stock count + badge
            Row(
              children: [
                Text(
                  item.stock.toStringAsFixed(0),
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: stockColor,
                  ),
                ),
                const SizedBox(width: 8),
                if (isOutOfStock)
                  _badge('Out of stock', Colors.red.shade400)
                else if (isLowStock)
                  _badge('Low stock', Colors.orange.shade400),
              ],
            ),
            if (supply?.paperSize != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  supply!.paperSize!,
                  style: GoogleFonts.outfit(fontSize: 12, color: posTextMuted),
                ),
              ),
            const SizedBox(height: 14),

            // Buttons
            Row(
              children: [
                if (onStockIn != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onStockIn,
                      icon: const Icon(Icons.add_box_outlined, size: 14),
                      label: Text('In', style: GoogleFonts.outfit(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: posPrimary,
                        side: BorderSide(color: posPrimary.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                if (onStockIn != null) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onStockOut,
                    icon: const Icon(Icons.remove_circle_outline, size: 14),
                    label: Text('Out', style: GoogleFonts.outfit(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade400,
                      side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Future<void> _showQuickStockInDialog(
  BuildContext context,
  InventoryItem item,
  Product product,
  VoidCallback onRefresh,
) async {
  final inventoryProvider = context.read<InventoryProvider>();
  final stockController = TextEditingController();
  final priceController = TextEditingController(
    text: item.retailPrice.toStringAsFixed(2),
  );
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
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.expiryDate != null)
                      Text(
                        'Expiry: ${DateFormat('MMM d, yyyy').format(item.expiryDate!)}',
                        style: GoogleFonts.outfit(
                          color: posTextMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
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
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Retail price (₱)',
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
                    horizontal: 14,
                    vertical: 12,
                  ),
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
                    final qty = double.tryParse(stockController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Quantity must be greater than 0'),
                        ),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      await inventoryProvider.stockIn(
                        productId: product.id,
                        quantity: qty,
                        retailPrice: price > 0 ? price : item.retailPrice,
                        expiryDate: item.expiryDate,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Quick stock in error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Stock In', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showQuickSupplyStockInDialog(
  BuildContext context,
  InventoryItem item,
  ServiceSupply supply,
  VoidCallback onRefresh,
) async {
  final inventoryProvider = context.read<InventoryProvider>();
  final stockController = TextEditingController();
  final priceController = TextEditingController(
    text: item.retailPrice.toStringAsFixed(2),
  );
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
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supply.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${supply.supplyType}${supply.paperSize != null ? ' · ${supply.paperSize}' : ''}',
                      style: GoogleFonts.outfit(
                        color: posTextMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
                    final qty = double.tryParse(stockController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Quantity must be greater than 0'),
                        ),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      await inventoryProvider.stockInSupply(
                        serviceSupplyId: supply.id,
                        quantity: qty,
                        purchasePrice: price > 0 ? price : supply.purchasePrice,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Quick supply stock in error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Stock In', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showStockOutDialog(
  BuildContext context,
  InventoryItem item,
  VoidCallback onRefresh,
) async {
  final inventoryProvider = context.read<InventoryProvider>();
  final qtyController = TextEditingController();
  final notesController = TextEditingController();
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Stock Out',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Current stock: ${item.stock.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(color: posTextMuted, fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Quantity to remove',
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
                ),
              ),
              TextField(
                controller: notesController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
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
                    final qty = double.tryParse(qtyController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Quantity must be greater than 0')),
                      );
                      return;
                    }
                    if (qty > item.stock) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Cannot remove more than current stock (${item.stock.toStringAsFixed(0)})')),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      await inventoryProvider.stockOut(
                        item: item,
                        quantity: qty,
                        notes: notesController.text.isEmpty ? null : notesController.text,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Stock out error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Stock Out', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
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
      const SnackBar(
        content: Text('No service supplies found. Add supplies first.'),
      ),
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
                        borderSide: const BorderSide(
                          color: posPrimary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: supplies
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.name} (${s.supplyType})'),
                          ),
                        )
                        .toList(),
                    onChanged: (s) {
                      if (s != null) {
                        setDialogState(() {
                          selectedSupply = s;
                          priceController.text = s.purchasePrice
                              .toStringAsFixed(2);
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
                        borderSide: const BorderSide(
                          color: posPrimary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                      borderSide: const BorderSide(
                        color: posPrimary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
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
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: posTextMuted),
            ),
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
                          content: Text('Quantity must be greater than 0'),
                        ),
                      );
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    try {
                      await inventoryProvider.stockInSupply(
                        serviceSupplyId: selectedSupply!.id,
                        quantity: qty,
                        purchasePrice: price > 0
                            ? price
                            : selectedSupply!.purchasePrice,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Supply stock in error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Stock In', style: GoogleFonts.outfit()),
          ),
        ],
      ),
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
      const SnackBar(
        content: Text('No service supplies found. Add supplies first.'),
      ),
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

        void addRow() => setDialogState(
          () => rows.add({
            'supply': supplies.first,
            'quantity': '',
            'purchasePrice': supplies.first.purchasePrice.toStringAsFixed(2),
          }),
        );
        void removeRow(int i) => setDialogState(() => rows.removeAt(i));

        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                'Bulk Stock In \u2013 Supplies',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Supply *',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Quantity *',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Purchase Price',
                            style: GoogleFonts.outfit(
                              color: posTextMuted,
                              fontSize: 12,
                            ),
                          ),
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
                            flex: 3,
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: posSurfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<ServiceSupply>(
                                  value: row['supply'] as ServiceSupply,
                                  dropdownColor: posSurfaceLight,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  isExpanded: true,
                                  items: supplies
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            '${s.name} (${s.supplyType})',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (s) => setDialogState(() {
                                    row['supply'] = s;
                                    row['purchasePrice'] =
                                        (s?.purchasePrice ?? 0).toStringAsFixed(
                                          2,
                                        );
                                  }),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0',
                              initialValue: row['quantity'] as String,
                              numeric: true,
                              onChanged: (v) => row['quantity'] = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: bulkTextField(
                              hint: '0.00',
                              initialValue: row['purchasePrice'] as String,
                              numeric: true,
                              onChanged: (v) => row['purchasePrice'] = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                            onPressed: rows.length > 1
                                ? () => removeRow(i)
                                : null,
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
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final validRows = rows.where((r) {
                        final qty =
                            double.tryParse(r['quantity'] as String) ?? 0;
                        return qty > 0 && r['supply'] != null;
                      }).toList();
                      if (validRows.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter at least one row with quantity > 0',
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      int saved = 0;
                      try {
                        for (final row in validRows) {
                          final supply = row['supply'] as ServiceSupply;
                          final qty =
                              double.tryParse(row['quantity'] as String) ?? 0;
                          final price =
                              double.tryParse(row['purchasePrice'] as String) ??
                              0;
                          await inventoryProvider.stockInSupply(
                            serviceSupplyId: supply.id,
                            quantity: qty,
                            purchasePrice: price > 0
                                ? price
                                : supply.purchasePrice,
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
                            SnackBar(
                              content: Text('Error after $saved saved: $e'),
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Save All', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    ),
  );
}

