import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/messaging_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  String _selectedRole = 'elder';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final MessagingService _messagingService =
      MessagingService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _messagingService.dispose();

    super.dispose();
  }

  // Registers the device FCM token for the logged-in user.
  Future<void> _initializeMessaging(String userId) async {
    try {
      await _messagingService.initialize(userId);
    } catch (error) {
      // Notification setup failure should not prevent login.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged in, but notification setup failed: $error',
            ),
          ),
        );
      }
    }
  }

  // Opens the Person 4 dashboard after login or registration.
  void _goToDashboard() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Person4Dashboard(),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        // LOGIN
        final credential =
            await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user == null) {
          throw Exception(
            'Login failed. User information not found.',
          );
        }

        // Register this device for FCM notifications.
        await _initializeMessaging(user.uid);

        // Open dashboard after login.
        _goToDashboard();
      } else {
        // REGISTER
        final name = _nameController.text.trim();

        final credential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user == null) {
          throw Exception(
            'Registration failed. User information not found.',
          );
        }

        // Save user information in Firestore.
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(
          {
            'uid': user.uid,
            'name': name,
            'email': email,
            'role': _selectedRole,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Register this device for FCM notifications.
        await _initializeMessaging(user.uid);

        // Open dashboard after registration.
        _goToDashboard();
      }
    } on FirebaseAuthException catch (error) {
      String message = 'Authentication failed';

      if (error.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (error.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (error.code == 'weak-password') {
        message = 'Password must be at least 6 characters.';
      } else if (error.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (error.code == 'network-request-failed') {
        message = 'Check your internet connection.';
      } else {
        message = error.message ?? message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error while processing request: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCircle'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 16),

                Text(
                  _isLogin
                      ? 'Welcome Back'
                      : 'Create Account',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? 'Login to continue to CareCircle'
                      : 'Register to use CareCircle',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter your name';
                      }

                      return null;
                    },
                  ),

                if (!_isLogin)
                  const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter your email';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'elder',
                        child: Text('Elder'),
                      ),
                      DropdownMenuItem(
                        value: 'caregiver',
                        child: Text('Caregiver'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLogin
                                ? 'LOGIN'
                                : 'REGISTER',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed:
                      _isLoading ? null : _switchMode,
                  child: Text(
                    _isLogin
                        ? 'New user? Create an account'
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}