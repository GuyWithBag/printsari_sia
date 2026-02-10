import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/types/types.dart';

class AuthController extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  Session? session;
  User? user;
  Profile? userProfile;

  Future<void> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    session = response.session;
    user = response.user;
    final query = await supabase
        .from('profiles')
        .select()
        .eq('user_id', user!.id)
        .single();
    final result = query;
    userProfile = Profile(
      username: result['username'],
      role: result['role'],
      id: result['id'],
      userId: result['user_id'],
      name: result['name'],
      roleId: result['role_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
    );
    notifyListeners();
  }

  void signOut(BuildContext context) async {
    GoRouter router = GoRouter.of(context);
    await supabase.auth.signOut();
    session = null;
    user = null;
    userProfile = null;
    router.go('/login');
    notifyListeners();
  }

  bool get isAuthenticated => user != null;
  bool isRole(UserRole role) {
    if (isAuthenticated == false) return false;
    return userProfile!.role == role;
  }

  bool hasRoles(List<UserRole> roles) {
    if (isAuthenticated == false) return false;

    return roles.contains(userProfile!.role);
  }
}
