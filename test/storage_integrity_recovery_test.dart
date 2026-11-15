import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/nutrition_models.dart';
import 'package:gymbro/models/timer_settings.dart';
import 'package:gymbro/models/chat_message.dart';
import 'package:gymbro/models/active_workout_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Storage Integrity & Data Recovery Suite', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Category 1: Missing storage gracefully returns defaults & seeds V5 with backups', () async {
      final storage = LocalStorageService();

      // Before init, getters return default values without throwing
      final preInitProfile = storage.getProfile();
      expect(preInitProfile.id, equals('user_armin_1'));
      expect(storage.getWorkoutLogs(), isEmpty);
      expect(storage.hasBackup('gymbro_user_profile'), isFalse);

      await storage.init();

      // After init, initial seeder runs and sets schema version 5
      final profile = storage.getProfile();
      expect(profile.firstName, equals('آرمین'));
      expect(storage.hasBackup('gymbro_user_profile'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('gymbro_schema_version'), equals(5));

      // Check backups were created for all initial categories
      expect(storage.hasBackup('gymbro_workout_plans'), isTrue);
      expect(storage.hasBackup('gymbro_exercises'), isTrue);
      expect(storage.hasBackup('gymbro_nutrition_plan'), isTrue);
      expect(storage.hasBackup('gymbro_timer_settings'), isTrue);
      expect(storage.hasBackup('gymbro_water_logs'), isTrue);
    });

    test('Category 2: Dual Storage & Backup synchronization', () async {
      final storage = LocalStorageService();
      await storage.init();

      // Update profile
      final updatedProfile = storage.getProfile().copyWith(
        firstName: 'تست یک',
        weightKg: 75.5,
      );
      await storage.saveProfile(updatedProfile);

      final prefs = await SharedPreferences.getInstance();
      final primaryProfileRaw = prefs.getString('gymbro_user_profile');
      final backupProfileRaw = prefs.getString('gymbro_backup_gymbro_user_profile');

      expect(primaryProfileRaw, isNotNull);
      expect(backupProfileRaw, equals(primaryProfileRaw));
      expect(storage.getBackupData('gymbro_user_profile'), equals(primaryProfileRaw));

      // Test active workout progress draft & clear
      final draft = ActiveWorkoutProgress(
        planId: 'test_plan_draft',
        selectedDay: 2,
        startTimeEpoch: 123456789,
        exerciseSets: {},
      );
      await storage.saveActiveWorkoutProgress(draft);
      expect(storage.getActiveWorkoutProgress('test_plan_draft'), isNotNull);
      expect(storage.hasBackup('gymbro_active_draft_test_plan_draft'), isTrue);

      await storage.clearActiveWorkoutProgress('test_plan_draft');
      expect(storage.getActiveWorkoutProgress('test_plan_draft'), isNull);
      expect(storage.hasBackup('gymbro_active_draft_test_plan_draft'), isFalse);

      // Verify exportAllBackups
      final allBackups = storage.exportAllBackups();
      expect(allBackups.containsKey('gymbro_backup_gymbro_user_profile'), isTrue);
      expect(allBackups.containsKey('gymbro_backup_gymbro_workout_plans'), isTrue);
    });

    test('Category 3: JSON Corruption detection, quarantine & auto-recovery from backup', () async {
      final storage = LocalStorageService();
      await storage.init();

      // Save a valid custom profile so backup is recorded
      final validCustomProfile = storage.getProfile().copyWith(
        firstName: 'علی',
        lastName: 'موسوی',
        weightKg: 80.0,
      );
      await storage.saveProfile(validCustomProfile);

      final prefs = await SharedPreferences.getInstance();
      expect(storage.hasBackup('gymbro_user_profile'), isTrue);

      // Simulate catastrophic JSON corruption on the primary key
      const corruptedJson = '{"firstName": "علی", "lastName": UNCLOSED_CORRUPT_JSON...';
      await prefs.setString('gymbro_user_profile', corruptedJson);

      // Read profile - should detect corruption, quarantine it, and recover from backup!
      final recoveredProfile = storage.getProfile();
      expect(recoveredProfile.firstName, equals('علی'));
      expect(recoveredProfile.lastName, equals('موسوی'));
      expect(recoveredProfile.weightKg, equals(80.0));

      // Verify quarantine exists
      expect(storage.hasCorruptedData('gymbro_user_profile'), isTrue);
      expect(storage.getQuarantinedData('gymbro_user_profile'), equals(corruptedJson));

      // Verify corruption event telemetry
      expect(storage.corruptionEvents.length, equals(1));
      final event = storage.corruptionEvents.first;
      expect(event.key, equals('gymbro_user_profile'));
      expect(event.recoveredFromBackup, isTrue);
      expect(event.quarantinedPayload, equals(corruptedJson));

      // Verify primary key in prefs is restored to valid JSON
      final primaryRestored = prefs.getString('gymbro_user_profile');
      expect(primaryRestored, isNot(equals(corruptedJson)));
      expect(jsonDecode(primaryRestored!)['firstName'], equals('علی'));

      // Test manual quarantine clear
      await storage.clearQuarantine('gymbro_user_profile');
      expect(storage.hasCorruptedData('gymbro_user_profile'), isFalse);
    });

    test('Category 3B: Corrupted JSON with missing backup preserves quarantine & falls back safely', () async {
      final storage = LocalStorageService();
      await storage.init();

      final prefs = await SharedPreferences.getInstance();

      // Inject corruption for workout logs with no backup
      await prefs.setString('gymbro_workout_logs', '{invalid: json: [');
      await prefs.remove('gymbro_backup_gymbro_workout_logs');

      final logs = storage.getWorkoutLogs();
      // Returns fallback empty list without crashing
      expect(logs, isEmpty);

      // Verify quarantined payload was preserved and not silently overwritten
      expect(storage.hasCorruptedData('gymbro_workout_logs'), isTrue);
      expect(storage.getQuarantinedData('gymbro_workout_logs'), equals('{invalid: json: ['));

      expect(storage.corruptionEvents.any((e) =>
          e.key == 'gymbro_workout_logs' && e.recoveredFromBackup == false), isTrue);
    });

    test('Category 4: Hardened Models Defend Against Type & Null Corruption', () {
      // 1. WorkoutPlan with numeric types as strings or nulls
      final corruptedPlanJson = {
        'id': 1001, // int instead of String
        'titleFa': null,
        'daysPerWeek': '5', // String instead of int
        'difficulty': 123,
        'exercises': [
          {
            'id': 999,
            'planId': null,
            'exerciseId': 'ex_squat',
            'dayOfWeek': '2',
            'orderInDay': 1.5,
            'targetSets': '4',
            'targetReps': '12',
            'targetWeightKg': '75.5',
            'restSeconds': '90',
          },
          'invalid_exercise_entry', // Non-map element in list
        ],
      };

      final plan = WorkoutPlan.fromJson(corruptedPlanJson);
      expect(plan.id, equals('1001'));
      expect(plan.titleFa, isEmpty);
      expect(plan.daysPerWeek, equals(5)); // String '5' safely coerced to 5
      expect(plan.exercises.length, equals(1));
      expect(plan.exercises.first.id, equals('999'));
      expect(plan.exercises.first.targetSets, equals(4)); // String '4' coerced to 4
      expect(plan.exercises.first.targetWeightKg, equals(75.5)); // String '75.5' coerced to 75.5

      final fallbackPlan =
          WorkoutPlan.fromJson({'daysPerWeek': 'invalid_string'});
      expect(fallbackPlan.daysPerWeek, equals(3)); // Invalid string safely fell back to 3

      // 2. ActiveWorkoutSet with double/int mismatches
      final corruptedSet = ActiveWorkoutSet.fromJson({
        'setNumber': 1.0,
        'targetReps': 10.0,
        'targetWeightKg': '60',
        'actualReps': 12.0,
        'actualWeightKg': '62.5',
        'isCompleted': 1, // numeric 1 coerced to true
      });
      expect(corruptedSet.setNumber, equals(1));
      expect(corruptedSet.targetReps, equals(10));
      expect(corruptedSet.targetWeightKg, equals(60.0));
      expect(corruptedSet.isCompleted, isTrue);

      // Unparseable bool falls back to false
      final fallbackSet = ActiveWorkoutSet.fromJson({'isCompleted': 'not_a_bool'});
      expect(fallbackSet.isCompleted, isFalse);

      // 3. UserProfile with string numbers and invalid dates
      final corruptedProfile = UserProfile.fromJson({
        'id': 42,
        'weightKg': '70.5', // coerced to 70.5
        'age': '22', // coerced to 22
        'level': 'UNKNOWN_LEVEL',
        'gender': 'INVALID_GENDER',
        'dateOfBirth': 'not-a-valid-date',
      });
      expect(corruptedProfile.id, equals('42'));
      expect(corruptedProfile.weightKg, equals(70.5));
      expect(corruptedProfile.age, equals(22));
      expect(corruptedProfile.level.name, equals('member'));
      expect(corruptedProfile.dateOfBirth, isNull);

      final fallbackProfile = UserProfile.fromJson({
        'weightKg': 'invalid_num',
        'age': 'invalid_age',
      });
      expect(fallbackProfile.weightKg, equals(72.6)); // safely fell back
      expect(fallbackProfile.age, equals(20)); // safely fell back

      // 4. CalorieScanLog & WaterLog
      final corruptedWaterLog = WaterLog.fromJson({
        'id': 555,
        'amountMl': '350', // coerced to 350
        'timestamp': 'now', // unparseable string -> falls back to current epoch
      });
      expect(corruptedWaterLog.id, equals('555'));
      expect(corruptedWaterLog.amountMl, equals(350));
      expect(corruptedWaterLog.timestamp, greaterThan(0));

      final corruptedCalorieLog = CalorieScanLog.fromJson({
        'id': 777,
        'calories': '500', // coerced to 500
        'proteinG': '35.5', // coerced to 35.5
        'isAiScanned': 'true', // coerced to true
      });
      expect(corruptedCalorieLog.id, equals('777'));
      expect(corruptedCalorieLog.calories, equals(500));
      expect(corruptedCalorieLog.proteinG, equals(35.5));
      expect(corruptedCalorieLog.isAiScanned, isTrue);

      // 5. TimerSettings & ChatMessage
      final corruptedTimer = TimerSettings.fromJson({
        'defaultRestSeconds': '120', // coerced to 120
        'soundAlerts': false,
        'vibrationAlerts': null,
      });
      expect(corruptedTimer.defaultRestSeconds, equals(120));
      expect(corruptedTimer.soundAlerts, isFalse);
      expect(corruptedTimer.vibrationAlerts, isTrue);

      final fallbackTimer =
          TimerSettings.fromJson({'defaultRestSeconds': 'invalid'});
      expect(fallbackTimer.defaultRestSeconds, equals(90)); // safely fell back to 90

      final corruptedChat = ChatMessage.fromJson({
        'id': 123,
        'text': null,
        'isUser': 'yes', // 'yes' coerced to true
        'timestamp': 'yesterday', // unparseable string falls back to 0
      });
      expect(corruptedChat.id, equals('123'));
      expect(corruptedChat.text, isEmpty);
      expect(corruptedChat.isUser, isTrue);
      expect(corruptedChat.timestamp.millisecondsSinceEpoch, equals(0));
    });

    test('Category 5: Schema Migration (V1..4 -> V5) & Future Version (V6) Safety', () async {
      // Simulate existing V2 installation with custom profile and workout logs
      SharedPreferences.setMockInitialValues({
        'gymbro_schema_version': 2,
        'gymbro_user_profile': jsonEncode({
          'id': 'user_migrated',
          'firstName': 'رضا',
          'lastName': 'پهلوان',
          'phone': '+989123456789',
          'email': 'reza@gymbro.ir',
          'weightKg': 82.0,
          'heightCm': 180.0,
          'age': 25,
          'fitnessGoal': 'عضله‌سازی',
          'fitnessLevel': 'پیشرفته',
          'level': 'pro',
          'coins': 120,
          'dailyFreeScans': 5,
          'streakDays': 30,
          'totalWorkoutsCompleted': 100,
          'activeSinceMonths': 12,
        }),
        'gymbro_workout_logs': jsonEncode([
          {
            'id': 'log_v2_1',
            'planId': 'plan_1',
            'planTitle': 'برنامه قدیمی',
            'date': '1403-01-01',
            'durationMinutes': 50,
            'totalVolumeKg': 3200.0,
            'completedSets': 16,
            'timestamp': 1700000000000,
            'sets': [],
          }
        ]),
      });

      final storage = LocalStorageService();
      await storage.init();

      // Migration checks
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('gymbro_schema_version'), equals(5));

      // User profile is preserved
      final profile = storage.getProfile();
      expect(profile.id, equals('user_migrated'));
      expect(profile.firstName, equals('رضا'));

      // Workout logs preserved
      final logs = storage.getWorkoutLogs();
      expect(logs.length, equals(1));
      expect(logs.first.id, equals('log_v2_1'));

      // Backups were generated for existing data during migration
      expect(storage.hasBackup('gymbro_user_profile'), isTrue);
      expect(storage.hasBackup('gymbro_workout_logs'), isTrue);

      // Future Schema Version Safety test
      await prefs.setInt('gymbro_schema_version', 6);
      await prefs.setString('gymbro_future_key', 'future_value');

      final storageFuture = LocalStorageService();
      await storageFuture.init();

      // Does not downgrade version or wipe data
      expect(prefs.getInt('gymbro_schema_version'), equals(6));
      expect(prefs.getString('gymbro_future_key'), equals('future_value'));
    });

    test('Category 6: Key-Scoped Concurrency Mutex eliminates write race conditions', () async {
      final storage = LocalStorageService();
      await storage.init();

      // Start with empty water logs
      await storage.saveWaterLogs([]);
      expect(storage.getWaterLogs(), isEmpty);

      // Launch 10 rapid concurrent write operations to the same storage key
      final futures = List.generate(10, (i) {
        return storage.saveWaterLog(WaterLog(
          id: 'water_concurrent_$i',
          dateString: '1403-08-24',
          amountMl: (i + 1) * 250,
          timestamp: 1700000000 + i,
        ));
      });

      await Future.wait(futures);

      // Under a race condition without mutex, the final list would have 1 or 2 items.
      // With KeyedAsyncMutex, all 10 logs must be present!
      final recordedLogs = storage.getWaterLogs();
      expect(recordedLogs.length, equals(10));
      for (int i = 0; i < 10; i++) {
        expect(recordedLogs.any((w) => w.id == 'water_concurrent_$i'), isTrue);
      }

      // Test concurrent writes to CalorieLogs
      await storage.saveCalorieLogs([]);
      final calorieFutures = List.generate(8, (i) {
        return storage.saveCalorieLog(CalorieScanLog(
          id: 'cal_concurrent_$i',
          foodName: 'غذای شماره $i',
          mealType: 'ناهار',
          calories: (i + 1) * 100,
          proteinG: 20.0,
          carbsG: 30.0,
          fatG: 10.0,
          portionG: 150.0,
          dateString: '1403-08-24',
          timestamp: 1700000000 + i,
        ));
      });

      await Future.wait(calorieFutures);

      final recordedCalories = storage.getCalorieLogs();
      expect(recordedCalories.length, equals(8));
    });

    test('Category 7: Manual Data Recovery & Administrative APIs', () async {
      final storage = LocalStorageService();
      await storage.init();

      final prefs = await SharedPreferences.getInstance();

      // Corrupt key intentionally
      await prefs.setString('gymbro_nutrition_plan', 'BROKEN_PLAN');
      await prefs.setString('gymbro_corrupted_gymbro_nutrition_plan', 'BROKEN_PLAN');

      expect(storage.hasCorruptedData('gymbro_nutrition_plan'), isTrue);

      // Perform manual restoreFromBackup
      final success = await storage.restoreFromBackup('gymbro_nutrition_plan');
      expect(success, isTrue);

      // Verify quarantine cleared and primary restored
      expect(storage.hasCorruptedData('gymbro_nutrition_plan'), isFalse);
      final restoredPlan = storage.getNutritionPlan();
      expect(restoredPlan.id, isNotEmpty);
      expect(restoredPlan.dailyCalories, greaterThan(0));

      // Test clearCorruptionEvents
      storage.clearCorruptionEvents();
      expect(storage.corruptionEvents, isEmpty);
    });
  });
}
