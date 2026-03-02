import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Is the main page wrapper for all pages in the app.
class AppPage extends HookWidget {
  final Widget? body;
  final AppBar? appBar;

  const AppPage({super.key, this.body, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar, body: body ?? const SizedBox());
  }
}
