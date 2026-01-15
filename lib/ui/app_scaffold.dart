import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AppScaffold extends HookWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
