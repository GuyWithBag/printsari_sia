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

  Future<bool> restoreSession() async {
    final currentSession = supabase.auth.currentSession;
    final currentUser = supabase.auth.currentUser;
    if (currentSession != null && currentUser != null) {
      session = currentSession;
      user = currentUser;
      try {
        final query = await supabase
            .from('profiles')
            .select()
            .eq('user_id', currentUser.id)
            .single();
        userProfile = Profile.fromJson(query);
        userRoleType = await userProfile!.getRoleType(userProfile!);
        notifyListeners();
        return true;
      } catch (e) {
        log('Failed to restore profile: $e');
        session = null;
        user = null;
        userProfile = null;
        userRoleType = null;
      }
    }
    return false;
  }

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
}
