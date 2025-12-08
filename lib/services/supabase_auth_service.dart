
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with Supabase (Supabase Auth only)
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      developer.log('Attempting signup with email: "$email"', name: 'FirebaseAuthService');  // Debug log
      final response = await _supabase.auth.signUp(email: email, password: password);
      // Log entire response for diagnostics
      developer.log('Signup response user: ${response.user?.id}', name: 'FirebaseAuthService');
      developer.log('Signup session null? ${response.session == null}', name: 'FirebaseAuthService');
      if (response.user == null) {
        // Try to read currentUser in case SDK populated it
        final current = _supabase.auth.currentUser;
        if (current != null) {
          developer.log('Using currentUser after sign-up: ${current.id}', name: 'FirebaseAuthService');
          return current;
        }
        developer.log('Signup returned null user (likely confirmation configured).', name: 'FirebaseAuthService');
        return null;
      }
      developer.log('Signup successful for email: "$email"', name: 'FirebaseAuthService');  // Debug log
      return response.user;
    } catch (e) {
      if (e is AuthException) {
        developer.log('AuthException during signup code=${e.statusCode} message=${e.message}', name: 'FirebaseAuthService');
        throw 'SUPABASE_AUTH_ERROR ${e.statusCode ?? ''} ${e.message}';
      }
      developer.log('Unknown signup error for email: "$email" -> $e', name: 'FirebaseAuthService');  // Debug log
      throw 'SIGNUP_UNKNOWN_ERROR ${e.toString()}';
    }
  }

  // Sign in with Supabase (Supabase Auth only)
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      developer.log('Attempting login with email: "$email"', name: 'FirebaseAuthService'); // Debug log
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      developer.log('Login response user: ${response.user?.id} session null? ${response.session == null}', name: 'FirebaseAuthService');
      if (response.user == null) {
        // Try to read currentUser in case SDK populated it
        final current = _supabase.auth.currentUser;
        if (current != null) {
          developer.log('Using currentUser from auth after sign-in: ${current.id}', name: 'FirebaseAuthService');
          return current;
        }
        developer.log('Login returned null user. Likely email not confirmed or invalid credentials.', name: 'FirebaseAuthService');
        throw 'EMAIL_NOT_CONFIRMED';
      }
      developer.log('Login successful for email: "$email"', name: 'FirebaseAuthService'); // Debug log
      return response.user;
    } catch (e) {
      if (e is AuthException) {
        developer.log('AuthException during login code=${e.statusCode} message=${e.message}', name: 'FirebaseAuthService');
        throw 'SUPABASE_AUTH_ERROR ${e.statusCode ?? ''} ${e.message}';
      }
      developer.log('Unknown login error for email: "$email" -> $e', name: 'FirebaseAuthService'); // Debug log
      throw 'SIGNIN_UNKNOWN_ERROR ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw e.toString();
    }
  }

  // Email verification disabled in app logic; always treat as verified.
  bool get isEmailVerified => true;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  }
}
