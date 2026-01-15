import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/data/sitemap_items.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sari-Sari & Printing"),
              Text("POS System", style: TextTheme.of(context).bodySmall),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i in siteMapItems)
                TextButton.icon(
                  icon: Icon(i.icon),
                  label: Text(i.title),
                  onPressed: () {},
                ),
            ],
          ),
        ),
        Spacer(),
        Divider(),
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("John Doe"),
                    Text("Owner", style: TextTheme.of(context).bodySmall),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                label: Text("Logout"),
                icon: Icon(Icons.logout),
              ),
            ],
          ),
        ),
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton.icon(
        //     onPressed: () {},
        //     label: Text("Logout"),
        //     icon: Icon(Icons.logout),
        //   ),
        // ),
      ],
    );
  }
}
