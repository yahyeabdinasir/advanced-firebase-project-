import 'package:firebase_auth/firebase_auth.dart';

/// Small helper around Firebase Auth.
/// Screens call these methods — they do not talk to Firebase directly.
class AuthService {
  // One shared Firebase Auth instance for the whole app
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login: only works if this email already exists in Firebase.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register: creates a NEW user in Firebase Auth.
  /// Fails if that email is already registered.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Logout: clears the current Firebase session.
  Future<void> logout() {
    return _auth.signOut();
  }

  /// Currently signed-in user (null if nobody is logged in).
  User? get currentUser => _auth.currentUser;
}
