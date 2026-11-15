import 'package:flutter/foundation.dart';
import '../core/repository/profile_repository.dart';
import '../core/storage/database_seeder.dart';
import '../models/body_analytics_models.dart';
import '../models/user_level.dart';
import '../models/user_profile.dart';

class LevelProgressInfo {
  final UserLevel currentLevel;
  final UserLevel? nextLevel;
  final double progressFraction;
  final String requirementDescriptionFa;
  final bool isEliteEarned;

  LevelProgressInfo({
    required this.currentLevel,
    this.nextLevel,
    required this.progressFraction,
    required this.requirementDescriptionFa,
    required this.isEliteEarned,
  });
}

class ProfileState extends ChangeNotifier {
  final IProfileRepository repository;

  late UserProfile userProfile;
  List<WeightRecord> weightRecords = [];
  List<BodyMeasurementRecord> bodyMeasurements = [];

  ProfileState({
    required this.repository,
    UserProfile? initialProfile,
    List<WeightRecord>? initialWeightRecords,
    List<BodyMeasurementRecord>? initialBodyMeasurements,
  }) {
    userProfile = initialProfile ?? DatabaseSeeder.defaultUserProfile;
    if (initialWeightRecords != null) weightRecords = initialWeightRecords;
    if (initialBodyMeasurements != null) bodyMeasurements = initialBodyMeasurements;
  }

  Future<void> loadFromRepository() async {
    userProfile = await repository.getProfile();
    weightRecords = await repository.getWeightRecords();
    bodyMeasurements = await repository.getBodyMeasurements();
    notifyListeners();
  }

  LevelProgressInfo get levelProgress {
    switch (userProfile.level) {
      case UserLevel.member:
        final progress = (userProfile.streakDays / 7.0).clamp(0.0, 1.0);
        return LevelProgressInfo(
          currentLevel: UserLevel.member,
          nextLevel: UserLevel.athlete,
          progressFraction: progress,
          requirementDescriptionFa:
              'ثبت حداقل ۷ روز فعالیت مستمر یا ۳ ماه تمرین منظم برای ارتقا به ورزشکار (Athlete).',
          isEliteEarned: false,
        );
      case UserLevel.athlete:
        final progress =
            (userProfile.totalWorkoutsCompleted / 30.0).clamp(0.0, 1.0);
        return LevelProgressInfo(
          currentLevel: UserLevel.athlete,
          nextLevel: UserLevel.pro,
          progressFraction: progress,
          requirementDescriptionFa:
              'انجام ۳۰ جلسه تمرین ثبت‌شده یا ارتقا به اشتراک حرفه‌ای (Pro).',
          isEliteEarned: false,
        );
      case UserLevel.pro:
        final mFactor = (userProfile.activeSinceMonths / 6.0).clamp(0.0, 0.5);
        final wFactor =
            (userProfile.totalWorkoutsCompleted / 50.0).clamp(0.0, 0.5);
        return LevelProgressInfo(
          currentLevel: UserLevel.pro,
          nextLevel: UserLevel.elite,
          progressFraction: mFactor + wFactor,
          requirementDescriptionFa:
              'رتبه نخبه (Elite) خریدنی نیست! نیازمند ۶ ماه استمرار و تایید رسمی مربی اختصاصی است.',
          isEliteEarned: false,
        );
      case UserLevel.elite:
        return LevelProgressInfo(
          currentLevel: UserLevel.elite,
          nextLevel: null,
          progressFraction: 1.0,
          requirementDescriptionFa:
              'شما به بالاترین رتبه کسب‌شده در جیم‌برو (Elite) رسیده‌اید. نشان طلایی و اسکن نامحدود فعال است.',
          isEliteEarned: true,
        );
    }
  }

  WeightRecord? get latestWeightRecord =>
      weightRecords.isNotEmpty ? weightRecords.last : null;

  BodyMeasurementRecord? get latestBodyMeasurement =>
      bodyMeasurements.isNotEmpty ? bodyMeasurements.last : null;

  double get initialWeightKg =>
      weightRecords.isNotEmpty ? weightRecords.first.weightKg : userProfile.weightKg;

  double get currentWeightKg =>
      latestWeightRecord?.weightKg ?? userProfile.weightKg;

  double get totalWeightChangeKg => currentWeightKg - initialWeightKg;

  double get targetWeightKg => userProfile.targetWeightKg;

  double get weightToTargetKg => (currentWeightKg - targetWeightKg).abs();

  double? get goalProgressFraction {
    final start = initialWeightKg;
    final current = currentWeightKg;
    final target = targetWeightKg;
    final totalDistance = (start - target).abs();
    if (totalDistance < 0.1) return 1.0;
    final isLosingWeight = target < start;
    if (isLosingWeight) {
      if (current <= target) return 1.0;
      if (current >= start) return 0.0;
      return ((start - current) / (start - target)).clamp(0.0, 1.0);
    } else {
      if (current >= target) return 1.0;
      if (current <= start) return 0.0;
      return ((current - start) / (target - start)).clamp(0.0, 1.0);
    }
  }

  BmiCategory get bmiCategory => userProfile.bmiCategory;

  Future<void> updateUserProfile(UserProfile profile) async {
    userProfile = profile;
    await repository.saveProfile(userProfile);
    notifyListeners();
  }

  Future<void> updateProfileMetrics({
    required double weightKg,
    required double heightCm,
    required String goal,
  }) async {
    userProfile = userProfile.copyWith(
      weightKg: weightKg,
      heightCm: heightCm,
      fitnessGoal: goal,
    );
    await repository.saveProfile(userProfile);
    notifyListeners();
  }

  Future<void> addWeightRecord({
    required double weightKg,
    DateTime? date,
    String? note,
  }) async {
    final recordDate = date ?? DateTime.now();
    final newRecord = WeightRecord(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      date: recordDate,
      weightKg: weightKg,
      note: note,
    );
    await repository.addWeightRecord(newRecord);
    weightRecords = await repository.getWeightRecords();

    if (weightRecords.isNotEmpty && weightRecords.last.id == newRecord.id) {
      userProfile = userProfile.copyWith(weightKg: weightKg);
      await repository.saveProfile(userProfile);
    }
    notifyListeners();
  }

  Future<void> deleteWeightRecord(String id) async {
    await repository.deleteWeightRecord(id);
    weightRecords = await repository.getWeightRecords();
    if (weightRecords.isNotEmpty) {
      userProfile = userProfile.copyWith(weightKg: weightRecords.last.weightKg);
      await repository.saveProfile(userProfile);
    }
    notifyListeners();
  }

  Future<void> addBodyMeasurement(BodyMeasurementRecord record) async {
    await repository.addBodyMeasurement(record);
    bodyMeasurements = await repository.getBodyMeasurements();
    if (record.bodyFatPercentage != null) {
      userProfile = userProfile.copyWith(bodyFatPercentage: record.bodyFatPercentage);
      await repository.saveProfile(userProfile);
    }
    notifyListeners();
  }

  Future<void> deleteBodyMeasurement(String id) async {
    await repository.deleteBodyMeasurement(id);
    bodyMeasurements = await repository.getBodyMeasurements();
    notifyListeners();
  }

  Future<void> updateFullProfile(UserProfile updated) async {
    userProfile = updated;
    await repository.saveProfile(userProfile);
    notifyListeners();
  }
}
