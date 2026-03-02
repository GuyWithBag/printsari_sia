import 'package:flutter/material.dart';
import 'package:printsari_sia/widgets/app_page.dart';

// '/'

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppPage(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: [
                Text(
                  '• ',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Dashboard / Card / Status',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Store Inventory Status card
            _StatusCard(
              title: 'Store Inventory Status',
              items: [
                _StatusItem(
                  title: 'Coca Cola 1L',
                  subtitle: 'Soft drink',
                  quantity: '50 units',
                  price: '₱45',
                ),
                _StatusItem(
                  title: 'Lucky Me Instant Noodles',
                  subtitle: 'Pancit Canton',
                  quantity: '100 units',
                  price: '₱15',
                ),
                _StatusItem(
                  title: 'White Bread',
                  subtitle: 'Tasty loaf',
                  quantity: '20 units',
                  price: '₱50',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Printing Supplies Status card
            _StatusCard(
              title: 'Printing Supplies Status',
              items: [
                _StatusItem(
                  title: 'B&W Printing (Short Bond)',
                  subtitle: 'Black and white',
                  quantity: '500 units',
                  price: '₱3',
                ),
                _StatusItem(
                  title: 'Colored Printing (Short Bond)',
                  subtitle: 'Full color',
                  quantity: '500 units',
                  price: '₱10',
                ),
                _StatusItem(
                  title: 'B&W Printing (Long Bond)',
                  subtitle: 'Black and white',
                  quantity: '300 units',
                  price: '₱5',
                ),
                _StatusItem(
                  title: 'Lamination (Short)',
                  subtitle: 'Short bond lamination',
                  quantity: '100 units',
                  price: '₱15',
                ),
                _StatusItem(
                  title: 'Lamination (Long)',
                  subtitle: 'Long bond lamination',
                  quantity: '100 units',
                  price: '₱25',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem {
  final String title, subtitle, quantity, price;
  const _StatusItem({
    required this.title,
    required this.subtitle,
    required this.quantity,
    required this.price,
  });
}

class _StatusCard extends StatelessWidget {
  final String title;
  final List<_StatusItem> items;
  const _StatusCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 16),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  _StatusRow(
                    title: item.title,
                    subtitle: item.subtitle,
                    quantity: item.quantity,
                    price: item.price,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String title, subtitle, quantity, price;
  const _StatusRow({
    required this.title,
    required this.subtitle,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                quantity,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                ),
              ),
              Text(
                price,
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
