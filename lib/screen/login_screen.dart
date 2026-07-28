import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:advanced_firebase/services/local_prefs_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'signup_screen.dart';

// StatefulWidget = can change (text in fields, etc.)
// StatelessWidget = fixed UI that does not change
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}





class _LoginScreenState extends State<LoginScreen> {
  // Controllers hold the text the user types
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key lets us validate all fields together
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Our small Firebase Auth helper
  final AuthService _authService = AuthService();

  // our shared preference class setup 
  final LocalPrefsService _sharedPreference= LocalPrefsService();

  // Shows a loading spinner while Firebase is working
  bool _isLoading = false;



@override
  void initState() async{
  await _sharedPreference.getEmail();
 
    super.initState();
  }


  Future<void> LoadSavedEmail() async {
    final savedEmail = await  _sharedPreference.getEmail();

    if (_emailController != null) {
      _emailController.text = savedEmail;
    }
  }
  @override
  void dispose() {
    // Always dispose controllers to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  Future<void> _login() async {
    // Runs validators on each TextFormField
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Ask Firebase: does this email + password match an existing user?
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Success → AuthGate hears the new user and shows Home automatically.
      // No Navigator.pushReplacement needed.
    } on FirebaseAuthException catch (e) {
      // Firebase sends error codes we can show as friendly messages
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForAuthError(e))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Turns Firebase error codes into short user-facing text.
  String _messageForAuthError(FirebaseAuthException e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('University App'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email';
                    }
                    return null; // null = valid
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // hides password
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Disable the button while Firebase is busy
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to Sign Up screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
