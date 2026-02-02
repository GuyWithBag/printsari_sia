import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/shared/data/sitemap_items.dart';
import 'package:provider/provider.dart';
import 'package:svg_pic_editor/svg_pic_editor.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: Divider.createBorderSide(context, width: 1)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: Divider.createBorderSide(context, width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.house_outlined, size: 30, color: Colors.blue),
                    Icon(Icons.print_outlined, size: 30, color: Colors.purple),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Sari-Sari & Printing",
                  style: TextTheme.of(context).bodyLarge,
                ),
                Text("POS System", style: TextTheme.of(context).bodySmall),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                for (var i in siteMapItems.where(
                  (item) => item == siteMapItems[1],
                ))
                  TextButton(
                    onPressed: () {},
                    style: TextButtonTheme.of(context).style!.copyWith(
                      textStyle: WidgetStatePropertyAll(
                        TextTheme.of(
                          context,
                        ).bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => {context.go(i.path)},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicEditor.asset(
                            i.iconPath,
                            height: 16,
                            width: 16,
                            modifications: [
                              ElementEdit(
                                querySelector: 'lucide',
                                strokeWidth: 2,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 17,
                          ), // Adjust this value to control spacing
                          Text(i.title),
                        ],
                      ),
                    ),
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
                      Text("John Doe", style: TextTheme.of(context).bodyMedium),
                      Text("Owner", style: TextTheme.of(context).bodySmall),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthController>().signOut(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully.')),
                    );
                  },
                  label: Text("Sign Out"),
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
      ),
    );
  }
}
