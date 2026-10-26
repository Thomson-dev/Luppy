import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/sign_in.model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<AuthResponse> signIn(LoginData data) async {
    return _supabase.auth.signInWithPassword(
      email: data.email.trim(),
      password: data.password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signUp({required String email, required String password}) async {
    await _supabase.auth.signUp(email: email.trim(), password: password);
  }
}
