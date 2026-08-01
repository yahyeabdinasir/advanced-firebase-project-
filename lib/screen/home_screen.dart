import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserService _userService = UserService();

  UserModel? _profile;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final profile = await _userService.getUser(uid);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load profile. Pull down or tap Retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? 'Unknown';
    final name = _profile?.name;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : _loadError != null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProfile,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name == null || name.isEmpty
                                  ? 'Welcome, $email'
                                  : 'Welcome, $name',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (_profile == null) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'No Firestore profile yet.\n'
                                'Create a new account to save name in users/{uid}.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
