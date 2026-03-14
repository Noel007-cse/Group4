import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);


  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  String accountType = "Buyer (I want to book spaces)";

  final greenColor = const Color(0xFF3D7F1E);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Container(
            height: 320,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"), // Add your image
                fit: BoxFit.cover,
              ),
            ),
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
                )
              ],
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

  Widget toggleButton(String text, bool loginValue) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLogin = loginValue;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isLogin == loginValue
              ? greenColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isLogin == loginValue ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

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
        inputField("Enter password", obscure: true, controller: _passwordController),

        const SizedBox(height: 20),
        primaryButton("Login"),

        const SizedBox(height: 15),
        const Center(child: Text("Or login with")),
        const SizedBox(height: 10),
        socialButtons(),
      ],
    );
  }

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
        inputField("Enter password", obscure: true, controller: _passwordController),

        const SizedBox(height: 15),
        const Text("Account Type"),
        const SizedBox(height: 5),

        // Dropdown
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
          onChanged: (value) {
            setState(() {
              accountType = value!;
            });
          },
        ),

        const SizedBox(height: 15),

        // Extra fields if Seller
        if (accountType ==
            "Seller (I want to offer spaces)") ...[
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

  Widget inputField(String hint, {bool obscure = false, TextEditingController? controller}) {
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
      onPressed: () async {
        try {
          if (isLogin) {
            final result = await ApiService.login(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
            if (result['token'] != null) {
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MainScreen()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['error'] ?? 'Login failed')));
            }
          } else {
            final result = await ApiService.register(
              _nameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
            if (result['token'] != null) {
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MainScreen()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['error'] ?? 'Registration failed')));
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connection error. Is the backend running?')));
        }
      },
      child: Text(text),
    ),
  );
}

  Widget socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata),
          label: const Text("Google"),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.facebook),
          label: const Text("Facebook"),
        ),
      ],
    );
  }
}