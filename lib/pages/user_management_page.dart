import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printsari_sia/shared/themes/colors.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:printsari_sia/widgets/app_page.dart';
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

    return AppPage(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'User Management',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'View and manage user profiles and roles',
                style: GoogleFonts.outfit(color: posTextMuted),
              ),
            ),
          ),
        ),
      ),
      body: Skeletonizer(
        enabled: !snapshot.hasData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showAddUserDialog(context, refresh),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text('Add User', style: GoogleFonts.outfit()),
                  style: FilledButton.styleFrom(
                    backgroundColor: posPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: snapshot.hasData
                    ? _UserTable(
                        profilesData: snapshot.data!,
                        currentUserId: currentUserId,
                        onRefresh: refresh,
                      )
                    : snapshot.hasError
                        ? Center(
                            child: Text(
                              'Error loading users: ${snapshot.error}',
                              style: GoogleFonts.outfit(color: posTextMuted),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(color: posPrimary),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTable extends StatelessWidget {
  final List<dynamic> profilesData;
  final String? currentUserId;
  final VoidCallback onRefresh;

  const _UserTable({
    required this.profilesData,
    required this.currentUserId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (profilesData.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: GoogleFonts.outfit(color: posTextMuted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: posSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(posSurfaceLight),
              dataRowColor: WidgetStateProperty.all(posSurface),
              headingTextStyle: GoogleFonts.outfit(
                color: posTextMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              dataTextStyle: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
              ),
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Username')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Actions')),
              ],
              rows: profilesData.map((data) {
                final map = data as Map<String, dynamic>;
                final profile = Profile.fromJson(map);
                UserRole? role;
                if (map['user_roles'] != null) {
                  role = UserRole.fromJson(
                    map['user_roles'] as Map<String, dynamic>,
                  );
                }
                final isCurrentUser = profile.userId == currentUserId;

                return DataRow(cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(profile.name),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: posPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'You',
                              style: GoogleFonts.outfit(
                                color: posPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  DataCell(Text(profile.username)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: role?.roleName == 'owner'
                            ? posPrimary.withValues(alpha: 0.15)
                            : const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role?.roleName ?? 'N/A',
                        style: GoogleFonts.outfit(
                          color: role?.roleName == 'owner'
                              ? posPrimary
                              : const Color(0xFF3B82F6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(profile.phone ?? '-')),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: posAccent,
                      ),
                      onPressed: () => _showEditUserDialog(
                        context,
                        profile,
                        role,
                        onRefresh,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showAddUserDialog(
  BuildContext context,
  VoidCallback onRefresh,
) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  int selectedRoleId = 2; // default to cashier

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
                _userField('Email', emailController,
                    keyboardType: TextInputType.emailAddress),
                _userField('Password', passwordController),
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
            onPressed: () async {
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty ||
                  nameController.text.isEmpty ||
                  usernameController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Email, password, name, and username are required'),
                  ),
                );
                return;
              }

              final supabase = Supabase.instance.client;
              try {
                // Sign up the new user via Supabase Auth
                final authResponse = await supabase.auth.admin.createUser(
                  AdminUserAttributes(
                    email: emailController.text,
                    password: passwordController.text,
                    emailConfirm: true,
                  ),
                );

                final newUserId = authResponse.user?.id;
                if (newUserId == null) {
                  throw Exception('Failed to create auth user');
                }

                // Create the profile
                await supabase.from('profiles').insert({
                  'user_id': newUserId,
                  'username': usernameController.text,
                  'role_id': selectedRoleId,
                  'name': nameController.text,
                  'phone': phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                });

                if (ctx.mounted) Navigator.pop(ctx);
                onRefresh();
              } catch (e) {
                debugPrint('Error: $e');
                if (ctx.mounted) {
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
            child: Text('Create User', style: GoogleFonts.outfit()),
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
            onPressed: () async {
              final supabase = Supabase.instance.client;
              try {
                await supabase.from('profiles').update({
                  'name': nameController.text,
                  'phone': phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  'role_id': selectedRoleId,
                }).eq('id', profile.id);
                if (ctx.mounted) Navigator.pop(ctx);
                onRefresh();
              } catch (e) {
                debugPrint('Error: $e');
                if (ctx.mounted) {
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
            child: Text('Update', style: GoogleFonts.outfit()),
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
