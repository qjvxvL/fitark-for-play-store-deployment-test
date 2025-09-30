import 'package:fitark/screens/register_screen.dart';
import 'package:flutter/material.dart';
// Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkFirebaseConfig();
  }

  void _checkFirebaseConfig() {
    print('Firebase App: ${_auth.app.name}');
    print('Firebase Project ID: ${_auth.app.options.projectId}');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add explicit configuration check
      if (_auth.app.options.projectId.isEmpty) {
        throw Exception('Firebase not properly configured');
      }

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        print('Login successful! User: ${userCredential.user?.email}');
        print('User UID: ${userCredential.user?.uid}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Welcome back, ${userCredential.user?.email}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear the form
        _emailController.clear();
        _passwordController.clear();

        // change to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      print('Firebase Auth Error: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'configuration-not-found':
        case 'unknown':
          errorMessage = 'Firebase configuration error. Please check setup.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Invalid email or password.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your internet connection.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message ?? 'Unknown error'}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle the type casting error more gracefully
      print('Unexpected error: $e');

      // Check if user is actually logged in despite the error
      if (_auth.currentUser != null) {
        print('User is actually logged in: ${_auth.currentUser?.email}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Login successful! Welcome, ${_auth.currentUser?.email}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Clear the form
          _emailController.clear();
          _passwordController.clear();
          // change to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createTestAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to create the test account
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: '123456',
      );

      print('Test account created! User: ${userCredential.user?.email}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Test account created successfully!\nEmail: test@example.com\nPassword: 123456'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Auto-fill the form
        _emailController.text = 'test@example.com';
        _passwordController.text = '123456';
      }
    } on FirebaseAuthException catch (e) {
      print('Error creating test account: ${e.code} - ${e.message}');

      if (mounted) {
        if (e.code == 'email-already-in-use') {
          // Account already exists, just fill the form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '✅ Test account already exists!\nEmail: test@example.com\nPassword: 123456'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );

          // Auto-fill the form
          _emailController.text = 'test@example.com';
          _passwordController.text = '123456';
        } else if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password is too weak. Try a stronger password.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to create test account: ${e.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Unexpected error creating test account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Future<void> _fillTestCredentials() async {
    // Fill form with test credentials
    _emailController.text = 'test@example.com';
    _passwordController.text = '123456';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Form filled with test credentials. Click "Create Test Account" first if account doesn\'t exist.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _checkCurrentUser() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      print('Current user: ${currentUser.email}');
      print('User UID: ${currentUser.uid}');
      print('Email verified: ${currentUser.emailVerified}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ User logged in: ${currentUser.email}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      print('No user currently logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No user logged in'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Updated Google Sign-In method with better error handling
  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);

    _handleSuccessfulGoogleSignIn(userCredential);
  }

  // Add this helper method
  void _handleSuccessfulGoogleSignIn(UserCredential userCredential) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Welcome, ${userCredential.user?.displayName ?? userCredential.user?.email}!'),
        backgroundColor: Colors.lightBlue,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to home screen
    if (mounted && userCredential.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Enhanced sign out method
  Future<void> _signingOut() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final fireBaseAuth = FirebaseAuth.instance;
    UserCredential userCredential =
        await fireBaseAuth.signInWithCredential(credential);
    await fireBaseAuth.signOut();
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.lightBlue,
        ),
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ... Keep all other existing methods unchanged ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCbJiUSEk1j8BQyPrhxh1E06WmY18iWGr1LpkayC1aQ1SmHl7jHkO8-0HnAHR1HJeU0Sya6F8wfgwCpd3MENJ5UdVe4swpldlXpJm0VQ8XJwERgi-jROvUd8yrntSYzfb-ockAlc1vSrSsWNzUoIswztLiJyzw8ykjsJV-EGrkuPYP4EvNnlmWjioDI548yXnQX9IapwgxhkNT8nY20PL-vm2nIyOLwvcSu2okRgIen1McaufHz29Ad3LkDA_Kwk08U2idvrpG5Bw1G',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1F2937), Color(0xFF111827)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.fitness_center,
                        color: Colors.white, size: 100),
                  ),
                );
              },
            ),
          ),
          // Gradient overlay
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
          // Content
          SafeArea(

            child: SingleChildScrollView(

            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    // Debug info
                    Container(
                      height: 215,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            'Firebase: ${_auth.currentUser?.email ?? 'Not logged in'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10),
                          ),
                          Text(
                            'Project: ${_auth.app.options.projectId}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: _checkCurrentUser,
                                child: const Text(
                                  'Check User',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _signingOut();
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'FitArk',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Unleash Your Potential',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Email field
                            _InputField(
                              controller: _emailController,
                              icon: Icons.email,
                              hint: 'Email',
                              obscure: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Password field
                            _InputField(
                              controller: _passwordController,
                              icon: Icons.lock,
                              hint: 'Password',
                              obscure: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Test account buttons
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextButton(
                                      onPressed:
                                          _isLoading ? null : _createTestAccount,
                                      child: Text(
                                        _isLoading
                                            ? 'Creating...'
                                            : '1. Create Test Account',
                                        style: const TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _isLoading ? null : _fillTestCredentials,
                                      child: const Text(
                                        '2. Fill Test Credentials',
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Forgot password not implemented yet')),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0b80ee),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed:
                                    _isLoading ? null : _signInWithEmailAndPassword,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Social buttons (UPDATE THIS SECTION)
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Color(0xFF4B5563))),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Or continue with',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8), fontSize: 14),
                                  ),
                                ),
                                Expanded(child: Divider(color: Color(0xFF4B5563))),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(
                                  icon: Icons.g_mobiledata,
                                  onTap: _isLoading
                                      ? null
                                      : signInWithGoogle, // Updated this line
                                ),
                                const SizedBox(width: 20),
                                _SocialButton(
                                  icon: Icons.alternate_email,
                                  onTap: () =>
                                      ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Twitter Sign-In not implemented yet')),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen()));
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... Keep existing _InputField and _SocialButton classes unchanged
class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData icon;
  final String hint;
  final bool obscure;
  final String? Function(String?)? validator;

  const _InputField({
    this.controller,
    required this.icon,
    required this.hint,
    required this.obscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // Changed to nullable

  const _SocialButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: onTap == null
            ? Colors.white.withOpacity(0.05)
            : Colors.white10, // Different color when disabled
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Center(
          child: Icon(icon,
              color:
                  onTap == null ? Colors.white.withOpacity(0.5) : Colors.white,
              size: 28),
        ),
      ),
    );
  }
}
