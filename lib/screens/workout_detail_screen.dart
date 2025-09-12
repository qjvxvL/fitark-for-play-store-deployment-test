import 'package:fitark/models/exercise.dart';
import 'package:fitark/screens/workout_flow_screen.dart';
import 'package:fitark/widgets/exercise_animation.dart';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutId; // Change to use workout ID instead of hardcoded data

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final WorkoutService _workoutService = WorkoutService();
  Workout? workout;

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  void _loadWorkout() {
    workout = _workoutService.getWorkoutById(widget.workoutId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Hero Image Section
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(workout!.heroImageUrl ??
                          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite_border,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          workout!.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout!.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoChip(
                                '${workout!.totalExercises} exercises'),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                                '${workout!.actualTotalDuration ~/ 60} min'),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                                '${workout!.estimatedCaloriesWithDifficulty} cal'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Exercises Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercises (${workout!.exercises.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workout!.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = workout!.exercises[index];
                        return _ExerciseCard(
                          exercise: exercise,
                          index: index + 1,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _WorkoutStartNavBar(workout: workout!),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Update your _ExerciseCard class

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Exercise number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Exercise animation preview
          SizedBox(
            width: 60,
            height: 60,
            child: ExerciseAnimation(
              exerciseType: _mapExerciseNameToType(exercise.name),
              isPlaying: true,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(width: 16),

          // Exercise details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.formattedDuration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.instruction,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Play button
          IconButton(
            onPressed: () {
              _showAnimationPreview(context, exercise);
            },
            icon: const Icon(Icons.play_circle_outline),
          ),
        ],
      ),
    );
  }

  String _mapExerciseNameToType(String exerciseName) {
    // Map your exercise names to the animation types
    final exerciseMap = {
      'Push-ups': 'push-ups',
      'Wide Arm Push-ups': 'push-ups',
      'Push Up': 'push-ups',
      'Squats': 'squats',
      'Jumping Jacks': 'jumping jacks',
      'Plank': 'plank',
      'Mountain Climbers': 'mountain climbers',
      'Burpees': 'burpees',
      'Free Inchworm': 'Free Inchworm',
    };

    return exerciseMap[exerciseName] ?? exerciseName.toLowerCase();
  }

  void _showAnimationPreview(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ExerciseAnimation(
                exerciseType: _mapExerciseNameToType(exercise.name),
                isPlaying: true,
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 20),
              Text(
                exercise.instruction,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutStartNavBar extends StatelessWidget {
  final Workout workout;

  const _WorkoutStartNavBar({required this.workout});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutFlowScreen(
                    workoutTitle: workout.name,
                    exercises: workout.exercises
                        .map((exercise) => WorkoutExercise(
                              name: exercise.name,
                              type: exercise.type,
                              reps: exercise
                                  .duration, // Using duration as reps for now
                              imageUrl: exercise.videoUrl ??
                                  'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
                            ))
                        .toList(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Start Workout'),
          ),
        ),
      ),
    );
  }
}
