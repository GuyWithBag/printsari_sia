import 'package:flutter/material.dart';
import 'package:printsari_sia/router.dart';
import 'package:printsari_sia/shared/themes/main_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PrintSari',
      theme: mainTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
