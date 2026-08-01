import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _authSubscription = _authService.authStateChanges.listen((user) {
      _user = user;
      _isInitializing = false;
      notifyListeners();
    });
  }

  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _messageForLoginError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _authService.register(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _messageForRegisterError(e);
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _errorMessage = null;
    await _authService.logout();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _messageForLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account for this email. Create one first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'invalid-email':
        return 'Email format looks invalid.';
      default:
        return e.message ?? 'Login failed.';
    }
  }

  String _messageForRegisterError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email already has an account.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Email format looks invalid.';
      default:
        return e.message ?? 'Sign up failed.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
