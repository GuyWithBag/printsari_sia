import 'package:flutter/material.dart';
import 'package:printsari_sia/routes.dart';
import 'package:printsari_sia/shared/themes/light_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PrintSari',
      theme: lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: routes,
      debugShowCheckedModeBanner: false,
      // routeInformationParser: routes.routeInformationParser,
      // routeInformationProvider: routes.routeInformationProvider,
      // routerDelegate: routes.routerDelegate,
    );
  }
}
