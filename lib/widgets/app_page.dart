import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Is the main page wrapper for all pages in the app.
class AppPage extends HookWidget {
  final Widget? child;

  const AppPage({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: child ?? const SizedBox(),
    );
  }
}
