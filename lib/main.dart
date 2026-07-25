import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screen/login_screen.dart';

void main() async {
  // Required before using any Flutter plugin (like Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Connects your app to Firebase (config is in firebase_options.dart)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Firebase',
      home: const LoginScreen(), // App starts on Login
    );
  }
}
