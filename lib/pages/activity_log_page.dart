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

  static const _categories = [
    'all',
    'transaction',
    'product',
    'inventory',
    'user',
    'expense',
  ];

  @override
  Widget build(BuildContext context) {
    final activityLogProvider = context.read<ActivityLogProvider>();
    final searchController = useTextEditingController();
    final searchText = useState('');
    final selectedCategory = useState('all');

    final logsFuture = useMemoized(
      () => activityLogProvider.getLogs(limit: 100),
      [],
    );
    final snapshot = useFuture(logsFuture);

    final isLoading = snapshot.connectionState == ConnectionState.waiting;

    List<ActivityLog> logs = snapshot.data ?? [];

    // Apply search filter
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      logs = logs
          .where((l) => l.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    if (selectedCategory.value != 'all') {
      logs = logs
          .where((l) => l.action?.category == selectedCategory.value)
          .toList();
    }

    useEffect(() {
      void listener() {
        searchText.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return AppPage(
      body: Skeletonizer(
        enabled: isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    'Track all actions performed in the system',
                    style:
                        GoogleFonts.outfit(fontSize: 14, color: posTextMuted),
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: posSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: TextField(
                      controller: searchController,
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search activity logs...',
                        hintStyle: GoogleFonts.outfit(
                            color: posTextMuted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: posTextMuted, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = selectedCategory.value == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              cat[0].toUpperCase() + cat.substring(1),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.white : posTextMuted,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) =>
                                selectedCategory.value = cat,
                            backgroundColor: posSurface,
                            selectedColor: posPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? posPrimary
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Log list
            Expanded(
              child: snapshot.hasError
                  ? Center(
                      child: Text(
                        'Failed to load activity logs.',
                        style:
                            GoogleFonts.outfit(color: Colors.redAccent),
                      ),
                    )
                  : logs.isEmpty && !isLoading
                      ? Center(
                          child: Text(
                            'No activity logs found.',
                            style:
                                GoogleFonts.outfit(color: posTextMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          itemCount: isLoading ? 8 : logs.length,
                          itemBuilder: (context, index) {
                            if (isLoading) {
                              return _LogEntryPlaceholder();
                            }
                            final log = logs[index];
                            return _LogEntry(log: log);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Log entry ----------

class _LogEntry extends StatelessWidget {
  final ActivityLog log;
  const _LogEntry({required this.log});

  @override
  Widget build(BuildContext context) {
    final category = log.action?.category ?? '';
    final icon = _categoryIcon(category);
    final iconColor = _categoryColor(category);
    final timeStr = DateFormat('MMM d, yyyy - h:mm a').format(log.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.action?.actionName ?? 'Action',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _CategoryBadge(category: category),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.description,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: posTextMuted,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13, color: posTextMuted.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: posTextMuted),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: posTextMuted.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      log.performedBy,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: posAccent,
                        fontWeight: FontWeight.w500,
                      ),
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'transaction':
        return Icons.receipt_long_rounded;
      case 'product':
        return Icons.inventory_2_rounded;
      case 'inventory':
        return Icons.all_inbox_rounded;
      case 'user':
        return Icons.person_rounded;
      case 'expense':
        return Icons.attach_money_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'transaction':
        return const Color(0xFF60A5FA);
      case 'product':
        return const Color(0xFF4ADE80);
      case 'inventory':
        return posAccent;
      case 'user':
        return const Color(0xFFA78BFA);
      case 'expense':
        return posPrimary;
      default:
        return posTextMuted;
    }
  }
}

// ---------- Category badge ----------

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor(category);
    final label = category.isEmpty ? 'other' : category;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _badgeColor(String category) {
    switch (category) {
      case 'transaction':
        return const Color(0xFF60A5FA);
      case 'product':
        return const Color(0xFF4ADE80);
      case 'inventory':
        return posAccent;
      case 'user':
        return const Color(0xFFA78BFA);
      case 'expense':
        return posPrimary;
      default:
        return posTextMuted;
    }
  }
}

// ---------- Skeleton placeholder ----------

class _LogEntryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: posSurfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: posSurfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: posSurfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: posSurfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
