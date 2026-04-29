import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printsari_sia/providers/inventory_provider.dart';
import 'package:printsari_sia/providers/product_provider.dart';
import 'package:printsari_sia/providers/transaction_provider.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/widgets/cart_panel.dart';
import 'package:printsari_sia/widgets/product_grid_panel.dart';
import 'package:provider/provider.dart';

class POSTerminalPage extends HookWidget {
  const POSTerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final tabIndex = useState(0); // 0 = Store, 1 = Printing
    final selectedPaymentMethod = useState(1);

    final productProvider = context.read<ProductProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    // Re-fetch inventory after each completed checkout so stock levels update.
    final completedTxCount = transactionProvider.completedTransactionCount;

    final productsFuture = useMemoized(() => productProvider.getProducts(), [
      productProvider,
    ]);
    final serviceSuppliesFuture = useMemoized(
      () => productProvider.getServiceSupplies(),
      [productProvider],
    );
    final inventoryFuture = useMemoized(
      () {
        inventoryProvider.clearCache();
        return inventoryProvider.getItems();
      },
      [completedTxCount],
    );

    final productsSnapshot = useFuture(productsFuture);
    final serviceSuppliesSnapshot = useFuture(serviceSuppliesFuture);
    final inventorySnapshot = useFuture(inventoryFuture);

    return Container(
      color: posBg,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Center Column: Product Grid (~60-65%) ──
          Expanded(
            flex: 6,
            child: ProductGridPanel(
              searchController: searchController,
              searchQuery: searchQuery,
              tabIndex: tabIndex,
              productsSnapshot: productsSnapshot,
              serviceSuppliesSnapshot: serviceSuppliesSnapshot,
              inventorySnapshot: inventorySnapshot,
              transactionProvider: transactionProvider,
            ),
          ),
          const SizedBox(width: 12),
          // ── Right Column: Cart (~35-40%) ──
          Expanded(
            flex: 4,
            child: CartPanel(
              transactionProvider: transactionProvider,
              selectedPaymentMethod: selectedPaymentMethod,
              inventory: inventorySnapshot.data ?? [],
            ),
          ),
        ],
      ),
    );
  }
}
