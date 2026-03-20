import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/shared/data/sitemap_items.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svg_pic_editor/svg_pic_editor.dart';

import '../shared/types/types.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final currentPath = GoRouterState.of(context).uri.toString();

    List<Widget> buildSitemapItems(List<SiteMapItem> items) {
      final widgets = <Widget>[];
      for (var item in items.where((i) => auth.hasRoles(i.roles))) {
        final isActive =
            currentPath == item.path ||
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
                    ? Border(left: BorderSide(color: posPrimary, width: 3))
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
                        strokeColor: isActive ? posPrimary : posTextMuted,
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isActive ? Colors.white : posTextMuted,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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

    final profile = auth.userProfile;
    final roleName = auth.userRoleType?.name ?? '';
    final displayRole = roleName.isNotEmpty
        ? roleName[0].toUpperCase() + roleName.substring(1)
        : '';

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
      child: Container(
        decoration: BoxDecoration(
          color: posSurface,
          border: Border(
            right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
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
                  InkWell(
                    onTap: () => _showEditProfileDialog(context, auth),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
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
                          _buildAvatar(profile, 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.name ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  profile != null
                                      ? '@${profile.username} · $displayRole'
                                      : '',
                                  style: const TextStyle(
                                    color: posTextMuted,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: posTextMuted.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.read<AuthController>().signOut(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully.'),
                        ),
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
      ),
    );
  }

  Widget _buildAvatar(Profile? profile, double radius) {
    if (profile?.profilePicture != null && profile!.profilePicture!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(profile.profilePicture!),
        backgroundColor: posPrimary.withValues(alpha: 0.2),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: posPrimary.withValues(alpha: 0.2),
      child: Text(
        profile?.name.isNotEmpty == true
            ? profile!.name[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: posPrimary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

Future<void> _showEditProfileDialog(BuildContext context, AuthController auth) async {
  final profile = auth.userProfile;
  if (profile == null) return;

  final nameController = TextEditingController(text: profile.name);
  final usernameController = TextEditingController(text: profile.username);
  final phoneController = TextEditingController(text: profile.phone ?? '');
  String? currentPictureUrl = profile.profilePicture;
  Uint8List? pickedImageBytes;
  String? pickedImageName;
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile picture
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: true,
                      );
                      if (result != null && result.files.single.bytes != null) {
                        setDialogState(() {
                          pickedImageBytes = result.files.single.bytes;
                          pickedImageName = result.files.single.name;
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: posPrimary.withValues(alpha: 0.2),
                          backgroundImage: pickedImageBytes != null
                              ? MemoryImage(pickedImageBytes!)
                              : (currentPictureUrl != null && currentPictureUrl!.isNotEmpty
                                  ? NetworkImage(currentPictureUrl!)
                                  : null) as ImageProvider?,
                          child: (pickedImageBytes == null &&
                                  (currentPictureUrl == null || currentPictureUrl!.isEmpty))
                              ? Text(
                                  profile.name.isNotEmpty
                                      ? profile.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: posPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: posPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: posSurface, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _profileField('Name', nameController),
                _profileField('Username', usernameController),
                _profileField('Phone', phoneController,
                    keyboardType: TextInputType.phone),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
          ),
          FilledButton(
            onPressed: isSaving
                ? null
                : () async {
                    setDialogState(() => isSaving = true);
                    final supabase = Supabase.instance.client;
                    try {
                      String? pictureUrl = currentPictureUrl;

                      // Upload image if picked
                      if (pickedImageBytes != null && pickedImageName != null) {
                        final ext = pickedImageName!.split('.').last;
                        final path = 'profile_pictures/${profile.id}.$ext';
                        await supabase.storage
                            .from('avatars')
                            .uploadBinary(
                              path,
                              pickedImageBytes!,
                              fileOptions: const FileOptions(upsert: true),
                            );
                        pictureUrl = supabase.storage
                            .from('avatars')
                            .getPublicUrl(path);
                      }

                      await supabase.from('profiles').update({
                        'name': nameController.text,
                        'username': usernameController.text,
                        'phone': phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        'profile_picture': pictureUrl,
                      }).eq('id', profile.id);

                      // Refresh the auth controller's profile
                      await auth.restoreSession();

                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      debugPrint('Error updating profile: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: posPrimary,
              foregroundColor: Colors.white,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Save', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Widget _profileField(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: posTextMuted),
        filled: true,
        fillColor: posSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: posPrimary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}
