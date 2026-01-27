import 'package:flutter/material.dart';
import 'package:printsari_sia/ui/app_page.dart';

// '/'

class BusinessExpensesPage extends StatelessWidget {
  const BusinessExpensesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AppPage(
      // alignment: Alignment.topCenter,
      // padding: const EdgeInsets.all(20),
      // isChildSliver: false,
      child: Text("BusinessExpenses Page", style: TextTheme.of(context).bodyLarge),
    );
  }
}
