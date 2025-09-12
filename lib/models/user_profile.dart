// lib/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }

enum FitnessLevel { beginner, intermediate, advanced }

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final FitnessLevel? fitnessLevel;
  final List<String> goals;
  final List<String> medicalConditions;
  final bool emailVerified;
  final bool accountSetupComplete;
  final Map<String, dynamic> preferences;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.fitnessLevel,
    this.goals = const [],
    this.medicalConditions = const [],
    this.emailVerified = false,
    this.accountSetupComplete = false,
    this.preferences = const {},
    this.createdAt,
    this.lastLogin,
  });

  // Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Calculate BMI
  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    DateTime? dateOfBirth,
    Gender? gender,
    double? height,
    double? weight,
    FitnessLevel? fitnessLevel,
    List<String>? goals,
    List<String>? medicalConditions,
    bool? emailVerified,
    bool? accountSetupComplete,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goals: goals ?? this.goals,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emailVerified: emailVerified ?? this.emailVerified,
      accountSetupComplete: accountSetupComplete ?? this.accountSetupComplete,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  // From Firestore
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.parse(data['dateOfBirth'])
          : null,
      gender: data['gender'] != null
          ? Gender.values.firstWhere((e) => e.name == data['gender'])
          : null,
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      fitnessLevel: data['fitnessLevel'] != null
          ? FitnessLevel.values
              .firstWhere((e) => e.name == data['fitnessLevel'])
          : null,
      goals: List<String>.from(data['goals'] ?? []),
      medicalConditions: List<String>.from(data['medicalConditions'] ?? []),
      emailVerified: data['emailVerified'] ?? false,
      accountSetupComplete: data['account_setup_complete'] ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : null,
      lastLogin: data['last_login'] is Timestamp
          ? (data['last_login'] as Timestamp).toDate()
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender?.name,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel?.name,
      'goals': goals,
      'medicalConditions': medicalConditions,
      'emailVerified': emailVerified,
      'account_setup_complete': accountSetupComplete,
      'preferences': preferences,
    };
  }
}
