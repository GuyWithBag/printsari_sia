import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
