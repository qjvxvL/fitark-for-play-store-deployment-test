import 'dart:async';

import 'package:fitark/screens/rest_screen.dart';
import 'package:fitark/screens/workout_list_screen.dart';
import 'package:fitark/widgets/exercise_animation.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/exercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutFlowScreen extends StatefulWidget {
  final String workoutTitle;
  final List<WorkoutExercise> exercises;

  const WorkoutFlowScreen({
    super.key,
    required this.workoutTitle,
    required this.exercises,
  });

  @override
  State<WorkoutFlowScreen> createState() => _WorkoutFlowScreenState();
}

class _WorkoutFlowScreenState extends State<WorkoutFlowScreen>
    with TickerProviderStateMixin {
  int currentExerciseIndex = 0;
  bool isPlaying = false;
  late int currentTime;
  late AnimationController _timerController;

  DateTime? _workoutStartTime;
  DateTime? _workoutEndTime;
  int _totalWorkoutDuration = 0;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();

    _startWorkoutSession();

    _timerController = AnimationController(
      vsync: this,
    );

    _timerController.addListener(() {
      if (currentExercise.type == MeasurementType.time) {
        final newTime = currentExercise.duration! -
            (_timerController.value * currentExercise.duration!).round();
        if (currentTime != newTime) {
          setState(() {
            currentTime = newTime;
          });
        }
      }
    });

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextExercise();
      }
    });

    _setupExercise();
  }

  void _startWorkoutSession() {
    _workoutStartTime = DateTime.now();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _totalWorkoutDuration++;
      });
    });
  }

  void _endWorkoutSession() {
    _workoutEndTime = DateTime.now();
    _sessionTimer?.cancel();

    // Send workout session data to backend
    _sendWorkoutDataToBackend();
  }

  Future<void> _sendWorkoutDataToBackend() async {
    final workoutData = {
      'workout_title': widget.workoutTitle,
      'start_time': _workoutStartTime?.toIso8601String(),
      'end_time': _workoutEndTime?.toIso8601String(),
      'total_duration_seconds': _totalWorkoutDuration,
      'total_exercises': widget.exercises.length,
      'completed_exercises': currentExerciseIndex + 1,
      'exercises_completed': widget.exercises.take(currentExerciseIndex + 1).map((e) => {
        'name': e.name,
        'reps': e.reps,
        'duration': e.duration,
      }).toList(),
      'created_at': FieldValue.serverTimestamp(),
      'user_id': FirebaseAuth.instance.currentUser?.uid,
    };

    // TODO: Replace with your actual API call
    print('Workout Session Data: $workoutData');

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('workout_sessions')
          .add(workoutData);

      print('Workout data saved to Firebase successfully');
    } catch (e) {
      print('Error saving workout data to Firebase: $e');
      // Optionally show a snackbar or dialog to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save workout data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatWorkoutDuration() {
    int hours = _totalWorkoutDuration ~/ 3600;
    int minutes = (_totalWorkoutDuration % 3600) ~/ 60;
    int seconds = _totalWorkoutDuration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }



  void _setupExercise() {
    setState(() {
      isPlaying = false;
      if (_isTimeBased) {
        currentTime = currentExercise.duration!;
        _timerController.duration =
            Duration(seconds: currentExercise.duration!);
      } else {
        currentTime = 0;
        _timerController.duration = const Duration(seconds: 1);
      }
      _timerController.reset();
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      _timerController.forward();
    } else {
      _timerController.stop();

    }
  }

  void _navigateToRestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RestScreen(),
      ),
    );
  }

  void _completeExercise() {
    _timerController.stop();

    // Check if this is the last exercise
    if (currentExerciseIndex < widget.exercises.length - 1) {
      // Navigate to rest screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RestScreen(),
        ),
      ).then((_) {
        // When returning from rest screen, go to next exercise
        _nextExercise();
      });
    } else {
      // This is the last exercise, show completion dialog
      _showWorkoutCompletedDialog();
    }
  }

  double get workoutProgress {
    return (currentExerciseIndex + 1) / widget.exercises.length;
  }

  WorkoutExercise get currentExercise {
    // Add safety check
    if (currentExerciseIndex >= widget.exercises.length) {
      return widget.exercises.last;
    }
    return widget.exercises[currentExerciseIndex];
  }

  bool get _isTimeBased {
    return currentExercise.duration != null && currentExercise.duration! > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: Stack(

        children: [
          // Header
          _buildExerciseInfoOverlay(),
          _buildHeader(),
          _buildExerciseInfo(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 8, // Tiny height
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: workoutProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // // Close Button
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInfo() {
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => _BackConfirmationDialog(onConfirmExit: _endWorkoutSession,
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentExerciseIndex + 1}/${widget.exercises.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

// Update your _buildExerciseInfoOverlay method
  Widget _buildExerciseInfoOverlay() {
    return Positioned(
      bottom: 105,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1)),
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Exercise Animation
            Center(
              child: ExerciseAnimation(
                exerciseType: currentExercise.name,
                isPlaying: true,
                width: 400,
                height: 400,

              ),
            ),
            const SizedBox(height: 20),
            // Exercise Name
            Text(
              currentExercise.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Repetitions
            Text(
              'x${currentExercise.reps}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(50, 101, 252, 1),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                _buildControlButton(
                  icon: Icons.arrow_back,
                  label: 'Previous',
                  onTap: _previousExercise,
                  enabled: currentExerciseIndex > 0,
                ),

                // Play/Pause Button
                GestureDetector(
                  onTap: _completeExercise,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.done,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                ),

                // Next Button
                _buildControlButton(
                  icon: Icons.arrow_forward,
                  label: 'Next',
                  onTap: _nextExercise,
                  enabled: currentExerciseIndex < widget.exercises.length - 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back) ...[
              Icon(
                icon,
                size: 20,
                color: enabled ? Colors.grey[700] : Colors.grey[400],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
            if (icon == Icons.arrow_forward) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 20,
                color: enabled ? Colors.grey[700] : Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
        currentTime = 0;
        isPlaying = false;
      });
      _timerController.reset();
    }
  }

  void _nextExercise() {
    if (currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        currentTime = 0;
        isPlaying = false;
      });
      _timerController.reset();
    } else {
      // Workout completed
      _showWorkoutCompletedDialog();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showWorkoutCompletedDialog() {
    _endWorkoutSession(); // End session when workout completes

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Workout Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Great job! You\'ve finished your workout session.'),
            const SizedBox(height: 8),
            Text('Total time: ${_formatWorkoutDuration()}'),
            Text('Exercises completed: ${widget.exercises.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Data model for workout exercises
class WorkoutExercise {
  final String name;
  final int? reps;
  final String imageUrl;
  final ExerciseType? type; // This now uses the imported ExerciseType
  final int? duration;

  const WorkoutExercise({
    required this.name,
    this.reps,
    required this.imageUrl,
    this.type,
    this.duration,
  });
}

// Update your measurement type enum to avoid conflicts:
enum MeasurementType {
  time,
  reps,
}

class _BackConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirmExit;

  const _BackConfirmationDialog({required this.onConfirmExit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.home,
            color: Color(0xFF2563eb),
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Go to Home?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293b),
            ),
          )
        ],
      ),
      content: const Text(
        'Do you really want to give up your workout?',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF64748b),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'No, I change my mind',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirmExit(); // Call the callback to end session
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const WorkoutListScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563eb),
          ),
          child: const Text(
            'Yes, Go Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }
}

// Example usage - you can call this screen like:
/*
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WorkoutFlowScreen(
      workoutTitle: 'Morning Cardio Blast',
      exercises: [
        WorkoutExercise(
          name: 'Push-ups',
          reps: 10,
          imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        ),
        WorkoutExercise(
          name: 'Squats',
          reps: 15,
          imageUrl: 'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        ),
        // Add more exercises...
      ],
    ),
  ),
);
*/
