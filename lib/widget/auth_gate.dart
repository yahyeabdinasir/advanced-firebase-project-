// import 'package:flutter/material.dart';

// import '../screen/home_screen.dart';
// import '../screen/login_screen.dart';
// import '../services/auth_service.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = AuthService();

//     return StreamBuilder(
//       stream: authService.authStateChanges,
//       builder: (context, snapshot) {
//         // Prefer cached user while auth is reconnecting to avoid a spinner flash.
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           final cachedUser = authService.currentUser;
//           if (cachedUser != null) {
//             return const HomeScreen();
//           }
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasData) {
//           return const HomeScreen();
//         }

//         return const LoginScreen();
//       },
//     );
//   }
// }
