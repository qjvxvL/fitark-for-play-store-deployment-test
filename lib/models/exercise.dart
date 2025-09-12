import 'package:equatable/equatable.dart';
import '../models/workout.dart'; // Import the DifficultyLevel enum from workout.dart

enum ExerciseType {
  cardio,
  strength,
  flexibility,
  balance,
  endurance,
}

enum MeasurementType {
  reps,
  time,
}

class Exercise extends Equatable {
  final String id;
  final String name;
  final String animationAsset;
  final String instruction;
  final ExerciseType type;
  final MeasurementType measurementType;
  final DifficultyLevel difficulty; // This will be imported from workout.dart
  final List<String> muscleGroups;
  final int calories; // estimated calories per minute
  final List<String> tips;
  final bool hasSound;
  final String? videoUrl;
  final Map<String, dynamic>? metadata;
  final int? reps;
  final int? duration;

  const Exercise({
    required this.measurementType,
    required this.id,
    required this.name,
    required this.animationAsset,
    required this.instruction,
    required this.type,
    required this.difficulty,
    required this.muscleGroups,
    required this.calories,
    this.reps,
    this.duration,
    this.tips = const [],
    this.hasSound = false,
    this.videoUrl,
    this.metadata,
  }) : assert(
  (measurementType == MeasurementType.reps && reps != null) ||
      (measurementType == MeasurementType.time && duration != null)
  );

  // Computed properties
  double get durationInMinutes => duration! / 60.0;

  int get estimatedCaloriesForDuration =>
      (calories * durationInMinutes).round();

  String get formattedDuration {
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get difficultyText {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }

  String get typeText {
    switch (type) {
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.balance:
        return 'Balance';
      case ExerciseType.endurance:
        return 'Endurance';
    }
  }

  // Create a copy with modifications
  Exercise copyWith({
    String? id,
    String? name,
    int? duration,
    int? reps,
    String? animationAsset,
    String? instruction,
    ExerciseType? type,
    MeasurementType? measurementType,
    DifficultyLevel? difficulty,
    List<String>? muscleGroups,
    int? calories,
    List<String>? tips,
    bool? hasSound,
    String? videoUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      reps: reps ?? this.reps,
      animationAsset: animationAsset ?? this.animationAsset,
      instruction: instruction ?? this.instruction,
      type: type ?? this.type,
      measurementType: measurementType ?? this.measurementType,
      difficulty: difficulty ?? this.difficulty,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      calories: calories ?? this.calories,
      tips: tips ?? this.tips,
      hasSound: hasSound ?? this.hasSound,
      videoUrl: videoUrl ?? this.videoUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'reps': reps,
      'animationAsset': animationAsset,
      'instruction': instruction,
      'type': type.name,
      'measurementType': measurementType.name,
      'difficulty': difficulty.name,
      'muscleGroups': muscleGroups,
      'calories': calories,
      'tips': tips,
      'hasSound': hasSound,
      'videoUrl': videoUrl,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      duration: json['duration'] as int?,
      reps: json['reps'] as int?,
      animationAsset: json['animationAsset'] as String,
      instruction: json['instruction'] as String,
      type: ExerciseType.values.firstWhere(
            (t) => t.name == json['type'],
        orElse: () => ExerciseType.cardio,
      ),
      measurementType: MeasurementType.values.firstWhere(
            (m) => m.name == json['measurementType'],
        orElse: () => MeasurementType.time,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
            (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      muscleGroups: List<String>.from(json['muscleGroups'] as List),
      calories: json['calories'] as int,
      tips: List<String>.from(json['tips'] as List? ?? []),
      hasSound: json['hasSound'] as bool? ?? false,
      videoUrl: json['videoUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    duration,
    reps,
    animationAsset,
    instruction,
    type,
    measurementType,
    difficulty,
    muscleGroups,
    calories,
    tips,
    hasSound,
    videoUrl,
    metadata,
  ];

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, duration: ${duration}s, reps: $reps, type: $type, measurementType: $measurementType)';
  }
}

// Rest of the ExerciseSet class remains the same...
class ExerciseSet extends Equatable {
  final int reps;
  final double? weight;
  final Duration? duration;
  final bool completed;

  const ExerciseSet({
    required this.reps,
    this.weight,
    this.duration,
    this.completed = false,
  });

  ExerciseSet copyWith({
    int? reps,
    double? weight,
    Duration? duration,
    bool? completed,
  }) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'duration': duration?.inSeconds,
      'completed': completed,
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'] as int,
      weight: json['weight'] as double?,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [reps, weight, duration, completed];

  @override
  String toString() {
    return 'ExerciseSet(reps: $reps, weight: $weight, completed: $completed)';
  }
}