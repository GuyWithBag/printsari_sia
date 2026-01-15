import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/themes/main_theme.dart';
import 'package:printsari_sia/ui/ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrintSari',
      theme: mainTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: AppScaffold(child: Container(color: Colors.grey[200])),
    );
  }
}
