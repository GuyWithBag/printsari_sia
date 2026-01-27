import 'package:flutter/material.dart';
import 'package:printsari_sia/ui/app_page.dart';

// '/'

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AppPage(
      // alignment: Alignment.topCenter,
      // padding: const EdgeInsets.all(20),
      // isChildSliver: false,
      child: Text(
        "UserManagement Page",
        style: TextTheme.of(context).bodyLarge,
      ),
    );
  }
}
