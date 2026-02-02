import 'package:printsari_sia/shared/types/role.dart';

class SiteMapItem {
  final String title;
  final String iconPath;
  final String path;
  final List<Role> roles;

  const SiteMapItem({
    required this.title,
    required this.iconPath,
    required this.path,
    required this.roles,
  });
}
