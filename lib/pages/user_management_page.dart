import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementPage extends HookWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;
    final refreshKey = useState(0);

    final profilesFuture = useMemoized(
      () async {
        final query = await supabase
            .from('profiles')
            .select('*, user_roles(*)')
            .order('created_at', ascending: true);
        return query as List<dynamic>;
      },
      [refreshKey.value],
    );
    final snapshot = useFuture(profilesFuture);

    void refresh() => refreshKey.value++;

    // Parse profiles and roles
    final List<_UserData> users = [];
    if (snapshot.hasData) {
      for (final data in snapshot.data!) {
        final map = data as Map<String, dynamic>;
        final profile = Profile.fromJson(map);
        UserRole? role;
        if (map['user_roles'] != null) {
          role = UserRole.fromJson(map['user_roles'] as Map<String, dynamic>);
        }
        users.add(_UserData(profile: profile, role: role));
      }
    }

    final owners = users.where((u) => u.role?.roleName == 'owner').toList();
    final cashiers = users.where((u) => u.role?.roleName != 'owner').toList();

    return AppPage(
      body: Skeletonizer(
        enabled: !snapshot.hasData && !snapshot.hasError,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Management',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage user accounts and permissions',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: posTextMuted,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddUserDialog(context, refresh),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add User', style: GoogleFonts.outfit()),
                    style: FilledButton.styleFrom(
                      backgroundColor: posPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 700 ? 3 : 1;
                  return GridView.count(
                    crossAxisCount: crossCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _SummaryCard(
                        label: 'Total Users',
                        count: users.length,
                        subtitle: 'Active accounts',
                        icon: Icons.people_outlined,
                        iconColor: posTextMuted,
                      ),
                      _SummaryCard(
                        label: 'Owners',
                        count: owners.length,
                        subtitle: 'Full access',
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF60A5FA),
                      ),
                      _SummaryCard(
                        label: 'Cashiers',
                        count: cashiers.length,
                        subtitle: 'Limited access',
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFF4ADE80),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Owner Accounts
              _UserGroupPanel(
                title: 'Owner Accounts',
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF60A5FA),
                users: owners,
                currentUserId: currentUserId,
                onRefresh: refresh,
              ),
              const SizedBox(height: 16),

              // Cashier Accounts
              _UserGroupPanel(
                title: 'Cashier Accounts',
                icon: Icons.person_outline,
                iconColor: const Color(0xFF4ADE80),
                users: cashiers,
                currentUserId: currentUserId,
                onRefresh: refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserData {
  final Profile profile;
  final UserRole? role;
  const _UserData({required this.profile, this.role});
}

// ---------- Summary card ----------

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: posTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 11, color: posTextMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}

// ---------- User group panel ----------

class _UserGroupPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_UserData> users;
  final String? currentUserId;
  final VoidCallback onRefresh;

  const _UserGroupPanel({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.users,
    required this.currentUserId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No users in this group.',
                style: GoogleFonts.outfit(color: posTextMuted, fontSize: 13),
              ),
            )
          else
            ...users.map((u) {
              final roleName = u.role?.roleName ?? 'N/A';
              final isOwner = roleName == 'owner';
              final isCurrentUser = u.profile.userId == currentUserId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Avatar
                    u.profile.profilePicture != null && u.profile.profilePicture!.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(u.profile.profilePicture!),
                            backgroundColor: iconColor.withValues(alpha: 0.12),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                u.profile.name.isNotEmpty
                                    ? u.profile.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: iconColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(width: 12),
                    // Name + username
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                u.profile.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '(You)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: posPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '@${u.profile.username}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: posTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOwner
                            ? const Color(0xFF60A5FA).withValues(alpha: 0.12)
                            : const Color(0xFF4ADE80).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleName[0].toUpperCase() + roleName.substring(1),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOwner
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: posAccent),
                      onPressed: () => _showEditUserDialog(
                        context,
                        u.profile,
                        u.role,
                        onRefresh,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

Future<void> _showAddUserDialog(
  BuildContext context,
  VoidCallback onRefresh,
) async {
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  int selectedRoleId = 2; // default to cashier
  bool obscurePassword = true;
  bool isCreating = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: posSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add User',
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: posTextMuted,
                        ),
                        onPressed: () {
                          setDialogState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                    ),
                  ),
                ),
                _userField('Full Name', nameController),
                _userField('Username', usernameController),
                _userField('Phone (optional)', phoneController,
                    keyboardType: TextInputType.phone),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Role',
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
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Owner')),
                      DropdownMenuItem(value: 2, child: Text('Cashier')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedRoleId = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
          ),
          FilledButton(
            onPressed: isCreating
                ? null
                : () async {
                    if (passwordController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        usernameController.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Password, name, and username are required'),
                        ),
                      );
                      return;
                    }

                    setDialogState(() => isCreating = true);

                    // Generate an internal email from username to avoid Supabase
                    // email deliverability validation on non-real domains.
                    // Users log in with their username, not email.
                    final username = usernameController.text.trim();
                    final generatedEmail = '$username@printsari.internal';

                    final supabase = Supabase.instance.client;
                    try {
                      // Sign up the new user via Supabase Auth
                      final authResponse = await supabase.auth.signUp(
                        email: generatedEmail,
                        password: passwordController.text,
                      );

                      final newUserId = authResponse.user?.id;
                      if (newUserId == null) {
                        throw Exception('Failed to create auth user');
                      }

                      // Create the profile
                      await supabase.from('profiles').insert({
                        'user_id': newUserId,
                        'username': username,
                        'role_id': selectedRoleId,
                        'name': nameController.text,
                        'phone': phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                      });

                      if (ctx.mounted) Navigator.pop(ctx);
                      onRefresh();
                    } catch (e) {
                      debugPrint('Error creating user: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isCreating = false);
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
            child: isCreating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Create User', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showEditUserDialog(
  BuildContext context,
  Profile profile,
  UserRole? role,
  VoidCallback onRefresh,
) async {
  final nameController = TextEditingController(text: profile.name);
  final phoneController = TextEditingController(text: profile.phone ?? '');
  int selectedRoleId = profile.roleId;
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
          'Edit User',
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
                          radius: 36,
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
                                    fontSize: 28,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: posPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: posSurface, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _userField('Name', nameController),
                _userField('Phone', phoneController,
                    keyboardType: TextInputType.phone),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    dropdownColor: posSurfaceLight,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Role',
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
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Owner')),
                      DropdownMenuItem(value: 2, child: Text('Cashier')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedRoleId = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.outfit(color: posTextMuted)),
          ),
          FilledButton(
            onPressed: isSaving
                ? null
                : () async {
                    setDialogState(() => isSaving = true);
                    final supabase = Supabase.instance.client;
                    try {
                      String? pictureUrl = currentPictureUrl;

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
                        'phone': phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        'role_id': selectedRoleId,
                        'profile_picture': pictureUrl,
                      }).eq('id', profile.id);

                      // If editing the current user, refresh the sidebar profile
                      if (ctx.mounted) {
                        final currentUserId = supabase.auth.currentUser?.id;
                        if (profile.userId == currentUserId) {
                          await ctx.read<AuthController>().restoreSession();
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                      onRefresh();
                    } catch (e) {
                      debugPrint('Error: $e');
                      if (ctx.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
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
                : Text('Update', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    ),
  );
}

Widget _userField(
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
