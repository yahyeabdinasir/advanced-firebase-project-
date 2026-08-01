import 'package:advanced_firebase/services/fcm_service.dart';
import 'package:advanced_firebase/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final FcmService _fcmService = FcmService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    User? createdUser;

    try {
      final credential = await auth.register(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (credential == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Sign up failed.')),
        );
        return;
      }

      createdUser = credential.user;
      if (createdUser == null) throw Exception('User was not created.');

      await _userService.createUser(
        UserModel(
          uid: createdUser.uid,
          email: createdUser.email ?? _emailController.text.trim(),
          name: _nameController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      await _fcmService.SetUpaAfterLogin();

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      await createdUser?.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForFirestoreError(e))));
    } catch (e) {
      await createdUser?.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save profile: $e')));
    }
  }

  String _messageForFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied saving profile. Ask your admin to deploy Firestore rules.';
      case 'unavailable':
        return 'Firestore is unavailable. Check your connection and try again.';
      default:
        return e.message ?? 'Could not save profile.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefix: const Icon(Icons.person),
                    hintText: 'your name ',
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefix: const Icon(Icons.attach_email),
                    labelText: 'Email',
                    hintText: 'exmaple@gmail.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefix: const Icon(Icons.password_outlined),
                    labelText: 'Password',
                    hintText: 'passoword',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefix: const Icon(Icons.password_outlined),
                    labelText: 'Confirm Password',
                    hintText: 'passoword',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _signup,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
