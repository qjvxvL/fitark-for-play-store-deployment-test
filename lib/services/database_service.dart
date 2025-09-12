import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/workout.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fitark.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_sessions(
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        caloriesBurned INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        completedDuration INTEGER NOT NULL,
        skipped INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert('workout_sessions', {
        'id': session.id,
        'workoutId': session.workoutId,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime?.toIso8601String(),
        'caloriesBurned': session.caloriesBurned,
        'completed': session.completed ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (final progress in session.exerciseProgress) {
        await txn.insert('exercise_progress', {
          'sessionId': session.id,
          'exerciseId': progress.exerciseId,
          'completedDuration': progress.completedDuration,
          'skipped': progress.skipped ? 1 : 0,
          'timestamp': progress.timestamp.toIso8601String(),
        });
      }
    });
  }

  Future<List<WorkoutSession>> getCompletedSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
    );

    List<WorkoutSession> sessions = [];
    for (final map in maps) {
      final progressMaps = await db.query(
        'exercise_progress',
        where: 'sessionId = ?',
        whereArgs: [map['id']],
      );

      final progress = progressMaps
          .map((p) => ExerciseProgress(
                exerciseId: p['exerciseId'] as String,
                completedDuration: (p['completedDuration'] as int),
                skipped: p['skipped'] == 1,
                timestamp: DateTime.parse(p['timestamp'] as String),
              ))
          .toList();

      sessions.add(WorkoutSession(
        id: map['id'],
        workoutId: map['workoutId'],
        startTime: DateTime.parse(map['startTime']),
        endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
        caloriesBurned: map['caloriesBurned'],
        exerciseProgress: progress,
        completed: map['completed'] == 1,
      ));
    }

    return sessions;
  }

  Future<Map<String, dynamic>> getWeeklyStats() async {
    final db = await database;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as workoutCount,
        SUM(caloriesBurned) as totalCalories,
        AVG(caloriesBurned) as avgCalories
      FROM workout_sessions 
      WHERE startTime >= ? AND completed = 1
    ''', [weekAgo.toIso8601String()]);

    return result.first;
  }

  Future<void> saveUserPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getUserPreference(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'];
    }
    return null;
  }
}
