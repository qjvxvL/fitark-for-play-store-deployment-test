import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class WorkoutSession extends StatefulWidget {
  final Workout workout;

  const WorkoutSession({super.key, required this.workout});

  @override
  _WorkoutSessionState createState() => _WorkoutSessionState();
}

class _WorkoutSessionState extends State<WorkoutSession> {
  late Timer _timer;
  int _currentExerciseIndex = 0;
  int _secondsLeft = 0;
  bool _isResting = false;
  final int _restDuration = 10;

  @override
  void initState() {
    super.initState();
    _startCurrentExercise();
  }

  void _startCurrentExercise() {
    if (_currentExerciseIndex >= widget.workout.exercises.length) {
      _completeWorkout();
      return;
    }

    final exercise = widget.workout.exercises[_currentExerciseIndex];
    _secondsLeft = exercise.duration!;
    _isResting = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        _timer.cancel();
        _startRest();
      }
    });
  }

  void _startRest() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      _secondsLeft = _restDuration;
      _isResting = true;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsLeft--;
        });

        if (_secondsLeft <= 0) {
          _timer.cancel();
          _currentExerciseIndex++;
          _startCurrentExercise();
        }
      });
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCompleteScreen(workout: widget.workout),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise =
        _currentExerciseIndex < widget.workout.exercises.length
            ? widget.workout.exercises[_currentExerciseIndex]
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (currentExercise != null) ...[
              if (_isResting)
                _buildRestScreen()
              else
                _buildExerciseScreen(currentExercise),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseScreen(Exercise exercise) {
    return Expanded(
      child: Column(
        children: [
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              child: const Icon(Icons.fitness_center,
                  size: 100), // Placeholder for Lottie
            ),
          ),
          const SizedBox(height: 20),
          Text(
            exercise.instruction,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            '$_secondsLeft',
            style: const TextStyle(
                fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const Text('seconds left',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.self_improvement, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Rest Time',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            '$_secondsLeft',
            style: const TextStyle(
                fontSize: 72, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const Text('seconds left',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class WorkoutCompleteScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutCompleteScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 100, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Workout Complete!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
