import 'package:printsari_sia/shared/types/types.dart';

class SiteMapItem {
  final String title;
  final String iconPath;
  final String path;
  final List<UserRoleType> roles;

  const SiteMapItem({
    required this.title,
    required this.iconPath,
    required this.path,
    required this.roles,
  });
}
