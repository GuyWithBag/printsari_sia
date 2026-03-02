import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CircularTab extends HookWidget {
  final String label;
  final IconData icon;
  final TabController tabController;
  final int index;
  final Function(void)? onTap;
  final ValueNotifier<int> indexState;
  const CircularTab({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    required this.tabController,
    required this.index,
    required this.indexState,
  });

  bool isActive() {
    return tabController.index == index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        tabController.animateTo(index);
        indexState.value = index;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive() ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive()
              ? [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive()
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isActive() ? FontWeight.w600 : FontWeight.normal,
                color: isActive()
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
