import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printsari_sia/ui/ui.dart';

class AppScaffold extends HookWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: Sidebar()),
          Expanded(child: child),
        ],
      ),
    );
  }
}
