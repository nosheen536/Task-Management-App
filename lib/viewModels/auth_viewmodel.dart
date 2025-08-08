

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';


class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  

  bool isLoading = false;

  // Field-specific error messages
  String? usernameError;
  String? emailError;
  String? passwordError;

  // General login/signup error (shown under button)
  String? loginError;

  // Live password validation flag
  bool isPasswordValid = false;

  /// ✅ Validate password: 8–14 chars, only letters & numbers, must contain at least 1 letter & 1 number
  void validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,14}$');
    if (!regex.hasMatch(password)) {
      passwordError = '8–14 chars, letters & numbers, must include both';
      isPasswordValid = false;
    } else {
      passwordError = null;
      isPasswordValid = true;
    }
    notifyListeners();
  }

  /// ✅ Clear all field errors
  void clearErrors() {
    usernameError = null;
    emailError = null;
    passwordError = null;
    loginError = null;
    notifyListeners();
  }

  /// ✅ Sign up
  Future<bool> signUp(String username, String email, String password) async {
    isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Check username availability
      final usernameAvailable = await _firebaseService.isUsernameAvailable(username);
      if (!usernameAvailable) {
        usernameError = 'Username is already taken';
        notifyListeners();
        return false;
      }

      // Create Firebase user
      final userCredential = await _firebaseService.signUpWithEmail(email, password);

      // Save user data to Firestore
      await _firebaseService.saveUserData(userCredential.user!.uid, username, email);

      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          emailError = 'Email is already registered';
          break;
        case 'invalid-email':
          emailError = 'Invalid email format';
          break;
        case 'weak-password':
          passwordError = 'Weak password';
          break;
        default:
          loginError = e.message ?? 'Sign up failed';
      }
      return false;
    } catch (e) {
      loginError = 'Sign up failed. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Login
  Future<bool> login(String email, String password) async {
    isLoading = true;
    clearErrors();
    notifyListeners();

    final error = await _firebaseService.signIn(email, password);

    isLoading = false;

    if (error != null) {
      loginError = error; // e.g., "Incorrect email or password"
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }
}
