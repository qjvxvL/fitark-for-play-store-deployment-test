import 'package:fitark/screens/community_screen.dart';
import 'package:fitark/screens/nofap_screen.dart';
import 'package:fitark/screens/progress_screen.dart';
import 'package:fitark/screens/settings_screen.dart';
import 'package:fitark/screens/workout_list_screen.dart';
import 'package:fitark/screens/workout_detail_screen.dart';
import 'package:fitark/screens/workout_flow_screen.dart';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkoutService _workoutService = WorkoutService();
  Workout? _todayWorkout;
  bool _isLoading = true;
  Map<String, dynamic>? _progressData;
  List<Map<String, dynamic>> _workoutSessions = [];
  final int _totalWorkouts = 0;
  int _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayWorkout();
    _loadProgressData();
    _fetchWorkoutData();
  }

  Future<void> _fetchWorkoutData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('workout_sessions')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      if(!mounted) return;

      _isLoading = true;

      final List<Map<String, dynamic>> sessions = [];
      int totalDuration = 0;
      int totalCalories = 0;
      int streakDays = 0;

      // Process workout sessions
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        sessions.add({
          'id': doc.id,
          ...data,
        });

        if (data['total_duration_seconds'] != null) {
          totalDuration += data['total_duration_seconds'] as int;
        }

        if (data['calories_burned'] != null) {
          totalCalories += data['calories_burned'] as int;
        }
      }

      // Calculate workout streak
      streakDays = _calculateWorkoutStreak(sessions);



      // // Calculate achievements
      // final achievements = _calculateAchievements(
      //   totalWorkouts: sessions.length,
      //   totalDuration: totalDuration,
      //   totalCalories: totalCalories,
      //   streakDays: streakDays,
      //   sessions: sessions,
      // );

      setState(() {
        _workoutSessions = sessions;
        // _totalWorkouts = sessions.length;
        _totalDuration = totalDuration;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workout data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculateWorkoutStreak(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0;

    // Sort sessions by date
    sessions.sort((a, b) {
      DateTime dateA = a['created_at'] is Timestamp
          ? (a['created_at'] as Timestamp).toDate()
          : DateTime.parse(a['created_at']);
      DateTime dateB = b['created_at'] is Timestamp
          ? (b['created_at'] as Timestamp).toDate()
          : DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA);
    });

    int streak = 0;
    DateTime? lastWorkoutDate;
    Set<String> workoutDates = {};

    for (var session in sessions) {
      DateTime workoutDate = session['created_at'] is Timestamp
          ? (session['created_at'] as Timestamp).toDate()
          : DateTime.parse(session['created_at']);

      // Format date as YYYY-MM-DD to group workouts by day
      String dateKey =
          "${workoutDate.year}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}";
      workoutDates.add(dateKey);
    }

    // Convert to sorted list of unique dates
    List<DateTime> uniqueDates = workoutDates
        .map((dateStr) => DateTime.parse(dateStr))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    if (uniqueDates.isEmpty) return 0;

    DateTime today = DateTime.now();
    DateTime currentDate = uniqueDates.first;

    // Check if streak is current (workout today or yesterday)
    Duration daysSinceLastWorkout = today.difference(currentDate);
    if (daysSinceLastWorkout.inDays > 1) {
      return 0; // Streak broken
    }

    streak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      Duration gap = uniqueDates[i - 1].difference(uniqueDates[i]);
      if (gap.inDays == 1) {
        streak++;
      } else {
        break; // Streak broken
      }
    }

    return streak;
  }

  void _loadTodayWorkout() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get a recommended workout for today
      // You can customize this logic based on user preferences, completed workouts, etc.
      final allWorkouts = _workoutService.getAllWorkouts();

      // For now, select a workout based on the day of week
      final dayOfWeek = DateTime.now().weekday;
      Workout selectedWorkout;

      switch (dayOfWeek) {
        case 1: // Monday - Start week strong
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.category == 'Strength',
            orElse: () => allWorkouts.first,
          );
          break;
        case 2: // Tuesday - Cardio
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.category == 'Cardio',
            orElse: () => allWorkouts.first,
          );
          break;
        case 3: // Wednesday - Core focus
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.category == 'Core',
            orElse: () => allWorkouts.first,
          );
          break;
        case 4: // Thursday - HIIT
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.category == 'HIIT',
            orElse: () => allWorkouts.first,
          );
          break;
        case 5: // Friday - Full body
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.name.contains('Full Body'),
            orElse: () => allWorkouts.first,
          );
          break;
        case 6: // Saturday - Fun workout
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.category == 'Cardio',
            orElse: () => allWorkouts.first,
          );
          break;
        default: // Sunday - Relaxing
          selectedWorkout = allWorkouts.firstWhere(
            (w) => w.category == 'Yoga',
            orElse: () => allWorkouts.first,
          );
      }

      setState(() {
        _todayWorkout = selectedWorkout;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading today\'s workout: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProgressData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get this week's workout data
      final DateTime now = DateTime.now();
      // Set time to 00:00:00 for start of day
      final DateTime startOfWeekDate = now.subtract(Duration(days: now.weekday - 1));
      final DateTime startOfWeek = DateTime(startOfWeekDate.year, startOfWeekDate.month, startOfWeekDate.day);
      // Set time to 23:59:59 for end of day
      final DateTime endOfWeekDate = startOfWeek.add(const Duration(days: 6));
      final DateTime endOfWeek = DateTime(endOfWeekDate.year, endOfWeekDate.month, endOfWeekDate.day, 23, 59, 59);

      print('DEBUG: Checking for workouts between: $startOfWeek and $endOfWeek');

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('workout_sessions')
          .where('user_id', isEqualTo: user.uid)
          .where('created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('created_at',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
          .get();

      print('DEBUG: Found ${snapshot.docs.length} workouts this week.');
      // Process workout sessions

      int totalWorkouts = snapshot.docs.length;
      int totalMinutes = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['total_duration_seconds'] != null) {
          totalMinutes += (data['total_duration_seconds'] as int) ~/ 60;
        }
      }

      if(!mounted) return;
      setState(() {
        _progressData = {
          'workouts': totalWorkouts,
          'minutes': totalMinutes,
        };
      });
    } catch (e) {
      print('Error loading progress data: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary600 = Color(0xFF2563eb);

    return Scaffold(
      backgroundColor: const Color(0xFFf9fafb),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Greeting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Ready to crush your goals?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  // Quick action button
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: primary600,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Main
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Today's Workout
                  const _SectionTitle("Today's Workout"),
                  const SizedBox(height: 8),
                  _isLoading
                      ? _LoadingWorkoutCard()
                      : _WorkoutCard(workout: _todayWorkout),

                  const SizedBox(height: 28),

                  // Progress Summary
                  const _SectionTitle("Progress Summary"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          color: const Color(0xFFDBEAFE),
                          iconBg: const Color(0xFFDBEAFE),
                          iconColor: const Color(0xFF2563eb),
                          icon: Icons.check_rounded,
                          label: "Workouts",
                          value: _progressData?['workouts']?.toString() ?? "0",
                          subLabel: "this week",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          color: const Color(0xFFD1FAE5),
                          iconBg: const Color(0xFFD1FAE5),
                          iconColor: const Color(0xFF16A34A),
                          icon: Icons.access_time_rounded,
                          label: "Time",
                          value: _progressData?['minutes']?.toString() ?? "0",
                          subLabel: "minutes",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Daily Tip
                  const _SectionTitle("Daily Tip"),
                  const SizedBox(height: 8),
                  _DailyTipCard(),
                ],
              ),
            ),

            // Bottom Navigation
            _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _LoadingWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black87,
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout? workout;

  const _WorkoutCard({this.workout});

  String _getMotivationalMessage() {
    final messages = [
      "Get ready to feel the burn!",
      "Time to crush this workout!",
      "Your body will thank you later!",
      "Let's make today count!",
      "Strong minds, strong bodies!",
      "Push your limits today!",
    ];
    return messages[DateTime.now().day % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const SizedBox(
          height: 250,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No workout available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Image part
            Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(
                  image: NetworkImage(
                    workout!.heroImageUrl ??
                        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${workout!.actualTotalDuration ~/ 60} min · ${workout!.exercises.length} exercises",
                          style: const TextStyle(
                            color: Color(0xFFe5e7eb),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Description & Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      // View Details Button
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WorkoutDetailScreen(
                                workoutId: workout!.id,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          side: const BorderSide(color: Color(0xFF2563eb)),
                        ),
                        child: const Text(
                          "Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563eb),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Start Button
                      ElevatedButton.icon(
                        onPressed: () {
                          // Start workout directly
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WorkoutFlowScreen(
                                workoutTitle: workout!.name,
                                exercises: workout!.exercises
                                    .map((exercise) => WorkoutExercise(
                                          name: exercise.name,
                                          type: exercise.type,
                                          duration: exercise.duration,
                                          reps: exercise.duration,
                                          imageUrl: exercise.videoUrl ??
                                              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded,
                            size: 20, color: Colors.white),
                        label: const Text("Start",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563eb),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
  final String subLabel;

  const _StatCard({
    required this.color,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2))
        ],
        border: Border.all(color: const Color(0x0F000000)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                padding: const EdgeInsets.all(7),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2),
          ),
          Text(subLabel,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  final List<Map<String, String>> _tips = [
    {
      'title': 'Hydration is Key',
      'content':
          'Drink plenty of water throughout the day to stay energized and aid recovery.',
    },
    {
      'title': 'Proper Form First',
      'content':
          'Focus on correct technique rather than speed. Quality over quantity always wins.',
    },
    {
      'title': 'Rest is Growth',
      'content':
          'Your muscles grow during rest, not during workouts. Get adequate sleep tonight.',
    },
    {
      'title': 'Consistency Beats Perfection',
      'content':
          'A 15-minute workout is better than no workout. Small steps lead to big changes.',
    },
    {
      'title': 'Fuel Your Body',
      'content':
          'Eat a balanced meal with protein and carbs within 2 hours after your workout.',
    },
    {
      'title': 'Listen to Your Body',
      'content':
          'If something hurts, stop. Pain is different from muscle fatigue - know the difference.',
    },
    {
      'title': 'Warm Up Always',
      'content':
          'Spend 5-10 minutes warming up to prepare your body and prevent injuries.',
    },
  ];

  String _getTodayTip() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _tips[dayOfYear % _tips.length]['title']!;
  }

  String _getTodayTipContent() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _tips[dayOfYear % _tips.length]['content']!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFeff6ff), Color(0xFFede9fe)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTodayTip(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  _getTodayTipContent(),
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                )
              ],
            ),
          ),
          // Tip icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Color(0xFF2563eb),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

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
            selected: true,
            onTap: () {
              // Already on home screen
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
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const NofapScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
