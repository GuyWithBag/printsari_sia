import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/types/types.dart';

class AuthController extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  Session? session;
  User? user;
  Profile? userProfile;
  UserRoleType? userRoleType;

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
    userProfile = Profile.fromJson(result);
    userRoleType = await userProfile!.getRoleType(userProfile!);
    notifyListeners();
    log(result.toString());
    log(userProfile.toString());
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
  bool isRole(UserRoleType role) {
    if (isAuthenticated == false) return false;
    return userRoleType == role;
  }

  bool hasRoles(List<UserRoleType> roles) {
    if (isAuthenticated == false) return false;

    return roles.contains(userRoleType);
  }

  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    required String password,
    required Profile profile,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      phone: phone,
      password: password,
    );
    profile.userId = user!.id;
    supabase.from('profiles').upsert(profile);
    return res;
  }
}
