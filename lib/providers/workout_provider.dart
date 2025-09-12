import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/database_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  final DatabaseService _databaseService = DatabaseService();

  List<Workout> _workouts = [];
  List<WorkoutSession> _completedSessions = [];
  Workout? _currentWorkout;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Workout> get workouts => _workouts;
  List<WorkoutSession> get completedSessions => _completedSessions;
  Workout? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add the missing initialize method
  void initialize() {
    loadWorkouts();
    _loadCompletedSessions();
  }

  Future<void> loadWorkouts() async {
    _setLoading(true);
    try {
      _workouts = _workoutService.getAllWorkouts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading workouts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadCompletedSessions() async {
    try {
      _completedSessions = await _databaseService.getCompletedSessions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading completed sessions: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentWorkout(Workout workout) {
    _currentWorkout = workout;
    notifyListeners();
  }

  Future<void> completeWorkout(WorkoutSession session) async {
    try {
      await _databaseService.saveWorkoutSession(session);
      _completedSessions.add(session);
      _currentWorkout = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Statistics
  int get totalWorkoutsCompleted =>
      _completedSessions.where((s) => s.completed).length;
  int get totalCaloriesBurned => _completedSessions.fold(
      0, (sum, session) => sum + session.caloriesBurned);
  Duration get totalWorkoutTime => _completedSessions.fold(
      Duration.zero, (sum, session) => sum + session.duration);
}
