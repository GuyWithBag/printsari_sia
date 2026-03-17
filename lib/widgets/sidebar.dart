import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/shared/data/sitemap_items.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:svg_pic_editor/svg_pic_editor.dart';

import '../shared/types/types.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final currentPath = GoRouterState.of(context).uri.toString();

    List<Widget> buildSitemapItems(List<SiteMapItem> items) {
      final widgets = <Widget>[];
      for (var item in items.where((i) => auth.hasRoles(i.roles))) {
        final isActive = currentPath == item.path ||
            (item.path != '/' && currentPath.startsWith(item.path));

        widgets.add(
          InkWell(
            onTap: () => context.go(item.path),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          posPrimary.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      )
                    : null,
                border: isActive
                    ? Border(
                        left: BorderSide(color: posPrimary, width: 3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  SvgPicEditor.asset(
                    item.iconPath,
                    height: 16,
                    width: 16,
                    modifications: [
                      ElementEdit(
                        querySelector: 'lucide',
                        strokeWidth: 1.75,
                        strokeColor:
                            isActive ? posPrimary : posTextMuted,
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isActive ? Colors.white : posTextMuted,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return widgets;
    }

    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: posPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: posPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.print_outlined,
                        size: 18,
                        color: posTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sari-Sari & Printing',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'POS System',
                  style: TextStyle(color: posTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: buildSitemapItems(siteMapItems),
              ),
            ),
          ),

          // User profile + sign out
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: posSurfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: posPrimary.withValues(alpha: 0.2),
                        child: Text(
                          auth.userProfile?.name.isNotEmpty == true
                              ? auth.userProfile!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: posPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.userProfile?.name ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Owner',
                              style: TextStyle(
                                color: posTextMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthController>().signOut(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully.')),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Sign Out'),
                  style: TextButton.styleFrom(
                    foregroundColor: posTextMuted,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
