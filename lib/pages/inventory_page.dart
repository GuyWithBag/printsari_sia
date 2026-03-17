import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    _InventoryGrid(items: storeItems),
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
  const _InventoryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No store inventory items',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: items
            .map((item) => InventoryCard(onEdit: () {}, item: item))
            .toList(),
      ),
    );
  }
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
