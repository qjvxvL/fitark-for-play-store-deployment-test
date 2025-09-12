import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Start animation
    _animationController.forward();

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));

    // Navigate based on auth state
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    var nextScreen = FirebaseAuth.instance.currentUser != null
        ? const HomeScreen()
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Background image with overlay
          image: DecorationImage(
            image: AssetImage('assets/images/man_splash_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Blue overlay
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0B81EF).withOpacity(0.7),
                const Color(0xFF0B81EF).withOpacity(0.8),
                const Color(0xFF0B81EF).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Main content centered
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // FitFlow Title
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: const Text(
                                  'FitArk',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1.0,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Arkitekta brand with icon
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Layers icon
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  child: CustomPaint(
                                    size: const Size(24, 24),
                                    painter: LayersIconPainter(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Arkitekta text
                                const Text(
                                  'Arkitekta',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF5F5F5),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Bottom section with loading indicator
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 60),
                              child: const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

// Custom painter for the layers icon
class LayersIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    // First layer (top)
    path1.moveTo(size.width * 0.1, size.height * 0.3);
    path1.lineTo(size.width * 0.5, size.height * 0.1);
    path1.lineTo(size.width * 0.9, size.height * 0.3);
    path1.lineTo(size.width * 0.5, size.height * 0.5);
    path1.close();

    // Second layer (middle)
    path2.moveTo(size.width * 0.1, size.height * 0.5);
    path2.lineTo(size.width * 0.5, size.height * 0.3);
    path2.lineTo(size.width * 0.9, size.height * 0.5);
    path2.lineTo(size.width * 0.5, size.height * 0.7);
    path2.close();

    // Third layer (bottom)
    path3.moveTo(size.width * 0.1, size.height * 0.7);
    path3.lineTo(size.width * 0.5, size.height * 0.5);
    path3.lineTo(size.width * 0.9, size.height * 0.7);
    path3.lineTo(size.width * 0.5, size.height * 0.9);
    path3.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
