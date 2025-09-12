import '../models/exercise.dart';
import '../models/workout.dart';

class WorkoutService {
  // Create different exercise pools for different workout types
  List<Exercise> _getCardioExercises() {
    return [
      const Exercise(
        id: 'cardio_1',
        name: 'Jumping Jacks',
        duration: 30,
        animationAsset: 'assets/animations/jumping_jacks.json',
        instruction: 'Jump with your legs spread and hands overhead.',
        type: ExerciseType.cardio,
        difficulty: DifficultyLevel.beginner,
        muscleGroups: ['Full Body'],
        calories: 8,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add proper measurement type
      ),
      const Exercise(
        id: 'cardio_2',
        name: 'High Knees',
        duration: 30,
        animationAsset: 'assets/animations/high_knees.json',
        instruction: 'Run in place lifting your knees as high as possible.',
        type: ExerciseType.cardio,
        difficulty: DifficultyLevel.beginner,
        muscleGroups: ['Legs', 'Core'],
        calories: 9,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add proper measurement type
      ),
      const Exercise(
        id: 'cardio_3',
        name: 'Mountain Climbers',
        duration: 45,
        animationAsset: 'assets/animations/mountain_climbers.json',
        instruction:
            'Start in plank position and alternate bringing knees to chest.',
        type: ExerciseType.cardio,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Core', 'Arms', 'Legs'],
        calories: 12,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'cardio_4',
        name: 'Burpees',
        duration: 60,
        animationAsset: 'assets/animations/burpees.json',
        instruction:
            'From standing, drop to plank, do push-up, jump back to squat, then jump up.',
        type: ExerciseType.cardio,
        difficulty: DifficultyLevel.advanced,
        muscleGroups: ['Full Body'],
        calories: 15,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
    ];
  }

  List<Exercise> _getStrengthExercises() {
    return [
      const Exercise(
        id: 'strength_1',
        name: 'Push-ups',
        duration: 45,
        animationAsset: '',
        instruction:
            'Lower your body until chest nearly touches floor, then push up.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Chest', 'Arms', 'Core'],
        calories: 10,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'strength_2',
        name: 'Squats',
        duration: 45,
        animationAsset: 'assets/animations/squats.json',
        instruction: 'Lower your body by bending knees, keep back straight.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.beginner,
        muscleGroups: ['Legs', 'Glutes'],
        calories: 8,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'strength_3',
        name: 'Burpee',
        duration: 60,
        animationAsset: 'assets/animations/lunges.json',
        instruction:
            'Step forward and lower your hips until both knees are at 90 degrees.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Legs', 'Glutes'],
        calories: 9,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'strength_4',
        name: 'Free Inchworm',
        duration: 45,
        animationAsset: 'assets/animations/inchworm.json',
        instruction:
            'The inchworm is a bodyweight move where you bend forward, walk your hands into a plank, then walk your feet up to your hands and stand.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Arms', 'Shoulders', 'Abs'],
        calories: 7,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
    ];
  }

  List<Exercise> _getCoreExercises() {
    return [
      const Exercise(
        id: 'core_1',
        name: 'Plank',
        duration: 60,
        animationAsset: 'assets/animations/plank.json',
        instruction: 'Hold your body in a straight line from head to heels.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Core', 'Arms'],
        calories: 5,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'core_2',
        name: 'Bicycle Crunches',
        duration: 45,
        animationAsset: 'assets/animations/bicycle_crunches.json',
        instruction: 'Lie on back, alternate bringing opposite elbow to knee.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Core'],
        calories: 6,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'core_3',
        name: 'Russian Twists',
        duration: 45,
        animationAsset: 'assets/animations/russian_twists.json',
        instruction:
            'Sit with knees bent, lean back and rotate torso side to side.',
        type: ExerciseType.strength,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Core'],
        calories: 7,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
    ];
  }

  List<Exercise> _getYogaExercises() {
    return [
      const Exercise(
        id: 'yoga_1',
        name: 'Child\'s Pose',
        duration: 60,
        animationAsset: 'assets/animations/childs_pose.json',
        instruction: 'Kneel and sit back on heels, extend arms forward.',
        type: ExerciseType.flexibility,
        difficulty: DifficultyLevel.beginner,
        muscleGroups: ['Back', 'Hips'],
        calories: 2,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'yoga_2',
        name: 'Downward Dog',
        duration: 60,
        animationAsset: 'assets/animations/downward_dog.json',
        instruction: 'Form inverted V-shape with hands and feet on ground.',
        type: ExerciseType.flexibility,
        difficulty: DifficultyLevel.beginner,
        muscleGroups: ['Full Body'],
        calories: 3,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Fixed this
      ),
      const Exercise(
        id: 'yoga_3',
        name: 'Warrior Pose',
        duration: 45,
        animationAsset: 'assets/animations/warrior_pose.json',
        instruction: 'Step one foot back, bend front knee, arms overhead.',
        type: ExerciseType.flexibility,
        difficulty: DifficultyLevel.intermediate,
        muscleGroups: ['Legs', 'Core'],
        calories: 4,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
    ];
  }

  List<Exercise> _getHIITExercises() {
    return [
      const Exercise(
        id: 'hiit_1',
        name: 'Jump Squats',
        duration: 30,
        animationAsset: 'assets/animations/jump_squats.json',
        instruction: 'Perform squat then explode up into a jump.',
        type: ExerciseType.cardio,
        difficulty: DifficultyLevel.advanced,
        muscleGroups: ['Legs', 'Glutes'],
        calories: 12,
        videoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Add this
      ),
      const Exercise(
        id: 'hiit_2',
        name: 'Plank Jacks',
        duration: 30,
        animationAsset: 'assets/animations/plank_jacks.json',
        instruction: 'In plank position, jump feet apart and together.',
        type: ExerciseType.cardio,
        difficulty: DifficultyLevel.advanced,
        muscleGroups: ['Core', 'Legs'],
        calories: 10,
        videoUrl:
            'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=600&fit=crop',
        measurementType: MeasurementType.time, // Fixed this
      ),
    ];
  }

  // Create specific workouts with different exercises
  List<Workout> getAllWorkouts() {
    final cardioExercises = _getCardioExercises();
    final strengthExercises = _getStrengthExercises();
    final coreExercises = _getCoreExercises();
    final yogaExercises = _getYogaExercises();
    final hiitExercises = _getHIITExercises();

    return [
      // Morning Cardio Workout
      Workout(
        id: '1',
        name: 'Morning Cardio Blast',
        description:
            'High-intensity cardio workout to kickstart your day with energy and burn calories effectively.',
        exercises: [
          cardioExercises[0], // Jumping Jacks
          cardioExercises[1], // High Knees
          cardioExercises[2], // Mountain Climbers
          strengthExercises[1], // Squats
        ],
        difficulty: DifficultyLevel.intermediate,
        imageAsset: 'assets/images/cardio_workout.jpg',
        category: 'Cardio',
        tags: const ['Morning', 'Energy', 'Fat Burn'],
        heroImageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      ),

      // Full Body Strength
      Workout(
        id: '2',
        name: 'Full Body Strength',
        description:
            'Complete strength training targeting all major muscle groups for lean muscle development.',
        exercises: [
          strengthExercises[0], // Push-ups
          strengthExercises[1], // Squats
          strengthExercises[2], // Burpee
          strengthExercises[3], // Free Inchworm
          coreExercises[0], // Plank
        ],
        difficulty: DifficultyLevel.intermediate,
        imageAsset: 'assets/images/strength_workout.jpg',
        category: 'Strength',
        tags: const ['Muscle Building', 'Full Body', 'Strength'],
        heroImageUrl:
            'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=300&fit=crop',
      ),

      // Core Crusher
      Workout(
        id: '3',
        name: 'Core Crusher',
        description:
            'Intense core workout to strengthen your abs and improve stability.',
        exercises: [
          coreExercises[0], // Plank
          coreExercises[1], // Bicycle Crunches
          coreExercises[2], // Russian Twists
          cardioExercises[2], // Mountain Climbers (also great for core)
        ],
        difficulty: DifficultyLevel.intermediate,
        imageAsset: 'assets/images/core_workout.jpg',
        category: 'Core',
        tags: const ['Abs', 'Core', 'Stability'],
        heroImageUrl:
            'https://images.unsplash.com/photo-1594737625785-a6cbdabd333c?w=400&h=300&fit=crop',
      ),

      // Yoga Flow
      Workout(
        id: '4',
        name: 'Peaceful Yoga Flow',
        description:
            'Gentle yoga sequence to improve flexibility and reduce stress.',
        exercises: [
          yogaExercises[0], // Child's Pose
          yogaExercises[1], // Downward Dog
          yogaExercises[2], // Warrior Pose
        ],
        difficulty: DifficultyLevel.beginner,
        imageAsset: 'assets/images/yoga_workout.jpg',
        category: 'Yoga',
        tags: const ['Flexibility', 'Mindfulness', 'Relaxation'],
        heroImageUrl:
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=300&fit=crop',
      ),

      // HIIT Blast
      Workout(
        id: '5',
        name: 'HIIT Power Blast',
        description:
            'High-intensity interval training for maximum calorie burn in minimum time.',
        exercises: [
          hiitExercises[0], // Jump Squats
          cardioExercises[3], // Burpees
          hiitExercises[1], // Plank Jacks
          cardioExercises[2], // Mountain Climbers
        ],
        difficulty: DifficultyLevel.advanced,
        imageAsset: 'assets/images/hiit_workout.jpg',
        category: 'HIIT',
        tags: const ['High Intensity', 'Fat Burn', 'Quick'],
        heroImageUrl:
            'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=400&h=300&fit=crop',
      ),

      // Beginner Friendly
      Workout(
        id: '6',
        name: 'Beginner\'s Start',
        description:
            'Perfect workout for fitness beginners to build foundation strength.',
        exercises: [
          cardioExercises[0], // Jumping Jacks
          strengthExercises[1], // Squats
          yogaExercises[0], // Child's Pose
          coreExercises[0], // Plank (modified for beginners)
        ],
        difficulty: DifficultyLevel.beginner,
        imageAsset: 'assets/images/beginner_workout.jpg',
        category: 'Beginner',
        tags: const ['Beginner', 'Foundation', 'Easy'],
        heroImageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      ),
    ];
  }

  // Get workout by ID
  Workout? getWorkoutById(String id) {
    try {
      return getAllWorkouts().firstWhere((workout) => workout.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get workouts by category
  List<Workout> getWorkoutsByCategory(String category) {
    return getAllWorkouts()
        .where((workout) =>
            workout.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Get workouts by difficulty
  List<Workout> getWorkoutsByDifficulty(DifficultyLevel difficulty) {
    return getAllWorkouts()
        .where((workout) => workout.difficulty == difficulty)
        .toList();
  }
}
