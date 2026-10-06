import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthErrorHandler {
  static String handleException(dynamic e) {
    // 🔥 Print detailed error for developer in terminal
    debugPrint("=== AUTH ERROR ===");
    debugPrint(e.toString());
    if (e is FirebaseAuthException) {
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
    }
    debugPrint("==================");

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use. Please try another one.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'operation-not-allowed':
          return 'Registration is currently disabled.';
        case 'weak-password':
          return 'The password is too weak. Please use a stronger password.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials and try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'requires-recent-login':
          return 'This action requires recent authentication. Please log in again.';
        default:
          return e.message ??
              'An unexpected authentication error occurred. Please try again.';
      }
    }

    return 'Something went wrong. Please try again later.';
  }
}
