import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<void> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final userId = userCredential.user!.uid;

      await _database.child('users').child(userId).set({
        'uid': userId,
        'email': email.trim(),
        'name': name.trim(),
        'skills': [],
        'interests': [],
        'bio': 'Enthusiastic IT Student',
        'createdAt': ServerValue.timestamp,
        'profileImage': 'https://i.postimg.cc/wjlhzZ6c/vishakhaprofessionalphoto.jpg',
      });

      debugPrint('✅ User created with proper structure: $userId');
      _safeNotifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      throw 'Failed to create account. Please try again.';
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      debugPrint('✅ User signed in successfully: ${_auth.currentUser?.email}');
      _safeNotifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      throw 'Failed to sign in. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔄 Signing out user: ${_auth.currentUser?.email}');

      await _auth.signOut();
      debugPrint('✅ User signed out successfully');
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Safe method to notify listeners that won't crash during build
  void _safeNotifyListeners() {
    try {
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Could not notify listeners (likely during build): $e');
      // Schedule notification for next frame
      Future.delayed(Duration.zero, () {
        notifyListeners();
      });
    }
  }

  // Stream for auth state changes
  Stream<User?> get userState {
    return _auth.authStateChanges();
  }
}