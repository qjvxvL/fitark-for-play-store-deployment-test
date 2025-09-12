import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitark/screens/home_screen.dart';
import 'package:fitark/screens/progress_screen.dart';
import 'package:fitark/screens/workout_list_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'community_screen.dart';

class NofapScreen extends StatefulWidget {
  const NofapScreen({super.key});

  @override
  State<NofapScreen> createState() => _NofapScreenState();
}

class _NofapScreenState extends State<NofapScreen>
    with TickerProviderStateMixin {
  DateTime? _startDate;
  int _currentStreak = 0;
  int _longestStreak = 0;
  bool _isLoading = true;
  String? _userId;
    late AnimationController _animationController;
    late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_userId != null) {
      _loadCounterData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCounterData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_nofap_counter')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _startDate = (data['start_date'] as Timestamp?)?.toDate();
          _longestStreak = data['longest_streak'] ?? 0;
          _currentStreak = _calculateCurrentStreak();
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading counter data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculateCurrentStreak() {
    if (_startDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays;
    return difference >= 0 ? difference : 0;
  }

  Future<void> _startCounter() async {
    final now = DateTime.now();

    try {
      await FirebaseFirestore.instance
          .collection('user_nofap_counter')
          .doc(_userId)
          .set({
        'user_id': _userId,
        'start_date': Timestamp.fromDate(now),
        'longest_streak': _longestStreak,
        'created_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });

      setState(() {
        _startDate = now;
        _currentStreak = 0;
      });

      _animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NoFap journey started! You got this! 💪'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting counter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetCounter() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Counter'),
        content: const Text(
            'Are you sure you want to reset your streak? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final now = DateTime.now();

      try {
        final newLongestStreak =
            _currentStreak > _longestStreak ? _currentStreak : _longestStreak;

        await FirebaseFirestore.instance
            .collection('user_nofap_counter')
            .doc(_userId)
            .update({
          'start_date': Timestamp.fromDate(now),
          'longest_streak': newLongestStreak,
          'updated_at': Timestamp.fromDate(now),
        });

        setState(() {
          _startDate = now;
          _currentStreak = 0;
          _longestStreak = newLongestStreak;
        });

        _animationController.reset();
        _animationController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Counter reset. Don\'t give up - restart stronger! 🔥'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting counter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getMotivationalMessage() {
    if (_currentStreak == 0) {
      return "Ready to start your journey?";
    } else if (_currentStreak < 7) {
      return "Great start! Keep going! 🌱";
    } else if (_currentStreak < 30) {
      return "Building momentum! 🔥";
    } else if (_currentStreak < 90) {
      return "Strong streak! You're crushing it! 💪";
    } else {
      return "Incredible dedication! You're a warrior! 🏆";
    }
  }

  double _getProgressPercentage() {
    // Progress towards next milestone
    if (_currentStreak < 7) return _currentStreak / 7;
    if (_currentStreak < 30) return (_currentStreak - 7) / 23;
    if (_currentStreak < 90) return (_currentStreak - 30) / 60;
    if (_currentStreak < 365) return (_currentStreak - 90) / 275;
    return 1.0;
  }

  String _getNextMilestone() {
    if (_currentStreak < 7) return "7 Days";
    if (_currentStreak < 30) return "30 Days";
    if (_currentStreak < 90) return "90 Days";
    if (_currentStreak < 365) return "1 Year";
    return "Legend!";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('NoFap Counter'),
          centerTitle: true,
          backgroundColor: const Color(0xFF2563eb),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: _BottomNavBar(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoFap Counter'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Circular Counter
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(280, 280),
                        painter: CircularCounterPainter(
                          progress: _getProgressPercentage() *
                              _progressAnimation.value,
                          currentStreak: _currentStreak,
                        ),
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_currentStreak',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563eb),
                                  ),
                                ),
                                Text(
                                  _currentStreak == 1 ? 'Day' : 'Days',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Next: ${_getNextMilestone()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Motivational Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2563eb).withOpacity(0.1),
                      const Color(0xFF3b82f6).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getMotivationalMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2563eb),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Longest',
                        value: '$_longestStreak',
                        subtitle: 'Days',
                        icon: Icons.emoji_events,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _StatCard(
                        title: 'Started',
                        value: _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}'
                            : '--/--',
                        subtitle: 'Date',
                        icon: Icons.calendar_today,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Action Buttons
              if (_startDate == null)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _startCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10b981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Your Journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _resetCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset Counter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class CircularCounterPainter extends CustomPainter {
  final double progress;
  final int currentStreak;

  CircularCounterPainter({
    required this.progress,
    required this.currentStreak,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2563eb),
          Color(0xFF3b82f6),
          Color(0xFF10b981),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Milestone dots
    final milestones = [7, 30, 90, 365];
    for (int i = 0; i < milestones.length; i++) {
      final angle = (2 * math.pi / milestones.length) * i - math.pi / 2;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final dotPaint = Paint()
        ..color = currentStreak >= milestones[i]
            ? const Color(0xFF10b981)
            : Colors.grey[400]!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);

      // Milestone labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${milestones[i]}d',
          style: TextStyle(
            color: currentStreak >= milestones[i]
                ? const Color(0xFF10b981)
                : Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelX =
          center.dx + (radius + 25) * math.cos(angle) - textPainter.width / 2;
      final labelY =
          center.dy + (radius + 25) * math.sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// ...existing code for _BottomNavBar remains the same...
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF2563eb); // blue-600

    Widget navItem({
      IconData? icon,
      Widget? customIcon,
      required String label,
      bool selected = false,
      VoidCallback? onTap,
    }) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon != null
                      ? Icon(
                          icon,
                          size: 24,
                          color: selected ? blueColor : const Color(0xFF64748b),
                        )
                      : customIcon!,
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? blueColor : const Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFf1f5f9))), // slate-100
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          navItem(
            icon: Icons.home,
            label: "Home",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.fitness_center,
            label: "Workouts",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const WorkoutListScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.leaderboard,
            label: "Progress",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ProgressScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.groups,
            label: "Community",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CommunityScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.self_improvement,
            label: "Nofap",
            selected: true,
            onTap: () {
              // Already on nofap screen
            },
          ),
        ],
      ),
    );
  }
}
