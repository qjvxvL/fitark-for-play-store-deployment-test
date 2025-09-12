import 'package:equatable/equatable.dart';
import 'exercise.dart';

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

class Workout extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<Exercise>
      exercises; // This will contain different exercises per workout
  final DifficultyLevel difficulty;
  final String imageAsset;
  final String category;
  final List<String> tags;
  final String? heroImageUrl; // Add hero image for workout detail screen

  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.difficulty,
    this.imageAsset = '',
    required this.category,
    this.tags = const [],
    this.heroImageUrl,
  });

  // Computed properties
  int get actualTotalDuration =>
      exercises.fold(0, (sum, exercise) => sum + (exercise.duration ?? 0));
  int get actualEstimatedCalories =>
      exercises.fold(0, (sum, exercise) => sum + exercise.calories);
  int get totalExercises => exercises.length;

  // Calculate difficulty multiplier for calories
  double get difficultyMultiplier {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 1.0;
      case DifficultyLevel.intermediate:
        return 1.2;
      case DifficultyLevel.advanced:
        return 1.5;
    }
  }

  // Get estimated calories with difficulty multiplier
  int get estimatedCaloriesWithDifficulty =>
      (actualEstimatedCalories * difficultyMultiplier).round();

  // Create a copy with modifications
  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<Exercise>? exercises,
    DifficultyLevel? difficulty,
    String? imageAsset,
    String? category,
    List<String>? tags,
    String? heroImageUrl,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      difficulty: difficulty ?? this.difficulty,
      imageAsset: imageAsset ?? this.imageAsset,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'difficulty': difficulty.name,
      'imageAsset': imageAsset,
      'category': category,
      'tags': tags,
      'heroImageUrl': heroImageUrl,
    };
  }

  // Create from JSON
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      imageAsset: json['imageAsset'] as String? ?? '',
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      heroImageUrl: json['heroImageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        exercises,
        difficulty,
        imageAsset,
        category,
        tags,
        heroImageUrl,
      ];

  @override
  String toString() {
    return 'Workout(id: $id, name: $name, exercises: ${exercises.length}, difficulty: $difficulty)';
  }
}

// Workout session for tracking completed workouts
class WorkoutSession extends Equatable {
  final String id;
  final String workoutId;
  final DateTime startTime;
  final DateTime? endTime;
  final int caloriesBurned;
  final List<ExerciseProgress> exerciseProgress;
  final bool completed;

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.startTime,
    this.endTime,
    required this.caloriesBurned,
    required this.exerciseProgress,
    required this.completed,
  });

  // Computed properties
  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return Duration.zero;
  }

  int get completedExercises =>
      exerciseProgress.where((p) => !p.skipped).length;

  int get skippedExercises => exerciseProgress.where((p) => p.skipped).length;

  double get completionRate {
    if (exerciseProgress.isEmpty) return 0.0;
    return completedExercises / exerciseProgress.length;
  }

  // Create a copy with modifications
  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    DateTime? startTime,
    DateTime? endTime,
    int? caloriesBurned,
    List<ExerciseProgress>? exerciseProgress,
    bool? completed,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exerciseProgress: exerciseProgress ?? this.exerciseProgress,
      completed: completed ?? this.completed,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'caloriesBurned': caloriesBurned,
      'exerciseProgress': exerciseProgress.map((e) => e.toJson()).toList(),
      'completed': completed,
    };
  }

  // Create from JSON
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      caloriesBurned: json['caloriesBurned'] as int,
      exerciseProgress: (json['exerciseProgress'] as List)
          .map((e) => ExerciseProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      completed: json['completed'] as bool,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        startTime,
        endTime,
        caloriesBurned,
        exerciseProgress,
        completed,
      ];

  @override
  String toString() {
    return 'WorkoutSession(id: $id, workoutId: $workoutId, completed: $completed)';
  }
}

// Exercise progress tracking
class ExerciseProgress extends Equatable {
  final String exerciseId;
  final int completedDuration;
  final bool skipped;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  const ExerciseProgress({
    required this.exerciseId,
    required this.completedDuration,
    required this.skipped,
    required this.timestamp,
    this.additionalData,
  });

  // Create a copy with modifications
  ExerciseProgress copyWith({
    String? exerciseId,
    int? completedDuration,
    bool? skipped,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return ExerciseProgress(
      exerciseId: exerciseId ?? this.exerciseId,
      completedDuration: completedDuration ?? this.completedDuration,
      skipped: skipped ?? this.skipped,
      timestamp: timestamp ?? this.timestamp,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'completedDuration': completedDuration,
      'skipped': skipped,
      'timestamp': timestamp.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  // Create from JSON
  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    return ExerciseProgress(
      exerciseId: json['exerciseId'] as String,
      completedDuration: json['completedDuration'] as int,
      skipped: json['skipped'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        exerciseId,
        completedDuration,
        skipped,
        timestamp,
        additionalData,
      ];

  @override
  String toString() {
    return 'ExerciseProgress(exerciseId: $exerciseId, completed: $completedDuration, skipped: $skipped)';
  }
}
