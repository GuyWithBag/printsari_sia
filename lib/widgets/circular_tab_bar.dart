import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A custom widget to hold the segmented tabs
class CircularTabBar extends HookWidget {
  final TabController tabController;
  final List<Widget> children;

  const CircularTabBar({
    Key? key,
    required this.tabController,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
