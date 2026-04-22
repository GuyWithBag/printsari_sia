import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printsari_sia/providers/providers.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/print_service_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _pageSize = 9;

class ProductGridPanel extends HookWidget {
  final TextEditingController searchController;
  final ValueNotifier<String> searchQuery;
  final ValueNotifier<int> tabIndex;
  final AsyncSnapshot<List<Product>> productsSnapshot;
  final AsyncSnapshot<List<PrintService>> servicesSnapshot;
  final AsyncSnapshot<List<InventoryItem>> inventorySnapshot;
  final TransactionProvider transactionProvider;

  const ProductGridPanel({
    required this.searchController,
    required this.searchQuery,
    required this.tabIndex,
    required this.productsSnapshot,
    required this.servicesSnapshot,
    required this.inventorySnapshot,
    required this.transactionProvider,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = useState(0);
    final pageInputController = useTextEditingController(text: '1');

    // Reset page when tab or search changes
    useEffect(() {
      currentPage.value = 0;
      pageInputController.text = '1';
      return null;
    }, [tabIndex.value, searchQuery.value]);

    // Compute filtered items for pagination totals
    final allProducts = productsSnapshot.data ?? [];
    final allInventory = inventorySnapshot.data ?? [];
    final allServices = servicesSnapshot.data ?? [];
    final query = searchQuery.value.toLowerCase();

    final filteredBatches = allInventory.where((inv) {
      final product =
          allProducts.where((p) => p.id == inv.productId).firstOrNull;
      if (product == null) return false;
      if (query.isEmpty) return true;
      return product.name.toLowerCase().contains(query) ||
          (product.category?.categoryName.toLowerCase().contains(query) ??
              false);
    }).toList();

    final filteredServices = allServices.where((s) {
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) ||
          (s.paperSize?.sizeName.toLowerCase().contains(query) ?? false) ||
          (s.colorMode?.modeName.toLowerCase().contains(query) ?? false);
    }).toList();

    final isProductTab = tabIndex.value == 0;
    final filteredCount =
        isProductTab ? filteredBatches.length : filteredServices.length;
    final totalPages = (filteredCount / _pageSize).ceil().clamp(1, 99999);
    final safePage = currentPage.value.clamp(0, totalPages - 1);

    void goToPage(int page) {
      final p = page.clamp(0, totalPages - 1);
      currentPage.value = p;
      pageInputController.text = (p + 1).toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: posCream,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top: Toggle + Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                // Segmented toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _SegmentButton(
                        label: 'Sari-Sari Store',
                        icon: Icons.storefront_rounded,
                        isActive: tabIndex.value == 0,
                        onTap: () => tabIndex.value = 0,
                      ),
                      _SegmentButton(
                        label: 'Printing Services',
                        icon: Icons.print_rounded,
                        isActive: tabIndex.value == 1,
                        onTap: () => tabIndex.value = 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Search bar
                TextField(
                  controller: searchController,
                  onChanged: (v) => searchQuery.value = v,
                  style: GoogleFonts.outfit(color: posTextMain, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: tabIndex.value == 0
                        ? 'Search products...'
                        : 'Search print services...',
                    hintStyle: GoogleFonts.outfit(
                      color: posPrimaryDark.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: posPrimaryDark.withValues(alpha: 0.4),
                    ),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: posPrimaryDark.withValues(alpha: 0.4),
                            ),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Body: Grid ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: tabIndex.value == 0
                    ? _buildProductGrid(
                        context, filteredBatches, allProducts, safePage)
                    : _buildServiceGrid(context, filteredServices, safePage),
              ),
            ),
          ),

          // ── Bottom: Pagination ──
          _PaginationBar(
            currentPage: safePage,
            totalPages: totalPages,
            pageInputController: pageInputController,
            onPrev: safePage > 0 ? () => goToPage(safePage - 1) : null,
            onNext:
                safePage < totalPages - 1 ? () => goToPage(safePage + 1) : null,
            onPageSubmit: (raw) {
              final p = int.tryParse(raw);
              if (p != null) goToPage(p - 1);
            },
          ),
        ],
      ),
    );
  }

  // ── Product Grid ──
  Widget _buildProductGrid(
    BuildContext context,
    List<InventoryItem> filteredBatches,
    List<Product> allProducts,
    int page,
  ) {
    final isLoading =
        productsSnapshot.connectionState == ConnectionState.waiting ||
        inventorySnapshot.connectionState == ConnectionState.waiting;

    if (isLoading) return _buildSkeletonGrid();

    if (productsSnapshot.hasError || inventorySnapshot.hasError) {
      return _emptyState(Icons.error_outline, 'Failed to load products');
    }

    if (filteredBatches.isEmpty) {
      return _emptyState(Icons.inventory_2_outlined, 'No products found');
    }

    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, filteredBatches.length);
    final pageItems = filteredBatches.sublist(start, end);

    return GridView.builder(
      key: ValueKey('products-$page'),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.05,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: pageItems.length,
      itemBuilder: (context, index) {
        final inventoryItem = pageItems[index];
        final product =
            allProducts.where((p) => p.id == inventoryItem.productId).firstOrNull;

        if (product == null) return const SizedBox.shrink();

        final cartQty = transactionProvider.cart
            .where((c) => c.inventoryId == inventoryItem.id)
            .fold(0.0, (sum, c) => sum + c.quantity);
        final effectiveStock = inventoryItem.stock - cartQty;

        return _BounceTapCard(
          child: _StoreProductCard(
            product: product,
            inventoryItem: inventoryItem,
            cartQuantity: cartQty,
          ),
          onTap: () {
            if (effectiveStock <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} is out of stock'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
              return;
            }
            _showQuantityDialog(context, product, inventoryItem, effectiveStock);
          },
        );
      },
    );
  }

  // ── Quantity dialog for store products ──
  Future<void> _showQuantityDialog(
    BuildContext context,
    Product product,
    InventoryItem inventoryItem,
    double maxQty,
  ) async {
    final qtyController = TextEditingController(text: '1');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Text(
          'Enter Quantity',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: GoogleFonts.outfit(color: posAccent, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Price: P${inventoryItem.retailPrice.toStringAsFixed(2)} · Stock: ${maxQty.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(color: posTextMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: GoogleFonts.outfit(color: posTextMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: posPrimary),
                ),
                filled: true,
                fillColor: posSurfaceLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: posPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              if (qty > 0 && qty <= maxQty) Navigator.of(ctx).pop(qty);
            },
            child: Text('Add to Cart', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );

    if (result == null || result <= 0) return;
    if (!context.mounted) return;

    final now = DateTime.now();
    transactionProvider.addToCart(
      TransactionItem(
        id: 0,
        transactionId: 0,
        inventoryId: inventoryItem.id,
        productId: product.id,
        productName: product.name,
        quantity: result.toDouble(),
        unitPrice: inventoryItem.retailPrice,
        subtotal: inventoryItem.retailPrice * result,
        categoryId: 1,
        itemCost: product.purchasePrice * result,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  // ── Service Grid ──
  Widget _buildServiceGrid(
    BuildContext context,
    List<PrintService> filteredServices,
    int page,
  ) {
    final isLoading =
        servicesSnapshot.connectionState == ConnectionState.waiting;

    if (isLoading) return _buildSkeletonGrid();

    if (servicesSnapshot.hasError) {
      return _emptyState(Icons.error_outline, 'Failed to load print services');
    }

    if (filteredServices.isEmpty) {
      return _emptyState(Icons.print_disabled, 'No print services found');
    }

    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, filteredServices.length);
    final pageItems = filteredServices.sublist(start, end);

    return GridView.builder(
      key: ValueKey('services-$page'),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.05,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: pageItems.length,
      itemBuilder: (context, index) {
        final service = pageItems[index];
        return _BounceTapCard(
          child: PrintServiceCard(service: service),
          onTap: () => _showPageCountDialog(context, service),
        );
      },
    );
  }

  // ── Page count dialog for print services ──
  Future<void> _showPageCountDialog(
    BuildContext context,
    PrintService service,
  ) async {
    final pageCountController = TextEditingController(text: '1');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Text(
          'Enter Page Count',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: GoogleFonts.outfit(color: posAccent, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Base price: P${service.basePrice.toStringAsFixed(2)} / page',
              style: GoogleFonts.outfit(color: posTextMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pageCountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Number of pages',
                labelStyle: GoogleFonts.outfit(color: posTextMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: posPrimary),
                ),
                filled: true,
                fillColor: posSurfaceLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: posTextMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: posPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final count = int.tryParse(pageCountController.text) ?? 0;
              if (count > 0) Navigator.of(ctx).pop(count);
            },
            child: Text('Add to Cart', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );

    if (result == null || result <= 0) return;
    if (!context.mounted) return;

    try {
      final pageCount = result;
      final totalPrice = service.basePrice * pageCount;
      final inkUsed = service.inkCostPerPage * pageCount;
      final paperUsed = service.paperCostPerPage * pageCount;
      final electricityUsed = service.electricityCostPerPage * pageCount;
      final totalCost = service.totalCostPerPage * pageCount;
      final profitMargin = totalPrice - totalCost;

      final supabase = Supabase.instance.client;
      final insertedOrder = await supabase
          .from('print_orders')
          .insert({
            'service_id': service.id,
            'quantity': pageCount,
            'total_price': totalPrice,
            'ink_used': inkUsed,
            'paper_used': paperUsed,
            'electricity_used': electricityUsed,
            'total_cost': totalCost,
            'profit_margin': profitMargin,
          })
          .select()
          .single();

      final printOrderId = insertedOrder['id'] as int;
      final now = DateTime.now();
      transactionProvider.addToCart(
        TransactionItem(
          id: 0,
          transactionId: 0,
          productId: null,
          productName: service.name,
          quantity: pageCount.toDouble(),
          unitPrice: service.basePrice,
          subtotal: totalPrice,
          categoryId: 2,
          printOrderId: printOrderId,
          itemCost: totalCost,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } catch (e) {
      debugPrint('Print order error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create print order: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Widget _buildSkeletonGrid() {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.05,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: warmGray.withValues(alpha: 0.3), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.outfit(
              color: warmGray.withValues(alpha: 0.5),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pagination Bar
// ─────────────────────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final TextEditingController pageInputController;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final ValueChanged<String> onPageSubmit;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.pageInputController,
    required this.onPrev,
    required this.onNext,
    required this.onPageSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
          ),
          const SizedBox(width: 10),
          // Page input
          SizedBox(
            width: 44,
            height: 36,
            child: TextField(
              controller: pageInputController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: posTextMain,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: posPrimary),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: onPageSubmit,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'of $totalPages',
            style: GoogleFonts.outfit(
              color: warmGray.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          // Next button
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: enabled ? 0.12 : 0.06),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? posTextMain
              : warmGray.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented Toggle Button
// ─────────────────────────────────────────────────────────────────────────────
class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? posPrimary : warmGray.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isActive ? posTextMain : warmGray,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bounce Tap Card Wrapper (AnimatedScale 150ms)
// ─────────────────────────────────────────────────────────────────────────────
class _BounceTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BounceTapCard({required this.child, required this.onTap});

  @override
  State<_BounceTapCard> createState() => _BounceTapCardState();
}

class _BounceTapCardState extends State<_BounceTapCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Store Product Card (cream/light theme)
// ─────────────────────────────────────────────────────────────────────────────
class _StoreProductCard extends StatelessWidget {
  final Product product;
  final InventoryItem? inventoryItem;
  final double cartQuantity;

  const _StoreProductCard({
    required this.product,
    this.inventoryItem,
    this.cartQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final rawStock = inventoryItem?.stock ?? 0;
    final stock = rawStock - cartQuantity;
    final isOutOfStock = inventoryItem == null || stock <= 0;
    final price = inventoryItem?.retailPrice ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: posCreamSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          if (product.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: posPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.category!.categoryName,
                style: GoogleFonts.outfit(
                  color: posPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: GoogleFonts.outfit(
              color: posTextMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Stock
          Row(
            children: [
              Icon(
                isOutOfStock ? Icons.error_outline : Icons.inventory_2_outlined,
                size: 11,
                color: isOutOfStock
                    ? Colors.red.shade400
                    : warmGray.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                isOutOfStock
                    ? 'Out of stock'
                    : '${stock.toStringAsFixed(0)} left',
                style: GoogleFonts.outfit(
                  color: isOutOfStock
                      ? Colors.red.shade400
                      : warmGray.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (product.perishable && inventoryItem?.expiryDate != null)
            Text(
              'Exp: ${DateFormat('MMM d, yyyy').format(inventoryItem!.expiryDate!)}',
              style: GoogleFonts.outfit(
                color: warmGray.withValues(alpha: 0.6),
                fontSize: 9,
              ),
            ),
          Text(
            'P${price.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: posPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
