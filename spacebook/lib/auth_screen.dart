import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:spacebook/main_screen.dart';
import 'services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _isLoading = false;
  String accountType = "Buyer (I want to book spaces)";

  final greenColor = const Color(0xFF3D7F1E);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signing in with Google...')));

    // Version 7.x uses GoogleAuthProvider directly for web
    final googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    googleProvider.addScope('profile');

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) return;

    // Try login with backend, register if first time
    try {
      final loginResult = await ApiService.login(
        firebaseUser.email!,
        firebaseUser.uid,
      );
      if (loginResult['token'] == null) {
        await ApiService.register(
          firebaseUser.displayName ?? 'User',
          firebaseUser.email!,
          firebaseUser.uid,
        );
      }
    } catch (_) {
      ApiService.currentUser = {
        'name': firebaseUser.displayName ?? 'User',
        'email': firebaseUser.email ?? '',
      };
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google sign-in failed: $e')));
  }
}
  // ── Facebook placeholder ────────────────────────────────────────────────────
  void _handleFacebookSignIn() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Facebook Login'),
        content: const Text(
            'Facebook login requires additional setup. Please use email/password or Google login for now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: greenColor)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background colour block
          Container(
            height: 320,
            color: const Color(0xFF2D6A0A),
          ),

          // Green overlay
          Container(
            height: 320,
            color: Colors.green.withOpacity(0.6),
          ),

          // Logo & Title
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Icon(Icons.business, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "SpaceBook",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Book spaces near your place.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Global loading overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Form Container
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle Login / Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          toggleButton("Login", true),
                          const SizedBox(width: 10),
                          toggleButton("Sign Up", false),
                        ],
                      ),
                      const SizedBox(height: 25),
                      isLogin ? buildLogin() : buildSignup(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Toggle button ───────────────────────────────────────────────────────────
  Widget toggleButton(String text, bool loginValue) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = loginValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color:
              isLogin == loginValue ? greenColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isLogin == loginValue ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ── Login form ──────────────────────────────────────────────────────────────
  Widget buildLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Email Address"),
        const SizedBox(height: 5),
        inputField("Enter email", controller: _emailController),
        const SizedBox(height: 15),
        const Text("Password"),
        const SizedBox(height: 5),
        inputField("Enter password",
            obscure: true, controller: _passwordController),
        const SizedBox(height: 20),
        primaryButton("Login"),
        const SizedBox(height: 15),
        const Center(child: Text("Or login with")),
        const SizedBox(height: 10),
        socialButtons(),
      ],
    );
  }

  // ── Signup form ─────────────────────────────────────────────────────────────
  Widget buildSignup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Full Name"),
        const SizedBox(height: 5),
        inputField("Enter full name", controller: _nameController),
        const SizedBox(height: 15),
        const Text("Email Address"),
        const SizedBox(height: 5),
        inputField("Enter email", controller: _emailController),
        const SizedBox(height: 15),
        const Text("Password"),
        const SizedBox(height: 5),
        inputField("Enter password",
            obscure: true, controller: _passwordController),
        const SizedBox(height: 15),
        const Text("Account Type"),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: accountType,
          decoration: inputDecoration(),
          items: const [
            DropdownMenuItem(
              value: "Buyer (I want to book spaces)",
              child: Text("Buyer (I want to book spaces)"),
            ),
            DropdownMenuItem(
              value: "Seller (I want to offer spaces)",
              child: Text("Seller (I want to offer spaces)"),
            ),
          ],
          onChanged: (value) => setState(() => accountType = value!),
        ),
        const SizedBox(height: 15),

        // Extra fields for Seller
        if (accountType == "Seller (I want to offer spaces)") ...[
          const Text("Contact Number"),
          const SizedBox(height: 5),
          inputField("Enter phone number"),
          const SizedBox(height: 15),
          const Text("Business Address"),
          const SizedBox(height: 5),
          inputField("Enter address"),
          const SizedBox(height: 15),
          const Text("Company ID / License"),
          const SizedBox(height: 5),
          inputField("Enter registration number"),
          const SizedBox(height: 15),
        ],

        primaryButton("Create Account"),
        const SizedBox(height: 15),
        const Center(child: Text("Or sign up with")),
        const SizedBox(height: 10),
        socialButtons(),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget inputField(String hint,
      {bool obscure = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: inputDecoration(hint),
    );
  }

  InputDecoration inputDecoration([String hint = ""]) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ── Primary button ──────────────────────────────────────────────────────────
  Widget primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: greenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                try {
                  if (isLogin) {
                    final result = await ApiService.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (result['token'] != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainScreen()));
                    } else {
                      _showSnackBar(
                          result['error'] ?? 'Login failed');
                    }
                  } else {
                    final result = await ApiService.register(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (result['token'] != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainScreen()));
                    } else {
                      _showSnackBar(
                          result['error'] ?? 'Registration failed');
                    }
                  }
                } catch (e) {
                  _showSnackBar(
                      'Connection error. Is the backend running?');
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(text),
      ),
    );
  }

  // ── Social buttons ──────────────────────────────────────────────────────────
  Widget socialButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            icon: const Icon(Icons.g_mobiledata, size: 20),
            label: const Text("Google"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleFacebookSignIn,
            icon: const Icon(Icons.facebook, size: 20),
            label: const Text("Facebook"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}