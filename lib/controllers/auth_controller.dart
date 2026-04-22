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
  int? _currentLoginHistoryId;

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

        if (!userProfile!.isActive) {
          await supabase.auth.signOut();
          session = null;
          user = null;
          userProfile = null;
          userRoleType = null;
          return false;
        }

        userRoleType = await userProfile!.getRoleType(userProfile!);

        // Record session restore as a login event if no current history exists
        if (_currentLoginHistoryId == null) {
          try {
            final loginRecord = await supabase.from('login_history').insert({
              'profile_id': userProfile!.id,
              'username': userProfile!.username,
              'login_time': DateTime.now().toIso8601String(),
            }).select().single();
            _currentLoginHistoryId = loginRecord['id'] as int;
          } catch (e) {
            log('Could not record login history: $e');
          }
        }

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

  Future<void> signIn(String identifier, String password) async {
    String email = identifier;

    // If the input doesn't contain '@', treat it as a username and resolve the email via RPC
    if (!identifier.contains('@')) {
      final result = await supabase.rpc(
        'get_email_by_username',
        params: {'lookup_username': identifier},
      );
      if (result == null || (result as String).isEmpty) {
        throw Exception('No account found with username "$identifier"');
      }
      email = result;
    }

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
    userProfile = Profile.fromJson(query);

    if (!userProfile!.isActive) {
      await supabase.auth.signOut();
      session = null;
      user = null;
      userProfile = null;
      throw Exception('This account has been deactivated. Please contact the owner.');
    }

    userRoleType = await userProfile!.getRoleType(userProfile!);

    // Record login in login_history
    try {
      final loginRecord = await supabase.from('login_history').insert({
        'profile_id': userProfile!.id,
        'username': userProfile!.username,
        'login_time': DateTime.now().toIso8601String(),
      }).select().single();
      _currentLoginHistoryId = loginRecord['id'] as int;
    } catch (e) {
      log('Could not record login history: $e');
    }

    notifyListeners();
  }

  void signOut(BuildContext context) async {
    GoRouter router = GoRouter.of(context);

    // Record logout time in login_history
    if (_currentLoginHistoryId != null) {
      try {
        await supabase.from('login_history').update({
          'logout_time': DateTime.now().toIso8601String(),
        }).eq('id', _currentLoginHistoryId!);
      } catch (e) {
        log('Could not record logout time: $e');
      }
      _currentLoginHistoryId = null;
    }

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
