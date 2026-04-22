import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:printsari_sia/providers/activity_log_provider.dart';

// '/activity-log'

class ActivityLogPage extends HookWidget {
  const ActivityLogPage({super.key});

  static const _actionFilters = [
    'All Actions',
    'Transactions',
    'Inventory Restock',
    'Inventory Adjustment',
    'Inventory Deduction',
    'Product Added',
    'Product Edited',
    'Product Deleted',
    'User Added',
    'User Edited',
    'User Deleted',
    'Expense Added',
    'Expense Edited',
    'Expense Deleted',
    'Login',
    'Logout',
  ];

  static const _timeFilters = [
    'All Time',
    'Today',
    'Last 7 Days',
    'Last 30 Days',
  ];

  @override
  Widget build(BuildContext context) {
    final activityLogProvider = context.read<ActivityLogProvider>();
    final searchController = useTextEditingController();
    final searchText = useState('');
    final selectedAction = useState('All Actions');
    final selectedTime = useState('All Time');

    final logsFuture = useMemoized(
      () => activityLogProvider.getLogs(limit: 200),
      [],
    );
    final snapshot = useFuture(logsFuture);

    final isLoading = snapshot.connectionState == ConnectionState.waiting;

    List<ActivityLog> logs = snapshot.data ?? [];

    // Apply search filter
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      logs = logs
          .where((l) =>
              l.description.toLowerCase().contains(query) ||
              (l.action?.actionName.toLowerCase().contains(query) ?? false) ||
              l.performedBy.toLowerCase().contains(query))
          .toList();
    }

    // Apply action filter (category-based + partial name match)
    if (selectedAction.value != 'All Actions') {
      logs = logs.where((l) => _matchesActionFilter(l, selectedAction.value)).toList();
    }

    // Apply time filter
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    if (selectedTime.value == 'Today') {
      logs = logs.where((l) => l.timestamp.isAfter(startOfToday)).toList();
    } else if (selectedTime.value == 'Last 7 Days') {
      final cutoff = startOfToday.subtract(const Duration(days: 7));
      logs = logs.where((l) => l.timestamp.isAfter(cutoff)).toList();
    } else if (selectedTime.value == 'Last 30 Days') {
      final cutoff = startOfToday.subtract(const Duration(days: 30));
      logs = logs.where((l) => l.timestamp.isAfter(cutoff)).toList();
    }

    // Compute summary counts
    final allLogs = snapshot.data ?? [];
    final transactionCount =
        allLogs.where((l) => l.action?.category == 'transaction').length;
    final inventoryCount =
        allLogs.where((l) => l.action?.category == 'inventory').length;
    final systemCount = allLogs
        .where((l) =>
            l.action?.category == 'user' || l.action?.category == 'expense')
        .length;

    return AppPage(
      body: Skeletonizer(
        enabled: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Activity Log',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete audit trail of all system activities',
                style: GoogleFonts.outfit(fontSize: 14, color: posTextMuted),
              ),
              const SizedBox(height: 24),

              // Summary cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 800 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _SummaryCard(
                        label: 'Total Activities',
                        count: allLogs.length,
                        icon: Icons.settings_rounded,
                        iconColor: posTextMuted,
                      ),
                      _SummaryCard(
                        label: 'Transactions',
                        count: transactionCount,
                        icon: Icons.shopping_cart_rounded,
                        iconColor: const Color(0xFF4ADE80),
                      ),
                      _SummaryCard(
                        label: 'Inventory Changes',
                        count: inventoryCount,
                        icon: Icons.inventory_2_rounded,
                        iconColor: const Color(0xFFA78BFA),
                      ),
                      _SummaryCard(
                        label: 'System Actions',
                        count: systemCount,
                        icon: Icons.people_rounded,
                        iconColor: posPrimary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Filters row
              _FiltersPanel(
                searchController: searchController,
                onSearchChanged: (val) => searchText.value = val,
                selectedAction: selectedAction.value,
                onActionChanged: (val) =>
                    selectedAction.value = val ?? 'All Actions',
                actionFilters: _actionFilters,
                selectedTime: selectedTime.value,
                onTimeChanged: (val) =>
                    selectedTime.value = val ?? 'All Time',
                timeFilters: _timeFilters,
              ),
              const SizedBox(height: 24),

              // Activity Records table
              _ActivityTable(logs: logs),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Summary card ----------

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: posTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}

// ---------- Filters panel ----------

class _FiltersPanel extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedAction;
  final ValueChanged<String?> onActionChanged;
  final List<String> actionFilters;
  final String selectedTime;
  final ValueChanged<String?> onTimeChanged;
  final List<String> timeFilters;

  const _FiltersPanel({
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedAction,
    required this.onActionChanged,
    required this.actionFilters,
    required this.selectedTime,
    required this.onTimeChanged,
    required this.timeFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildActionDropdown()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildTimeDropdown()),
              ],
            );
          }
          return Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildActionDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeDropdown()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search activities...',
        hintStyle: GoogleFonts.outfit(color: posTextMuted, fontSize: 14),
        prefixIcon:
            const Icon(Icons.search_rounded, color: posTextMuted, size: 20),
        filled: true,
        fillColor: posSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildActionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: posSurfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedAction,
          isExpanded: true,
          dropdownColor: posSurfaceLight,
          icon: const Icon(Icons.keyboard_arrow_down, color: posTextMuted),
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          items: actionFilters
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined,
                            size: 16, color: posTextMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(f, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onActionChanged,
        ),
      ),
    );
  }

  Widget _buildTimeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: posSurfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTime,
          isExpanded: true,
          dropdownColor: posSurfaceLight,
          icon: const Icon(Icons.keyboard_arrow_down, color: posTextMuted),
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          items: timeFilters
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: posTextMuted),
                        const SizedBox(width: 8),
                        Text(f),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onTimeChanged,
        ),
      ),
    );
  }
}

// ---------- Activity table ----------

class _ActivityTable extends StatelessWidget {
  final List<ActivityLog> logs;
  const _ActivityTable({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.settings_rounded,
                    color: posTextMuted, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Activity Records (${logs.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(14)),
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
                dataTextStyle:
                    GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                columns: const [
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Performed By')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: logs.map((log) {
                  final dateStr =
                      DateFormat('M/d/yyyy').format(log.timestamp);
                  final timeStr =
                      DateFormat('h:mm:ss a').format(log.timestamp);
                  final actionName = log.action?.actionName ?? 'Action';
                  final category = log.action?.category ?? '';

                  return DataRow(cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dateStr),
                          Text(
                            timeStr,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: posTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      _ActionBadge(
                        actionName: actionName,
                        category: category,
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Text(
                          log.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    DataCell(Text(log.performedBy)),
                    DataCell(
                      TextButton.icon(
                        onPressed: () => _showLogDetailDialog(context, log),
                        icon: const Icon(Icons.visibility_outlined,
                            size: 16, color: posTextMuted),
                        label: Text(
                          'View',
                          style: GoogleFonts.outfit(
                            color: posTextMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Action badge ----------

class _ActionBadge extends StatelessWidget {
  final String actionName;
  final String category;
  const _ActionBadge({required this.actionName, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    final icon = _categoryIcon(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            actionName,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'transaction':
        return Icons.shopping_cart_rounded;
      case 'product':
        return Icons.inventory_2_rounded;
      case 'inventory':
        return Icons.all_inbox_rounded;
      case 'user':
        return Icons.person_rounded;
      case 'expense':
        return Icons.attach_money_rounded;
      default:
        return Icons.login_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'transaction':
        return const Color(0xFF4ADE80);
      case 'product':
        return const Color(0xFF60A5FA);
      case 'inventory':
        return const Color(0xFFA78BFA);
      case 'user':
        return posPrimary;
      case 'expense':
        return const Color(0xFFFBBF24);
      default:
        return posTextMuted;
    }
  }
}

// ---------- Log detail dialog ----------

void _showLogDetailDialog(BuildContext context, ActivityLog log) {
  final dateStr =
      DateFormat('M/d/yyyy, h:mm:ss a').format(log.timestamp);
  final actionName = log.action?.actionName ?? 'Action';
  final category = log.action?.category ?? '';
  final icon = _dialogCategoryIcon(category);
  final color = _dialogCategoryColor(category);

  String? metadataStr;
  if (log.metadata != null && log.metadata!.isNotEmpty) {
    const encoder = JsonEncoder.withIndent('  ');
    metadataStr = encoder.convert(log.metadata);
  }

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: posSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Text(
            'Activity Details',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: posTextMuted, size: 20),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: posSurfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Action Type',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: posTextMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(icon, size: 16, color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    actionName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Timestamp',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: posTextMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Performed By',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: posTextMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.performedBy,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log ID',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: posTextMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${log.id}',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Description',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: posSurfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  log.description,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),

              // Metadata
              if (metadataStr != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Additional Details',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    metadataStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7EE787),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          style: FilledButton.styleFrom(
            backgroundColor: posSurfaceLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('Close', style: GoogleFonts.outfit()),
        ),
      ],
    ),
  );
}

IconData _dialogCategoryIcon(String category) {
  switch (category) {
    case 'transaction':
      return Icons.shopping_cart_rounded;
    case 'product':
      return Icons.inventory_2_rounded;
    case 'inventory':
      return Icons.all_inbox_rounded;
    case 'user':
      return Icons.person_rounded;
    case 'expense':
      return Icons.attach_money_rounded;
    default:
      return Icons.login_rounded;
  }
}

Color _dialogCategoryColor(String category) {
  switch (category) {
    case 'transaction':
      return const Color(0xFF4ADE80);
    case 'product':
      return const Color(0xFF60A5FA);
    case 'inventory':
      return const Color(0xFFA78BFA);
    case 'user':
      return posPrimary;
    case 'expense':
      return const Color(0xFFFBBF24);
    default:
      return posTextMuted;
  }
}

bool _matchesActionFilter(ActivityLog l, String filter) {
  final cat = l.action?.category ?? '';
  final name = (l.action?.actionName ?? '').toLowerCase();
  switch (filter) {
    case 'Transactions':
      return cat == 'transaction';
    case 'Inventory Restock':
      return cat == 'inventory' && name.contains('stock');
    case 'Inventory Adjustment':
      return cat == 'inventory' && name.contains('adjust');
    case 'Inventory Deduction':
      return cat == 'inventory' && name.contains('deduct');
    case 'Product Added':
      return cat == 'product' && name.contains('add');
    case 'Product Edited':
      return cat == 'product' && name.contains('edit');
    case 'Product Deleted':
      return cat == 'product' && name.contains('delete');
    case 'User Added':
      return cat == 'user' && name.contains('add');
    case 'User Edited':
      return cat == 'user' && name.contains('edit');
    case 'User Deleted':
      return cat == 'user' && name.contains('delete');
    case 'Expense Added':
      return cat == 'expense' && name.contains('add');
    case 'Expense Edited':
      return cat == 'expense' && name.contains('edit');
    case 'Expense Deleted':
      return cat == 'expense' && name.contains('delete');
    case 'Login':
      return name.contains('login');
    case 'Logout':
      return name.contains('logout');
    default:
      return l.action?.actionName == filter;
  }
}
