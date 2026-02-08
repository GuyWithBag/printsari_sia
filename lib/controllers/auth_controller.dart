import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/types/types.dart';

class AuthController extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  Session? session;
  User? user;

  Future<void> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    session = response.session;
    user = response.user;
    notifyListeners();
  }

  void signOut(BuildContext context) async {
    GoRouter router = GoRouter.of(context);
    await supabase.auth.signOut();
    session = null;
    user = null;
    router.go('/login');
    notifyListeners();
  }

  bool get isAuthenticated => user != null;
  // Future<bool>? isRole(String role) async {
  //   if (isAuthenticated == false) return false;
  //   final int userId = user!.appMetadata['id'];
  //   final profile = await supabase.from('profiles').select('user_id').eq('user_id', userId);
  //   final userRole = profile.;
  //   return userRole == role;
  // }

  bool hasRoles(List<Role> roles) {
    if (isAuthenticated == false) return false;
    final userRoleString = user!.appMetadata['role'];
    final userRole = Role.values.asNameMap()[userRoleString];
    return roles.contains(userRole);
  }
}
