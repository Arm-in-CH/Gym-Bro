import 'user_level.dart';
import 'body_analytics_models.dart';
import '../core/storage/safe_cast.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final double weightKg;
  final double heightCm;
  final int age;
  final double bodyFatPercentage;
  final double muscleMassKg;
  final String fitnessGoal;
  final String fitnessLevel;
  final UserLevel level;
  final int coins;
  final int dailyFreeScans;
  final int streakDays;
  final int totalWorkoutsCompleted;
  final int activeSinceMonths;

  // Phase 12 Additions: Professional Profile & Body Analytics
  final double targetWeightKg;
  final Gender gender;
  final ActivityLevel activityLevel;
  final int preferredTrainingDays;
  final DateTime? dateOfBirth;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.weightKg,
    required this.heightCm,
    this.age = 20,
    this.bodyFatPercentage = 27.2,
    this.muscleMassKg = 29.9,
    required this.fitnessGoal,
    required this.fitnessLevel,
    required this.level,
    required this.coins,
    required this.dailyFreeScans,
    required this.streakDays,
    required this.totalWorkoutsCompleted,
    required this.activeSinceMonths,
    this.targetWeightKg = 70.0,
    this.gender = Gender.male,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.preferredTrainingDays = 4,
    this.dateOfBirth,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  double get bmi {
    if (heightCm <= 0) return 0;
    final hMeters = heightCm / 100.0;
    return weightKg / (hMeters * hMeters);
  }

  BmiCategory get bmiCategory => BmiCategory.fromBmi(bmi);

  /// Target weight delta: positive if target is greater, negative if target is smaller.
  double get weightToTarget => (weightKg - targetWeightKg).abs();

  FitnessGoal get parsedFitnessGoal => FitnessGoal.fromString(fitnessGoal);

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    double? weightKg,
    double? heightCm,
    int? age,
    double? bodyFatPercentage,
    double? muscleMassKg,
    String? fitnessGoal,
    String? fitnessLevel,
    UserLevel? level,
    int? coins,
    int? dailyFreeScans,
    int? streakDays,
    int? totalWorkoutsCompleted,
    int? activeSinceMonths,
    double? targetWeightKg,
    Gender? gender,
    ActivityLevel? activityLevel,
    int? preferredTrainingDays,
    DateTime? dateOfBirth,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMassKg: muscleMassKg ?? this.muscleMassKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      dailyFreeScans: dailyFreeScans ?? this.dailyFreeScans,
      streakDays: streakDays ?? this.streakDays,
      totalWorkoutsCompleted:
          totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
      activeSinceMonths: activeSinceMonths ?? this.activeSinceMonths,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      preferredTrainingDays:
          preferredTrainingDays ?? this.preferredTrainingDays,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMassKg': muscleMassKg,
      'fitnessGoal': fitnessGoal,
      'fitnessLevel': fitnessLevel,
      'level': level.name,
      'coins': coins,
      'dailyFreeScans': dailyFreeScans,
      'streakDays': streakDays,
      'totalWorkoutsCompleted': totalWorkoutsCompleted,
      'activeSinceMonths': activeSinceMonths,
      'targetWeightKg': targetWeightKg,
      'gender': gender.name,
      'activityLevel': activityLevel.name,
      'preferredTrainingDays': preferredTrainingDays,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: SafeCast.toStringVal(json['id'], 'user_armin_1'),
      firstName: SafeCast.toStringVal(json['firstName'], 'آرمین'),
      lastName: SafeCast.toStringVal(json['lastName'], 'چینی‌پرداز'),
      phone: SafeCast.toStringVal(json['phone'], '+989120000000'),
      email: SafeCast.toStringVal(json['email'], 'armin@gymbro.ir'),
      weightKg: SafeCast.toDouble(json['weightKg'], 72.6),
      heightCm: SafeCast.toDouble(json['heightCm'], 165.0),
      age: SafeCast.toInt(json['age'], 20),
      bodyFatPercentage: SafeCast.toDouble(json['bodyFatPercentage'], 27.2),
      muscleMassKg: SafeCast.toDouble(json['muscleMassKg'], 29.9),
      fitnessGoal: SafeCast.toStringVal(
        json['fitnessGoal'],
        'بهبود فرم بدنی و عضله‌سازی (Body Recomposition)',
      ),
      fitnessLevel:
          SafeCast.toStringVal(json['fitnessLevel'], 'متوسط (Intermediate)'),
      level: UserLevel.fromString(SafeCast.toStringOrNull(json['level'])),
      coins: SafeCast.toInt(json['coins'], 50),
      dailyFreeScans: SafeCast.toInt(json['dailyFreeScans'], 5),
      streakDays: SafeCast.toInt(json['streakDays'], 14),
      totalWorkoutsCompleted:
          SafeCast.toInt(json['totalWorkoutsCompleted'], 38),
      activeSinceMonths: SafeCast.toInt(json['activeSinceMonths'], 4),
      targetWeightKg: SafeCast.toDouble(json['targetWeightKg'], 70.0),
      gender: Gender.fromString(SafeCast.toStringOrNull(json['gender'])),
      activityLevel: ActivityLevel.fromString(
          SafeCast.toStringOrNull(json['activityLevel'])),
      preferredTrainingDays: SafeCast.toInt(json['preferredTrainingDays'], 4),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      avatarUrl: SafeCast.toStringOrNull(json['avatarUrl']),
    );
  }
}
