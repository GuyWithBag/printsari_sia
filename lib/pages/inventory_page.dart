import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printsari_sia/widgets/circular_tab.dart';
import 'package:printsari_sia/widgets/circular_tab_bar.dart';
import 'package:printsari_sia/widgets/inventory_card.dart';
import 'package:printsari_sia/widgets/app_page.dart';

class InventoryPage extends HookWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabController = useTabController(initialLength: 2);
    final currentIndex = useState(0);

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
      body: Column(
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
                icon: Icons.inventory_2_outlined,
                indexState: currentIndex,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // Center(child: Text('TSADD')),
                // Center(child: Text('TSADD')),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    InventoryCard(
                      title: 'Coca Cola 1L',
                      subtitle: 'Soft drink',
                      stockLevel: '50 units',
                      price: '₱45.00',
                      onEdit: () {},
                    ),
                    InventoryCard(
                      title: 'Lucky Me Instant Noodles',
                      subtitle: 'Pancit Canton',
                      stockLevel: '100 units',
                      price: '₱15.00',
                      onEdit: () {},
                    ),
                    InventoryCard(
                      title: 'White Bread',
                      subtitle: 'Tasty loaf',
                      stockLevel: '20 units',
                      price: '₱50.00',
                      expiry: '10/20/2025',
                      onEdit: () {},
                    ),
                  ],
                ),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    InventoryCard(
                      title: 'Coca Cola 1L',
                      subtitle: 'Soft drink',
                      stockLevel: '50 units',
                      price: '₱45.00',
                      onEdit: () {},
                    ),
                    InventoryCard(
                      title: 'Lucky Me Instant Noodles',
                      subtitle: 'Pancit Canton',
                      stockLevel: '100 units',
                      price: '₱15.00',
                      onEdit: () {},
                    ),
                    InventoryCard(
                      title: 'White Bread',
                      subtitle: 'Tasty loaf',
                      stockLevel: '20 units',
                      price: '₱50.00',
                      expiry: '10/20/2025',
                      onEdit: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual tab items that adapt styling based on their active state

/// The reusable inventory card widget
