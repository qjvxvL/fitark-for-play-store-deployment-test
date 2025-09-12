import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'nofap_screen.dart';
import 'workout_list_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  List<Map<String, dynamic>> _workoutSessions = [];
  bool _isLoading = true;
  int _totalWorkouts = 0;
  int _totalDuration = 0;
  List<Map<String, dynamic>> _achievements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

      // Calculate achievements
      final achievements = _calculateAchievements(
        totalWorkouts: sessions.length,
        totalDuration: totalDuration,
        totalCalories: totalCalories,
        streakDays: streakDays,
        sessions: sessions,
      );

      setState(() {
        _workoutSessions = sessions;
        _totalWorkouts = sessions.length;
        _totalDuration = totalDuration;
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workout data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _calculateWeeklyChange(List<FlSpot> spots) {
    if (spots.length < 4) return '+0%';

    // spots[3] is this week's workout count
    // spots[2] is last week's workout count
    final thisWeekWorkouts = spots[3].y;
    final lastWeekWorkouts = spots[2].y;

    if (lastWeekWorkouts == 0) {
      if (thisWeekWorkouts > 0) {
        return '+${(thisWeekWorkouts * 100).toInt()}%'; // Or just show a big increase icon
      }
      return '+0%'; // No change from zero
    }

    final double percentageChange =
        ((thisWeekWorkouts - lastWeekWorkouts) / lastWeekWorkouts) * 100;

    if (percentageChange > 0) {
      return '+${percentageChange.toStringAsFixed(0)}%';
    } else {
      return '${percentageChange.toStringAsFixed(0)}%';
    }
  }

  List<FlSpot> _generateChartData() {
    if (_workoutSessions.isEmpty) {
      // Return empty data if there are no workouts
      return [
        const FlSpot(0, 0),
        const FlSpot(1, 0),
        const FlSpot(2, 0),
        const FlSpot(3, 0),
      ];
    }

    final now = DateTime.now();
    // We'll create 4 buckets for the last 4 weeks.
    // weeklyCounts[0] = this week, [1] = last week, etc.
    final weeklyCounts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};

    for (var session in _workoutSessions) {
      DateTime sessionDate;
      if (session['created_at'] is Timestamp) {
        sessionDate = (session['created_at'] as Timestamp).toDate();
      } else {
        // Add handling for string dates if necessary
        continue;
      }

      final daysAgo = now.difference(sessionDate).inDays;

      // Check if the workout is within the last 28 days (4 weeks)
      if (daysAgo >= 0 && daysAgo < 28) {
        // Determine which week bucket it falls into
        final weekIndex = daysAgo ~/ 7; // Integer division
        weeklyCounts[weekIndex] = (weeklyCounts[weekIndex] ?? 0) + 1;
      }
    }

    // The chart expects spots from left to right (oldest to newest).
    // Our weeklyCounts are newest to oldest. So, we reverse them for the chart.
    // Spot(0, workouts_3_weeks_ago), Spot(1, workouts_2_weeks_ago), ...
    final List<FlSpot> spots = [];
    for (int i = 0; i < 4; i++) {
      // Week 3 is the oldest, Week 0 is the newest.
      // Chart X-axis 0 should be the oldest data.
      int weekKey = 3 - i;
      spots.add(FlSpot(i.toDouble(), (weeklyCounts[weekKey] ?? 0).toDouble()));
    }

    return spots;
  }



  // Calculate workout streak
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

  // Calculate achievements based on workout data
  List<Map<String, dynamic>> _calculateAchievements({
    required int totalWorkouts,
    required int totalDuration,
    required int totalCalories,
    required int streakDays,
    required List<Map<String, dynamic>> sessions,
  }) {
    // Calculate additional metrics
    int totalHours = (totalDuration / 3600).floor();
    int completedWorkouts = sessions
        .where((s) =>
            s['status'] == 'completed' ||
            s['completed_exercises'] == s['total_exercises'])
        .length;

    // Get workout categories
    Map<String, int> categoryCount = {};
    for (var session in sessions) {
      String category = session['workout_category'] ?? 'General';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return [
      {
        'id': 'first_workout',
        'title': 'First Steps',
        'description': 'Complete your first workout',
        'threshold': 1,
        'current': totalWorkouts,
        'icon': Icons.star,
        'color': const Color(0xFFFBBF24),
        'unlocked': totalWorkouts >= 1,
        'category': 'milestone',
      },
      {
        'id': 'workout_5',
        'title': 'Getting Started',
        'description': 'Complete 5 workouts',
        'threshold': 5,
        'current': totalWorkouts,
        'icon': Icons.fitness_center,
        'color': const Color(0xFF0EA5E9),
        'unlocked': totalWorkouts >= 5,
        'category': 'milestone',
      },
      {
        'id': 'workout_10',
        'title': 'Committed',
        'description': 'Complete 10 workouts',
        'threshold': 10,
        'current': totalWorkouts,
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFEF4444),
        'unlocked': totalWorkouts >= 10,
        'category': 'milestone',
      },
      {
        'id': 'workout_25',
        'title': 'Dedicated',
        'description': 'Complete 25 workouts',
        'threshold': 25,
        'current': totalWorkouts,
        'icon': Icons.military_tech,
        'color': const Color(0xFF8B5CF6),
        'unlocked': totalWorkouts >= 25,
        'category': 'milestone',
      },
      {
        'id': 'workout_50',
        'title': 'Fitness Enthusiast',
        'description': 'Complete 50 workouts',
        'threshold': 50,
        'current': totalWorkouts,
        'icon': Icons.emoji_events,
        'color': const Color(0xFFEAB308),
        'unlocked': totalWorkouts >= 50,
        'category': 'milestone',
      },
      {
        'id': 'streak_3',
        'title': 'On Fire',
        'description': 'Workout 3 days in a row',
        'threshold': 3,
        'current': streakDays,
        'icon': Icons.whatshot,
        'color': const Color(0xFFFF6B35),
        'unlocked': streakDays >= 3,
        'category': 'streak',
      },
      {
        'id': 'streak_7',
        'title': 'Week Warrior',
        'description': 'Workout 7 days in a row',
        'threshold': 7,
        'current': streakDays,
        'icon': Icons.shield,
        'color': const Color(0xFF10B981),
        'unlocked': streakDays >= 7,
        'category': 'streak',
      },
      {
        'id': 'time_5h',
        'title': 'Time Keeper',
        'description': 'Exercise for 5 hours total',
        'threshold': 5,
        'current': totalHours,
        'icon': Icons.timer,
        'color': const Color(0xFF06B6D4),
        'unlocked': totalHours >= 5,
        'category': 'duration',
      },
      {
        'id': 'time_10h',
        'title': 'Endurance Master',
        'description': 'Exercise for 10 hours total',
        'threshold': 10,
        'current': totalHours,
        'icon': Icons.access_time,
        'color': const Color(0xFF8B5CF6),
        'unlocked': totalHours >= 10,
        'category': 'duration',
      },
      {
        'id': 'calories_1000',
        'title': 'Calorie Burner',
        'description': 'Burn 1000 calories total',
        'threshold': 1000,
        'current': totalCalories,
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFEF4444),
        'unlocked': totalCalories >= 1000,
        'category': 'calories',
      },
      {
        'id': 'cardio_specialist',
        'title': 'Cardio Specialist',
        'description': 'Complete 10 cardio workouts',
        'threshold': 10,
        'current': categoryCount['Cardio'] ?? 0,
        'icon': Icons.favorite,
        'color': const Color(0xFFEC4899),
        'unlocked': (categoryCount['Cardio'] ?? 0) >= 10,
        'category': 'specialty',
      },
      {
        'id': 'strength_builder',
        'title': 'Strength Builder',
        'description': 'Complete 10 strength Workouts',
        'threshold': 10,
        'current': categoryCount['Strength'] ?? 0,
        'icon': Icons.fitness_center,
        'color': const Color(0xFF059669),
        'unlocked': (categoryCount['Strength'] ?? 0) >= 10,
        'category': 'specialty',
      },
    ];
  }

  String _formatTotalDuration() {
    int hours = _totalDuration ~/ 3600;
    int minutes = (_totalDuration % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  List<int> _getWorkoutDaysForMonth(DateTime month) {
    return _workoutSessions.where((session) {
      if (session['created_at'] == null) return false;

      DateTime sessionDate;
      if (session['created_at'] is Timestamp) {
        sessionDate = (session['created_at'] as Timestamp).toDate();
      } else if (session['created_at'] is String) {
        sessionDate = DateTime.parse(session['created_at']);
      } else {
        return false;
      }

      return sessionDate.year == month.year && sessionDate.month == month.month;
    }).map((session) {
      DateTime sessionDate;
      if (session['created_at'] is Timestamp) {
        sessionDate = (session['created_at'] as Timestamp).toDate();
      } else {
        sessionDate = DateTime.parse(session['created_at']);
      }
      return sessionDate.day;
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) :TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildWorkoutsTab(),
                  _buildBadgesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          const Expanded(
            child: Text(
              'Progress',
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFB2CBE5),
        indicatorWeight: 3,
        labelColor: const Color(0xFF101418),
        unselectedLabelColor: const Color(0xFF5C728A),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Workouts'),
          Tab(text: 'Badges'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityHistory(),
          const SizedBox(height: 32),
          _buildAchievements(),
          const SizedBox(height: 32),
          _buildProgressChart(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActivityHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity History',
          style: TextStyle(
            color: Color(0xFF101418),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.36,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildCalendarHeader(),
              const SizedBox(height: 16),
              _buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            });
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          _getMonthYearString(_selectedMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101418),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              );
            });
          },
          icon: const Icon(
            Icons.chevron_right,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Color(0xFF5C728A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        _buildCalendarDays(),
      ],
    );
  }

  Widget _buildCalendarDays() {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
    final workoutDays =
        _getWorkoutDaysForMonth(_selectedMonth); // Use real data
    final today = DateTime.now();

    // Rest of the method stays the same...
    List<Widget> dayWidgets = [];

    for (int i = 0; i < firstWeekday % 7; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isWorkoutDay = workoutDays.contains(day);
      final isToday = _selectedMonth.year == today.year &&
          _selectedMonth.month == today.month &&
          day == today.day;

      dayWidgets.add(
        Expanded(
          child: Container(
            height: 32,
            margin: const EdgeInsets.all(2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isToday)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(78, 113, 255, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                ),
                if (isWorkoutDay && !isToday)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(78, 113, 255, 1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildAchievements() {
    // Filter unlocked achievements first, then locked ones
    final unlockedAchievements =
        _achievements.where((a) => a['unlocked'] == true).toList();
    final lockedAchievements =
        _achievements.where((a) => a['unlocked'] == false).toList();
    final displayAchievements = [
      ...unlockedAchievements,
      ...lockedAchievements.take(3)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.36,
              ),
            ),
            Text(
              '${unlockedAchievements.length}/${_achievements.length}',
              style: const TextStyle(
                color: Color(0xFF5C728A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayAchievements.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildAchievementCard(displayAchievements[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final bool isUnlocked = achievement['unlocked'] ?? false;
    final int current = achievement['current'] ?? 0;
    final int threshold = achievement['threshold'] ?? 1;
    final double progress = (current / threshold).clamp(0.0, 1.0);

    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Container(
            width: 160,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isUnlocked ? achievement['color'] : Colors.grey[300],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  achievement['icon'],
                  size: 48,
                  color: isUnlocked ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(height: 8),
                if (!isUnlocked) ...[
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: achievement['color'],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$current/$threshold',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement['title'],
            style: TextStyle(
              color: isUnlocked ? const Color(0xFF101418) : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement['description'],
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget _buildPersonalBests() {
  //   final personalBests = [
  //     {
  //       'title': 'Push-ups',
  //       'value': '100 reps',
  //       'icon': Icons.local_fire_department,
  //       'color': const Color(0xFFFBBF24),
  //     },
  //     {
  //       'title': 'Pull-ups',
  //       'value': '50 reps',
  //       'icon': Icons.fitness_center,
  //       'color': const Color(0xFF0EA5E9),
  //     },
  //     {
  //       'title': 'Squats',
  //       'value': '200 reps',
  //       'icon': Icons.airline_seat_legroom_extra,
  //       'color': const Color(0xFF84CC16),
  //     },
  //   ];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Personal Bests',
  //         style: TextStyle(
  //           color: Color(0xFF101418),
  //           fontSize: 24,
  //           fontWeight: FontWeight.bold,
  //           letterSpacing: -0.36,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       Column(
  //         children: personalBests
  //             .map((best) => _buildPersonalBestCard(best))
  //             .toList(),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPersonalBestCard(Map<String, dynamic> best) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: best['color'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              best['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  best['title'],
                  style: const TextStyle(
                    color: Color(0xFF101418),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  best['value'],
                  style: const TextStyle(
                    color: Color(0xFF5C728A),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    // 1. Generate the data for the chart
    final chartSpots = _generateChartData();
    final weeklyChange = _calculateWeeklyChange(chartSpots);

    // 2. Determine the maximum Y value for better chart scaling
    double maxY = 5; // A default minimum height for the chart
    if (chartSpots.isNotEmpty) {
      final maxWorkouts = chartSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      if (maxWorkouts > 4) {
        maxY = maxWorkouts + 2; // Add some padding
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Over Time',
          style: TextStyle(
            color: Color(0xFF101418),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.36,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Frequency',
                style: TextStyle(
                  color: Color(0xFF101418),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Last 4 Weeks', // Updated from "30 Days" to match data
                    style: TextStyle(
                      color: Color(0xFF5C728A),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 3. Use the dynamic weeklyChange data
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: weeklyChange.startsWith('+')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          weeklyChange.startsWith('+') ? Icons.trending_up : Icons.trending_down,
                          color: weeklyChange.startsWith('+') ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        Text(
                          weeklyChange,
                          style: TextStyle(
                            color: weeklyChange.startsWith('+') ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    // 4. Use the dynamic maxY value
                    maxY: maxY,
                    minY: 0,
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            // These labels correspond to the chartSpots index
                            const weeks = ['W1', 'W2', 'W3', 'W4'];
                            if (value.toInt() >= 0 &&
                                value.toInt() < weeks.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  weeks[value.toInt()],
                                  style: const TextStyle(
                                    color: Color(0xFF5C728A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        // 5. Use the dynamic chartSpots data
                        spots: chartSpots,
                        isCurved: true,
                        color: const Color.fromRGBO(141, 216, 255, 1),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFB2CBE5).withOpacity(0.2),
                        ),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Workouts',
                  _totalWorkouts.toString(),
                  Icons.fitness_center,
                  const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Time',
                  _formatTotalDuration(),
                  Icons.timer,
                  const Color(0xFF84CC16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Workout history
          const Text(
            'Recent Workouts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101418),
            ),
          ),
          const SizedBox(height: 16),

          if (_workoutSessions.isEmpty)
            const Center(
              child: Text(
                'No workouts recorded yet.\nStart your first workout!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5C728A),
                  fontSize: 16,
                ),
              ),
            )
          else
            ...(_workoutSessions
                .take(10)
                .map((session) => _buildWorkoutCard(session))),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF5C728A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF101418),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> session) {
    DateTime workoutDate;
    if (session['created_at'] is Timestamp) {
      workoutDate = (session['created_at'] as Timestamp).toDate();
    } else if (session['created_at'] is String) {
      workoutDate = DateTime.parse(session['created_at']);
    } else {
      workoutDate = DateTime.now();
    }

    final duration = session['total_duration_seconds'] ?? 0;
    final durationText =
        duration > 0 ? '${(duration / 60).round()}m' : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFB2CBE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['workout_title'] ?? 'Workout',
                  style: const TextStyle(
                    color: Color(0xFF101418),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session['completed_exercises']}/${session['total_exercises']} exercises • $durationText',
                  style: const TextStyle(
                    color: Color(0xFF5C728A),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${workoutDate.day}/${workoutDate.month}',
            style: const TextStyle(
              color: Color(0xFF5C728A),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group achievements by category
    Map<String, List<Map<String, dynamic>>> groupedAchievements = {};
    for (var achievement in _achievements) {
      String category = achievement['category'] ?? 'general';
      if (!groupedAchievements.containsKey(category)) {
        groupedAchievements[category] = [];
      }
      groupedAchievements[category]!.add(achievement);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  widthFactor: 1,
                  child: Column(
                    children: [
                      Text(
                        _achievements
                            .where((a) => a['unlocked'] == true)
                            .length
                            .toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101418),
                        ),
                      ),
                      const Text(
                        'Unlocked',
                        style: TextStyle(
                          color: Color(0xFF5C728A),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    transformAlignment: Alignment.center,
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                ),
                Center(
                  widthFactor: 1.5,
                  child: Column(
                    children: [
                      Text(
                        _achievements.length.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101418),
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF5C728A),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Achievement categories
          ...groupedAchievements.entries.map((entry) {
            String categoryName = entry.key;
            List<Map<String, dynamic>> categoryAchievements = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryTitle(categoryName),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categoryAchievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(categoryAchievements[index]);
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'milestone':
        return 'Milestones';
      case 'streak':
        return 'Streaks';
      case 'duration':
        return 'Time-based';
      case 'calories':
        return 'Calorie Burning';
      case 'specialty':
        return 'Specializations';
      default:
        return 'General';
    }
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
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
            selected: false,
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
            selected: true,

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
