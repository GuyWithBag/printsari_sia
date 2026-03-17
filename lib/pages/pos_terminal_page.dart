import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/providers/transaction_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// '/'

class POSTerminalPage extends HookWidget {
  const POSTerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final tabController = useTabController(initialLength: 2);
    final tabIndex = useState(0);
    final selectedPaymentMethod = useState(1); // 1=Cash default

    final productProvider = context.read<ProductProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    final productsFuture = useMemoized(
      () => productProvider.getProducts(),
      [productProvider],
    );
    final servicesFuture = useMemoized(
      () => productProvider.getPrintServices(),
      [productProvider],
    );
    final inventoryFuture = useMemoized(
      () => inventoryProvider.getItems(),
      [inventoryProvider],
    );

    final productsSnapshot = useFuture(productsFuture);
    final servicesSnapshot = useFuture(servicesFuture);
    final inventorySnapshot = useFuture(inventoryFuture);

    final posTextStyle = GoogleFonts.outfit();

    return AppPage(
      body: Container(
        color: posBg,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Product Catalog (~60%)
            Expanded(
              flex: 6,
              child: _LeftPanel(
                searchController: searchController,
                searchQuery: searchQuery,
                tabController: tabController,
                tabIndex: tabIndex,
                productsSnapshot: productsSnapshot,
                servicesSnapshot: servicesSnapshot,
                inventorySnapshot: inventorySnapshot,
                transactionProvider: transactionProvider,
                posTextStyle: posTextStyle,
              ),
            ),
            const SizedBox(width: 16),
            // Right Panel - Cart (~40%)
            Expanded(
              flex: 4,
              child: _RightPanel(
                transactionProvider: transactionProvider,
                selectedPaymentMethod: selectedPaymentMethod,
                posTextStyle: posTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Left Panel
// ---------------------------------------------------------------------------
class _LeftPanel extends HookWidget {
  final TextEditingController searchController;
  final ValueNotifier<String> searchQuery;
  final TabController tabController;
  final ValueNotifier<int> tabIndex;
  final AsyncSnapshot<List<Product>> productsSnapshot;
  final AsyncSnapshot<List<PrintService>> servicesSnapshot;
  final AsyncSnapshot<List<InventoryItem>> inventorySnapshot;
  final TransactionProvider transactionProvider;
  final TextStyle posTextStyle;

  const _LeftPanel({
    required this.searchController,
    required this.searchQuery,
    required this.tabController,
    required this.tabIndex,
    required this.productsSnapshot,
    required this.servicesSnapshot,
    required this.inventorySnapshot,
    required this.transactionProvider,
    required this.posTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: posSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search products or services...',
              hintStyle: GoogleFonts.outfit(color: posTextMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: posTextMuted),
              suffixIcon: searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: posTextMuted),
                      onPressed: () {
                        searchController.clear();
                        searchQuery.value = '';
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tabs
        Row(
          children: [
            CircularTabBar(
              tabController: tabController,
              children: [
                CircularTab(
                  label: 'Store Products',
                  icon: Icons.storefront_rounded,
                  tabController: tabController,
                  index: 0,
                  indexState: tabIndex,
                ),
                CircularTab(
                  label: 'Print Services',
                  icon: Icons.print_rounded,
                  tabController: tabController,
                  index: 1,
                  indexState: tabIndex,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: tabIndex.value == 0
                ? _buildProductGrid(context)
                : _buildServiceGrid(context),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    final isLoading = productsSnapshot.connectionState ==
            ConnectionState.waiting ||
        inventorySnapshot.connectionState == ConnectionState.waiting;

    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => _buildSkeletonCard(),
        ),
      );
    }

    if (productsSnapshot.hasError || inventorySnapshot.hasError) {
      return Center(
        child: Text(
          'Failed to load products',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final products = productsSnapshot.data ?? [];
    final inventory = inventorySnapshot.data ?? [];
    final query = searchQuery.value.toLowerCase();

    final filtered = products.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          (p.category?.categoryName.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                color: posTextMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              'No products found',
              style: GoogleFonts.outfit(color: posTextMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        final inventoryItem = inventory
            .where((inv) => inv.productId == product.id)
            .firstOrNull;

        return _ProductCard(
          product: product,
          inventoryItem: inventoryItem,
          onTap: () {
            if (inventoryItem == null || inventoryItem.stock <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} is out of stock'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
              return;
            }
            final now = DateTime.now();
            final item = TransactionItem(
              id: 0,
              transactionId: 0,
              inventoryId: inventoryItem.id,
              productId: product.id,
              productName: product.name,
              quantity: 1,
              unitPrice: inventoryItem.retailPrice,
              subtotal: inventoryItem.retailPrice,
              categoryId: 1,
              itemCost: product.purchasePrice,
              createdAt: now,
              updatedAt: now,
            );
            transactionProvider.addToCart(item);
          },
        );
      },
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    final isLoading =
        servicesSnapshot.connectionState == ConnectionState.waiting;

    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => _buildSkeletonCard(),
        ),
      );
    }

    if (servicesSnapshot.hasError) {
      return Center(
        child: Text(
          'Failed to load print services',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    final services = servicesSnapshot.data ?? [];
    final query = searchQuery.value.toLowerCase();

    final filtered = services.where((s) {
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) ||
          (s.paperSize?.sizeName.toLowerCase().contains(query) ?? false) ||
          (s.colorMode?.modeName.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.print_disabled, color: posTextMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              'No print services found',
              style: GoogleFonts.outfit(color: posTextMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final service = filtered[index];
        return _PrintServiceCard(
          service: service,
          onTap: () => _showPageCountDialog(context, service),
        );
      },
    );
  }

  Future<void> _showPageCountDialog(
    BuildContext context,
    PrintService service,
  ) async {
    final pageCountController = TextEditingController(text: '1');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: posSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
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
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
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
                final count =
                    int.tryParse(pageCountController.text) ?? 0;
                if (count > 0) {
                  Navigator.of(ctx).pop(count);
                }
              },
              child: Text('Add to Cart', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
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

      // Insert print order into Supabase
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
      final item = TransactionItem(
        id: 0,
        transactionId: 0,
        productId: service.id,
        productName: service.name,
        quantity: pageCount.toDouble(),
        unitPrice: service.basePrice,
        subtotal: totalPrice,
        categoryId: 2,
        printOrderId: printOrderId,
        itemCost: totalCost,
        createdAt: now,
        updatedAt: now,
      );
      transactionProvider.addToCart(item);
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

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: posSurfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: posSurfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: 50,
            height: 16,
            decoration: BoxDecoration(
              color: posSurfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product Card
// ---------------------------------------------------------------------------
class _ProductCard extends StatelessWidget {
  final Product product;
  final InventoryItem? inventoryItem;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.inventoryItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock =
        inventoryItem == null || inventoryItem!.stock <= 0;
    final stock = inventoryItem?.stock ?? 0;
    final price = inventoryItem?.retailPrice ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: posSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOutOfStock
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              if (product.category != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: posPrimary.withOpacity(0.15),
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
              const SizedBox(height: 8),

              // Product name
              Text(
                product.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Stock indicator
              Row(
                children: [
                  Icon(
                    isOutOfStock
                        ? Icons.error_outline
                        : Icons.inventory_2_outlined,
                    size: 12,
                    color: isOutOfStock ? Colors.red.shade400 : posTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOutOfStock
                        ? 'Out of stock'
                        : '${stock.toStringAsFixed(0)} in stock',
                    style: GoogleFonts.outfit(
                      color:
                          isOutOfStock ? Colors.red.shade400 : posTextMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Price
              Text(
                'P${price.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  color: posAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Print Service Card
// ---------------------------------------------------------------------------
class _PrintServiceCard extends StatelessWidget {
  final PrintService service;
  final VoidCallback onTap;

  const _PrintServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: posSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badges row
              Row(
                children: [
                  if (service.paperSize != null)
                    _badge(service.paperSize!.sizeName),
                  if (service.paperSize != null && service.colorMode != null)
                    const SizedBox(width: 6),
                  if (service.colorMode != null)
                    _badge(service.colorMode!.modeName),
                ],
              ),
              const SizedBox(height: 8),

              // Service name
              Text(
                service.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Cost breakdown hint
              Text(
                'Cost: P${service.totalCostPerPage.toStringAsFixed(2)}/page',
                style: GoogleFonts.outfit(color: posTextMuted, fontSize: 11),
              ),
              const SizedBox(height: 6),

              // Base price
              Text(
                'P${service.basePrice.toStringAsFixed(2)} / page',
                style: GoogleFonts.outfit(
                  color: posAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: posSurfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: posTextMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Right Panel (Cart)
// ---------------------------------------------------------------------------
class _RightPanel extends HookWidget {
  final TransactionProvider transactionProvider;
  final ValueNotifier<int> selectedPaymentMethod;
  final TextStyle posTextStyle;

  const _RightPanel({
    required this.transactionProvider,
    required this.selectedPaymentMethod,
    required this.posTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cart = transactionProvider.cart;
    final isCheckingOut = useState(false);

    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: posPrimary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Current Order',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: posPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cart.length}',
                    style: GoogleFonts.outfit(
                      color: posPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => transactionProvider.clearCart(),
                    icon: const Icon(Icons.delete_sweep_rounded,
                        size: 16, color: posTextMuted),
                    label: Text(
                      'Clear',
                      style: GoogleFonts.outfit(
                          color: posTextMuted, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
              ],
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.06), height: 1),

          // Cart items list
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            color: posTextMuted.withOpacity(0.4), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Cart is empty',
                          style: GoogleFonts.outfit(
                            color: posTextMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap a product or service to add it',
                          style: GoogleFonts.outfit(
                            color: posTextMuted.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withOpacity(0.04),
                      height: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _CartItemTile(
                        item: item,
                        onIncrease: () {
                          transactionProvider.updateCartItemQuantity(
                            index,
                            item.quantity + 1,
                          );
                        },
                        onDecrease: () {
                          if (item.quantity > 1) {
                            transactionProvider.updateCartItemQuantity(
                              index,
                              item.quantity - 1,
                            );
                          }
                        },
                        onRemove: () {
                          transactionProvider.removeFromCart(index);
                        },
                      );
                    },
                  ),
          ),

          // Order Summary + Checkout
          if (cart.isNotEmpty) ...[
            Divider(color: Colors.white.withOpacity(0.06), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  _summaryRow('Subtotal',
                      'P${transactionProvider.cartSubtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _summaryRow(
                    'Store Revenue',
                    'P${transactionProvider.cartStoreRevenue.toStringAsFixed(2)}',
                    muted: true,
                  ),
                  const SizedBox(height: 6),
                  _summaryRow(
                    'Printing Revenue',
                    'P${transactionProvider.cartPrintingRevenue.toStringAsFixed(2)}',
                    muted: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'P${transactionProvider.cartSubtotal.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: posAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment method selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _paymentChip('Cash', Icons.money_rounded, 1,
                      selectedPaymentMethod),
                  const SizedBox(width: 6),
                  _paymentChip('GCash', Icons.phone_android_rounded, 2,
                      selectedPaymentMethod),
                  const SizedBox(width: 6),
                  _paymentChip('Card', Icons.credit_card_rounded, 3,
                      selectedPaymentMethod),
                  const SizedBox(width: 6),
                  _paymentChip('Credit', Icons.account_balance_rounded, 4,
                      selectedPaymentMethod),
                ],
              ),
            ),

            // Checkout button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [posPrimary, posPrimaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: posPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isCheckingOut.value
                        ? null
                        : () => _handleCheckout(context, isCheckingOut),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isCheckingOut.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Checkout',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    ValueNotifier<bool> isCheckingOut,
  ) async {
    isCheckingOut.value = true;
    try {
      final cashierId =
          context.read<AuthController>().userProfile!.id;
      final result = await transactionProvider.checkout(
        cashierId: cashierId,
        paymentMethodId: selectedPaymentMethod.value,
      );

      if (!context.mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Transaction ${result.transactionNumber} completed!',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Checkout failed. Please try again.',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      isCheckingOut.value = false;
    }
  }

  Widget _summaryRow(String label, String value, {bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: muted ? posTextMuted.withOpacity(0.7) : posTextMuted,
            fontSize: muted ? 12 : 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: muted ? posTextMuted.withOpacity(0.7) : Colors.white,
            fontSize: muted ? 12 : 13,
            fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _paymentChip(
    String label,
    IconData icon,
    int methodId,
    ValueNotifier<int> selected,
  ) {
    final isSelected = selected.value == methodId;
    return Expanded(
      child: InkWell(
        onTap: () => selected.value = methodId,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? posPrimary.withOpacity(0.15)
                : posSurfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? posPrimary.withOpacity(0.4)
                  : Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? posPrimary : posTextMuted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSelected ? posPrimary : posTextMuted,
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart Item Tile
// ---------------------------------------------------------------------------
class _CartItemTile extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isPrint = item.categoryId == 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPrint
                ? Colors.blue.withOpacity(0.1)
                : posPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPrint ? Icons.print_rounded : Icons.shopping_bag_outlined,
            color: isPrint ? Colors.blue.shade300 : posPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),

        // Name + unit price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'P${item.unitPrice.toStringAsFixed(2)}${isPrint ? '/page' : ''}',
                style: GoogleFonts.outfit(color: posTextMuted, fontSize: 11),
              ),
            ],
          ),
        ),

        // Quantity controls
        Container(
          decoration: BoxDecoration(
            color: posSurfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(Icons.remove, onDecrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.quantity.toStringAsFixed(0),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _qtyButton(Icons.add, onIncrease),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Subtotal
        SizedBox(
          width: 65,
          child: Text(
            'P${item.subtotal.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: posAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),

        // Remove button
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: posTextMuted.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: posTextMuted),
      ),
    );
  }
}
