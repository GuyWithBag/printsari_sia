import 'package:flutter/material.dart';
import 'package:printsari_sia/widgets/app_page.dart';

// '/'

class FinancialReportsPage extends StatelessWidget {
  const FinancialReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AppPage(
      // alignment: Alignment.topCenter,
      // padding: const EdgeInsets.all(20),
      // isChildSliver: false,
      body: Text(
        "FinancialReports Page",
        style: TextTheme.of(context).bodyLarge,
      ),
    );
  }
}
