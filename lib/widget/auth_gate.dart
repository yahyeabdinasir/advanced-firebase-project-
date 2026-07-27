import 'package:flutter/material.dart';

import '../screen/home_screen.dart';
import '../screen/login_screen.dart';
import '../services/auth_service.dart';

/// Decides which screen to show based on the Firebase Auth session.
///
/// - Waiting for Firebase → loading spinner (unless a cached user exists)
/// - User is logged in   → HomeScreen
/// - Nobody logged in    → LoginScreen
///
/// Because Auth remembers the session on the device, closing and
/// reopening the app still lands on Home if they did not log out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // While Firebase re-checks the session, use the cached user so we
        // don't flash a full-screen spinner when returning from background.
        if (snapshot.connectionState == ConnectionState.waiting) {
          final cachedUser = authService.currentUser;
          if (cachedUser != null) {
            return const HomeScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
