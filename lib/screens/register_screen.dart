import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitark/screens/login_screen.dart';
import 'package:fitark/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const double _maxWidth = 400;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool isLoading = false;

  void register() async {
    if (controllerEmail.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email address';
        isLoading = false; // Keep button normal
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(controllerEmail.text.trim())) {
      setState(() {
        errorMessage = 'Please enter a valid email address';
        isLoading = false; // Keep button normal
      });
      return;
    }

    if (controllerPassword.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please create a password';
        isLoading = false; // Keep button normal
      });
      return;
    }

    if (controllerPassword.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters long';
        isLoading = false; // Keep button normal
      });
      return;
    }

    // Only start loading AFTER validation passes
    setState(() {
      isLoading = true;
    });

    try {
      setState(() {
        isLoading = true;
      });
      await authService.value.createAccount(
          email: controllerEmail.text, password: controllerPassword.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Account created successfully! Please sign in.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login with slight delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Reset button to normal state on error
      setState(() {
        isLoading = false; // Reset loading state
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Please choose a stronger password';
            break;
          case 'email-already-in-use':
            errorMessage =
                'This email is already registered. Try signing in instead.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'Registration is currently unavailable. Please try again later.';
            break;
          default:
            errorMessage =
                e.message ?? 'Something went wrong. Please try again.';
        }
      });
    } catch (e) {
      // Reset button to normal state on any other error
      setState(() {
        isLoading = false; // Reset loading state
        errorMessage =
            'Network error. Please check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF2563EB); // Tailwind blue-600

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/woman_fitness_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.8),
                    Color.fromRGBO(0, 0, 0, 0.5),
                    Colors.transparent,
                  ],
                  stops: [0, 0.6, 1],
                ),
              ),
            ),
          ),
          // Background gradient

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Container(
                        constraints: const BoxConstraints(
                            maxWidth: RegisterScreen._maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title and subtitle
                            const SizedBox(height: 12),
                            const Text(
                              "Create an Account",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Start your fitness journey today.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Email
                            _InputField(
                              controller: controllerEmail,
                              icon: Icons.email,
                              hint: 'Email',
                              obscure: false,
                            ),
                            const SizedBox(height: 16),
                            // Password
                            _InputField(
                              controller: controllerPassword,
                              icon: Icons.lock,
                              hint: 'Password',
                              obscure: true,
                            ),
                            if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color:
                                        Colors.redAccent, // Make it stand out
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 28),
                            // Sign Up button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : register,
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: Colors.grey[400],
                                ),
                                child: isLoading
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Signing Up...",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // OR divider
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: Color(0xFFe5e7eb))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 14),
                                  ),
                                ),
                                const Expanded(
                                    child: Divider(color: Color(0xFFe5e7eb))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Google button
                            SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                icon: Image.network(
                                  "https://lh3.googleusercontent.com/aida-public/AB6AXuBYYW8p517PmMm3ZLKEvjj8_MUMP-935yvTGtErGm59umS8s8797CPqoVbVp8PTCExJ4ahSlDUslKxxhWTKleQQxBWEBnsLuZgS-kuEe30hqo_Ilz9H7Op5Bz6ay9fC33IeyuEwntVMDqyKchI0denzxCmEr6aB_F8TjVyLxTuxRdOIcA64bIVBGieZN5A3tEMcguqhJscKj4TnRuYgGJ547Ul5klejvjmHh-HztLwf4JWm_cpSN4Cjn1bwJHpdPeMNg0NRHJ73yea-",
                                  width: 26,
                                  height: 26,
                                ),
                                label: const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFd1d5db)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Apple button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.apple,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Continue with Apple",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Already have account
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 15),
                                    children: [
                                      const TextSpan(
                                          text: "Already have an account? "),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            // go to RegisterScreen()
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Log In",
                                            style: TextStyle(
                                              color: primaryBlue,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom NavBar
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;

  const _InputField({
    this.controller,
    required this.icon,
    required this.hint,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white10,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Color(0xFF0b80ee), width: 2),
        ),
      ),
    );
  }
}
