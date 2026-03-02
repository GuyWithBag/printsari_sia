import 'package:flutter/material.dart';
import 'package:printsari_sia/widgets/app_page.dart';

// '/'

class BusinessExpensesPage extends StatelessWidget {
  const BusinessExpensesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AppPage(
      // alignment: Alignment.topCenter,
      // padding: const EdgeInsets.all(20),
      // isChildSliver: false,
      body: Text(
        "BusinessExpenses Page",
        style: TextTheme.of(context).bodyLarge,
      ),
    );
  }
}
