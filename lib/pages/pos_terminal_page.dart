import 'package:flutter/material.dart';
import 'package:printsari_sia/widgets/app_page.dart';

// '/'

class POSTerminalPage extends StatelessWidget {
  const POSTerminalPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AppPage(
      // alignment: Alignment.topCenter,
      // padding: const EdgeInsets.all(20),
      // isChildSliver: false,
      child: Text("POSTerminal Page", style: TextTheme.of(context).bodyLarge),
    );
  }
}
