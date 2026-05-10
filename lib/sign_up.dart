import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'controllers/auth_controller.dart';
import 'models/models.dart';
import 'services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '379014504202-cfr5tgueggk2vi4ok6p7jqv26su1qkoc.apps.googleusercontent.com',
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  void _showMessage(String message) {
    Get.snackbar(
      'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _handleSignUp() async {
    final username = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }
    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post('/Auth/signup', {
        'username': username,
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = AuthResponse.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
        if (data.token != null && data.token!.isNotEmpty) {
          _auth.storeToken(data.token!, data.user);
          Get.offAllNamed('/kanban');
        } else {
          _showMessage('Account created! Please sign in.');
          Get.back();
        }
      } else {
        _showMessage('Signup failed (${res.statusCode}). ${res.body}');
      }
    } catch (e) {
      _showMessage('Network error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        _showMessage('Failed to get Google ID token.');
        return;
      }

      setState(() => _isLoading = true);
      try {
        final res = await ApiService.post('/Auth/google-signup', {
          'idToken': idToken,
          'name': account.displayName ?? '',
          'email': account.email,
        });

        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = AuthResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>,
          );
          if (data.token != null && data.token!.isNotEmpty) {
            _auth.storeToken(data.token!, data.user);
            Get.offAllNamed('/kanban');
          } else {
            _showMessage('Account created! Please sign in.');
            Get.back();
          }
        } else {
          _showMessage('Google signup failed (${res.statusCode}). ${res.body}');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') return;
      if (e.message != null && e.message!.contains('ApiException: 10')) {
        _showMessage('Google Sign-In not configured: add SHA-1 fingerprint to Firebase Console.');
      } else {
        _showMessage('Google sign-in error (${e.code}): ${e.message}');
      }
    } catch (e) {
      _showMessage('Google sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF2FF), Color(0xFFF7F9FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20),
                        border: const OutlineInputBorder(),
                        labelText: 'Username',
                        hintText: 'John Doe',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20),
                        border: const OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'john@example.com',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20),
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.verified_user,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20),
                        labelText: 'Confirm password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create account'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignUp,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign up with Google'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
