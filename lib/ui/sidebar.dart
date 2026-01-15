import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/data/sitemap_items.dart';
import 'package:printsari_sia/shared/types/sitemap_item.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Sari-Sari & Printing"), Text("POS System")],
          ),
        ),
        for (var i in siteMapItems)
          TextButton.icon(
            icon: Icon(Icons.label),
            label: Text(i.title),
            onPressed: () {},
          ),
        Spacer(),
        ElevatedButton.icon(
          onPressed: () {},
          label: Text("Logout"),
          icon: Icon(Icons.logout),
        ),
      ],
    );
  }
}
