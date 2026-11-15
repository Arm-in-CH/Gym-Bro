import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../../models/exercise.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_log.dart';
import '../../models/nutrition_plan.dart';
import '../../models/calorie_scan_log.dart';
import '../../models/marketplace_models.dart';
import '../../models/active_workout_progress.dart';
import '../../models/timer_settings.dart';
import '../../models/body_analytics_models.dart';
import '../../models/nutrition_models.dart';
import 'database_seeder.dart';

/// Structured telemetry event logged when storage corruption is detected and handled.
class StorageCorruptionEvent {
  final String key;
  final DateTime timestamp;
  final String error;
  final bool recoveredFromBackup;
  final String? quarantinedPayload;

  const StorageCorruptionEvent({
    required this.key,
    required this.timestamp,
    required this.error,
    required this.recoveredFromBackup,
    this.quarantinedPayload,
  });

  @override
  String toString() =>
      'StorageCorruptionEvent(key: $key, time: $timestamp, recovered: $recoveredFromBackup, error: $error)';
}

/// Key-scoped asynchronous mutex to eliminate read-modify-write race conditions.
class KeyedAsyncMutex {
  final Map<String, Future<void>> _chains = {};

  Future<T> runLocked<T>(String key, Future<T> Function() action) {
    final previous = _chains[key] ?? Future.value();
    final completer = Completer<void>();
    _chains[key] = completer.future;

    return previous
        .catchError((_) {})
        .then((_) => action())
        .whenComplete(() {
      completer.complete();
      if (identical(_chains[key], completer.future)) {
        _chains.remove(key);
      }
    });
  }
}

class LocalStorageService {
  static const String _keyProfile = 'gymbro_user_profile';
  static const String _keyNutritionPlan = 'gymbro_nutrition_plan';
  static const String _keyWorkoutPlans = 'gymbro_workout_plans';
  static const String _keyExercises = 'gymbro_exercises';
  static const String _keyWorkoutLogs = 'gymbro_workout_logs';
  static const String _keyCalorieLogs = 'gymbro_calorie_logs';
  static const String _keyWaterLogs = 'gymbro_water_logs';
  static const String _keyFavoriteFoods = 'gymbro_favorite_foods';
  static const String _keyGyms = 'gymbro_gyms';
  static const String _keyTrainers = 'gymbro_trainers';
  static const String _keyBookings = 'gymbro_bookings';
  static const String _keyApiKey = 'gymbro_openrouter_api_key';
  static const String _keyGeminiApiKey = 'gymbro_gemini_api_key';
  static const String _keyGeminiModel = 'gymbro_gemini_model';
  static const String _keyTimerSettings = 'gymbro_timer_settings';
  static const String _keyWeightRecords = 'gymbro_weight_records';
  static const String _keyBodyMeasurements = 'gymbro_body_measurements';
  static const String _keyActiveDraftPrefix = 'gymbro_active_draft_';
  static const String _keySchemaVersion = 'gymbro_schema_version';

  static const String _keyBackupPrefix = 'gymbro_backup_';
  static const String _keyQuarantinePrefix = 'gymbro_corrupted_';

  static const int _currentSchemaVersion = 5;

  SharedPreferences? _prefs;
  final KeyedAsyncMutex _mutex = KeyedAsyncMutex();
  final List<StorageCorruptionEvent> _corruptionEvents = [];

  List<StorageCorruptionEvent> get corruptionEvents =>
      List.unmodifiable(_corruptionEvents);

  void clearCorruptionEvents() => _corruptionEvents.clear();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedIfFirstLaunch();
    await _migrateIfNeeded();
  }

  Future<void> _seedIfFirstLaunch() async {
    final prefs = _prefs;
    if (prefs == null) return;
    if (!prefs.containsKey(_keyProfile)) {
      await saveProfile(DatabaseSeeder.defaultUserProfile);
    }
    if (!prefs.containsKey(_keyNutritionPlan)) {
      await saveNutritionPlan(DatabaseSeeder.defaultNutritionPlan);
    }
    if (!prefs.containsKey(_keyExercises)) {
      await saveExercises(DatabaseSeeder.defaultExercises);
    }
    if (!prefs.containsKey(_keyWorkoutPlans)) {
      await saveWorkoutPlans(DatabaseSeeder.defaultWorkoutPlans);
    }
    if (!prefs.containsKey(_keyGyms)) {
      await saveGyms(DatabaseSeeder.defaultGyms);
    }
    if (!prefs.containsKey(_keyTrainers)) {
      await saveTrainers(DatabaseSeeder.defaultTrainers);
    }
    if (!prefs.containsKey(_keyTimerSettings)) {
      await saveTimerSettings(const TimerSettings());
    }
    if (!prefs.containsKey(_keyWeightRecords)) {
      await saveWeightRecords(DatabaseSeeder.defaultWeightRecords);
    }
    if (!prefs.containsKey(_keyBodyMeasurements)) {
      await saveBodyMeasurements(DatabaseSeeder.defaultBodyMeasurements);
    }
    if (!prefs.containsKey(_keyCalorieLogs)) {
      await saveCalorieLogs(DatabaseSeeder.defaultCalorieLogs);
    }
    if (!prefs.containsKey(_keyWaterLogs)) {
      await saveWaterLogs(DatabaseSeeder.defaultWaterLogs);
    }
    if (!prefs.containsKey(_keyFavoriteFoods)) {
      await saveFavoriteFoods(DatabaseSeeder.defaultFavoriteFoods);
    }
  }

  Future<void> _migrateIfNeeded() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final installedVersion = prefs.getInt(_keySchemaVersion) ?? 1;

    // Guard against future schema versions (e.g. v6+) to avoid data loss
    if (installedVersion > _currentSchemaVersion) {
      return;
    }

    if (installedVersion < _currentSchemaVersion) {
      // Safe migration: never delete existing user records
      if (!prefs.containsKey(_keyTimerSettings)) {
        await saveTimerSettings(const TimerSettings());
      }
      if (!prefs.containsKey(_keyWeightRecords)) {
        await saveWeightRecords(DatabaseSeeder.defaultWeightRecords);
      }
      if (!prefs.containsKey(_keyBodyMeasurements)) {
        await saveBodyMeasurements(DatabaseSeeder.defaultBodyMeasurements);
      }
      if (!prefs.containsKey(_keyCalorieLogs)) {
        await saveCalorieLogs(DatabaseSeeder.defaultCalorieLogs);
      }
      if (!prefs.containsKey(_keyWaterLogs)) {
        await saveWaterLogs(DatabaseSeeder.defaultWaterLogs);
      }
      if (!prefs.containsKey(_keyFavoriteFoods)) {
        await saveFavoriteFoods(DatabaseSeeder.defaultFavoriteFoods);
      }

      // Ensure backups exist for all existing primary keys
      await _ensureBackupsForExistingData();

      await prefs.setInt(_keySchemaVersion, _currentSchemaVersion);
    }
  }

  Future<void> _ensureBackupsForExistingData() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final keys = [
      _keyProfile,
      _keyNutritionPlan,
      _keyExercises,
      _keyWorkoutPlans,
      _keyGyms,
      _keyTrainers,
      _keyTimerSettings,
      _keyWeightRecords,
      _keyBodyMeasurements,
      _keyCalorieLogs,
      _keyWaterLogs,
      _keyFavoriteFoods,
      _keyWorkoutLogs,
      _keyBookings,
    ];
    for (final k in keys) {
      final backupKey = '$_keyBackupPrefix$k';
      if (prefs.containsKey(k) && !prefs.containsKey(backupKey)) {
        final val = prefs.getString(k);
        if (val != null) {
          await prefs.setString(backupKey, val);
        }
      }
    }
  }

  // --- SAFE READ / WRITE / RECOVERY CORE ---

  T _readSafely<T>({
    required String key,
    required T Function(dynamic json) parser,
    required T fallback,
  }) {
    final prefs = _prefs;
    if (prefs == null || !prefs.containsKey(key)) {
      return fallback;
    }

    final raw = prefs.getString(key);
    if (raw == null) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(raw);
      return parser(decoded);
    } catch (error) {
      // Corruption detected!
      final backupKey = '$_keyBackupPrefix$key';
      final quarantineKey = '$_keyQuarantinePrefix$key';

      // Quarantine corrupted payload
      prefs.setString(quarantineKey, raw);

      // Attempt backup recovery
      if (prefs.containsKey(backupKey)) {
        final backupRaw = prefs.getString(backupKey);
        if (backupRaw != null) {
          try {
            final backupDecoded = jsonDecode(backupRaw);
            final recovered = parser(backupDecoded);

            // Successfully recovered from backup; restore primary key
            prefs.setString(key, backupRaw);
            _corruptionEvents.add(StorageCorruptionEvent(
              key: key,
              timestamp: DateTime.now(),
              error: error.toString(),
              recoveredFromBackup: true,
              quarantinedPayload: raw,
            ));
            return recovered;
          } catch (_) {
            // Backup is also invalid
          }
        }
      }

      // Record corruption event with no backup recovery
      _corruptionEvents.add(StorageCorruptionEvent(
        key: key,
        timestamp: DateTime.now(),
        error: error.toString(),
        recoveredFromBackup: false,
        quarantinedPayload: raw,
      ));

      // Return safe fallback without destroying or overwriting corrupted payload
      return fallback;
    }
  }

  Future<void> _writeKey(String key, String jsonPayload) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(key, jsonPayload);
    await prefs.setString('$_keyBackupPrefix$key', jsonPayload);
  }

  Future<void> _writeSafely(String key, String jsonPayload) async {
    await _mutex.runLocked(key, () => _writeKey(key, jsonPayload));
  }

  // --- PUBLIC RECOVERY & BACKUP APIS ---

  bool hasCorruptedData(String key) {
    return _prefs?.containsKey('$_keyQuarantinePrefix$key') ?? false;
  }

  String? getQuarantinedData(String key) {
    return _prefs?.getString('$_keyQuarantinePrefix$key');
  }

  Future<void> clearQuarantine(String key) async {
    await _prefs?.remove('$_keyQuarantinePrefix$key');
  }

  bool hasBackup(String key) {
    return _prefs?.containsKey('$_keyBackupPrefix$key') ?? false;
  }

  String? getBackupData(String key) {
    return _prefs?.getString('$_keyBackupPrefix$key');
  }

  Future<bool> restoreFromBackup(String key) async {
    final prefs = _prefs;
    if (prefs == null) return false;
    final backupKey = '$_keyBackupPrefix$key';
    if (!prefs.containsKey(backupKey)) return false;
    final backupData = prefs.getString(backupKey);
    if (backupData == null) return false;

    try {
      jsonDecode(backupData);
      await prefs.setString(key, backupData);
      await prefs.remove('$_keyQuarantinePrefix$key');
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> exportAllBackups() {
    final prefs = _prefs;
    if (prefs == null) return {};
    final result = <String, String>{};
    for (final k in prefs.getKeys()) {
      if (k.startsWith(_keyBackupPrefix)) {
        final val = prefs.getString(k);
        if (val != null) {
          result[k] = val;
        }
      }
    }
    return result;
  }

  // USER PROFILE
  UserProfile getProfile() {
    return _readSafely<UserProfile>(
      key: _keyProfile,
      parser: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      fallback: DatabaseSeeder.defaultUserProfile,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _writeSafely(_keyProfile, jsonEncode(profile.toJson()));
  }

  // NUTRITION PLAN
  NutritionPlan getNutritionPlan() {
    return _readSafely<NutritionPlan>(
      key: _keyNutritionPlan,
      parser: (json) => NutritionPlan.fromJson(json as Map<String, dynamic>),
      fallback: DatabaseSeeder.defaultNutritionPlan,
    );
  }

  Future<void> saveNutritionPlan(NutritionPlan plan) async {
    await _writeSafely(_keyNutritionPlan, jsonEncode(plan.toJson()));
  }

  // EXERCISES
  List<Exercise> getExercises() {
    return _readSafely<List<Exercise>>(
      key: _keyExercises,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => Exercise.fromJson(e))
          .toList(),
      fallback: DatabaseSeeder.defaultExercises,
    );
  }

  Future<void> saveExercises(List<Exercise> exercises) async {
    final list = exercises.map((e) => e.toJson()).toList();
    await _writeSafely(_keyExercises, jsonEncode(list));
  }

  Future<void> saveExercise(Exercise exercise) async {
    await _mutex.runLocked(_keyExercises, () async {
      final exercises = getExercises();
      final index = exercises.indexWhere((e) => e.id == exercise.id);
      if (index >= 0) {
        exercises[index] = exercise;
      } else {
        exercises.add(exercise);
      }
      final list = exercises.map((e) => e.toJson()).toList();
      await _writeKey(_keyExercises, jsonEncode(list));
    });
  }

  Future<void> deleteExercise(String id) async {
    await _mutex.runLocked(_keyExercises, () async {
      final exercises = getExercises();
      exercises.removeWhere((e) => e.id == id);
      final list = exercises.map((e) => e.toJson()).toList();
      await _writeKey(_keyExercises, jsonEncode(list));
    });
  }

  // WORKOUT PLANS
  List<WorkoutPlan> getWorkoutPlans() {
    return _readSafely<List<WorkoutPlan>>(
      key: _keyWorkoutPlans,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => WorkoutPlan.fromJson(e))
          .toList(),
      fallback: DatabaseSeeder.defaultWorkoutPlans,
    );
  }

  Future<void> saveWorkoutPlans(List<WorkoutPlan> plans) async {
    final list = plans.map((p) => p.toJson()).toList();
    await _writeSafely(_keyWorkoutPlans, jsonEncode(list));
  }

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await _mutex.runLocked(_keyWorkoutPlans, () async {
      final plans = getWorkoutPlans();
      final index = plans.indexWhere((p) => p.id == plan.id);
      if (index >= 0) {
        plans[index] = plan;
      } else {
        plans.insert(0, plan);
      }
      final list = plans.map((p) => p.toJson()).toList();
      await _writeKey(_keyWorkoutPlans, jsonEncode(list));
    });
  }

  Future<void> deleteWorkoutPlan(String id) async {
    await _mutex.runLocked(_keyWorkoutPlans, () async {
      final plans = getWorkoutPlans();
      plans.removeWhere((p) => p.id == id);
      final list = plans.map((p) => p.toJson()).toList();
      await _writeKey(_keyWorkoutPlans, jsonEncode(list));
      await clearActiveWorkoutProgress(id);
    });
  }

  // ACTIVE WORKOUT PROGRESS / DRAFT
  ActiveWorkoutProgress? getActiveWorkoutProgress(String planId) {
    return _readSafely<ActiveWorkoutProgress?>(
      key: '$_keyActiveDraftPrefix$planId',
      parser: (json) =>
          ActiveWorkoutProgress.fromJson(json as Map<String, dynamic>),
      fallback: null,
    );
  }

  Future<void> saveActiveWorkoutProgress(ActiveWorkoutProgress progress) async {
    await _writeSafely(
      '$_keyActiveDraftPrefix${progress.planId}',
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> clearActiveWorkoutProgress(String planId) async {
    await _mutex.runLocked('$_keyActiveDraftPrefix$planId', () async {
      await _prefs?.remove('$_keyActiveDraftPrefix$planId');
      await _prefs?.remove('$_keyBackupPrefix$_keyActiveDraftPrefix$planId');
    });
  }

  // WORKOUT LOGS
  List<WorkoutLog> getWorkoutLogs() {
    return _readSafely<List<WorkoutLog>>(
      key: _keyWorkoutLogs,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => WorkoutLog.fromJson(e))
          .toList(),
      fallback: [],
    );
  }

  Future<void> saveWorkoutLogs(List<WorkoutLog> logs) async {
    final list = logs.map((l) => l.toJson()).toList();
    await _writeSafely(_keyWorkoutLogs, jsonEncode(list));
  }

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    await _mutex.runLocked(_keyWorkoutLogs, () async {
      final logs = getWorkoutLogs();
      final index = logs.indexWhere((l) => l.id == log.id);
      if (index >= 0) {
        logs[index] = log;
      } else {
        logs.insert(0, log);
      }
      final list = logs.map((l) => l.toJson()).toList();
      await _writeKey(_keyWorkoutLogs, jsonEncode(list));
    });
  }

  Future<void> deleteWorkoutLog(String id) async {
    await _mutex.runLocked(_keyWorkoutLogs, () async {
      final logs = getWorkoutLogs();
      logs.removeWhere((l) => l.id == id);
      final list = logs.map((l) => l.toJson()).toList();
      await _writeKey(_keyWorkoutLogs, jsonEncode(list));
    });
  }

  // TIMER SETTINGS
  TimerSettings getTimerSettings() {
    return _readSafely<TimerSettings>(
      key: _keyTimerSettings,
      parser: (json) =>
          TimerSettings.fromJson(json as Map<String, dynamic>),
      fallback: const TimerSettings(),
    );
  }

  Future<void> saveTimerSettings(TimerSettings settings) async {
    await _writeSafely(_keyTimerSettings, jsonEncode(settings.toJson()));
  }

  // CALORIE SCAN LOGS
  List<CalorieScanLog> getCalorieLogs() {
    return _readSafely<List<CalorieScanLog>>(
      key: _keyCalorieLogs,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => CalorieScanLog.fromJson(e))
          .toList(),
      fallback: [],
    );
  }

  Future<void> saveCalorieLogs(List<CalorieScanLog> logs) async {
    final list = logs.map((l) => l.toJson()).toList();
    await _writeSafely(_keyCalorieLogs, jsonEncode(list));
  }

  Future<void> saveCalorieLog(CalorieScanLog log) async {
    await _mutex.runLocked(_keyCalorieLogs, () async {
      final logs = getCalorieLogs();
      logs.insert(0, log);
      final list = logs.map((l) => l.toJson()).toList();
      await _writeKey(_keyCalorieLogs, jsonEncode(list));
    });
  }

  Future<void> updateCalorieLog(CalorieScanLog updated) async {
    await _mutex.runLocked(_keyCalorieLogs, () async {
      final logs = getCalorieLogs();
      final idx = logs.indexWhere((l) => l.id == updated.id);
      if (idx != -1) {
        logs[idx] = updated;
      } else {
        logs.insert(0, updated);
      }
      final list = logs.map((l) => l.toJson()).toList();
      await _writeKey(_keyCalorieLogs, jsonEncode(list));
    });
  }

  Future<void> deleteCalorieLog(String id) async {
    await _mutex.runLocked(_keyCalorieLogs, () async {
      final logs = getCalorieLogs();
      logs.removeWhere((l) => l.id == id);
      final list = logs.map((l) => l.toJson()).toList();
      await _writeKey(_keyCalorieLogs, jsonEncode(list));
    });
  }

  // WATER LOGS
  List<WaterLog> getWaterLogs() {
    return _readSafely<List<WaterLog>>(
      key: _keyWaterLogs,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => WaterLog.fromJson(e))
          .toList(),
      fallback: DatabaseSeeder.defaultWaterLogs,
    );
  }

  Future<void> saveWaterLogs(List<WaterLog> logs) async {
    final list = logs.map((w) => w.toJson()).toList();
    await _writeSafely(_keyWaterLogs, jsonEncode(list));
  }

  Future<void> saveWaterLog(WaterLog log) async {
    await _mutex.runLocked(_keyWaterLogs, () async {
      final logs = getWaterLogs();
      logs.insert(0, log);
      final list = logs.map((w) => w.toJson()).toList();
      await _writeKey(_keyWaterLogs, jsonEncode(list));
    });
  }

  Future<void> deleteWaterLog(String id) async {
    await _mutex.runLocked(_keyWaterLogs, () async {
      final logs = getWaterLogs();
      logs.removeWhere((w) => w.id == id);
      final list = logs.map((w) => w.toJson()).toList();
      await _writeKey(_keyWaterLogs, jsonEncode(list));
    });
  }

  // FAVORITE FOODS / TEMPLATES
  List<QuickFoodTemplate> getFavoriteFoods() {
    return _readSafely<List<QuickFoodTemplate>>(
      key: _keyFavoriteFoods,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => QuickFoodTemplate.fromJson(e))
          .toList(),
      fallback: DatabaseSeeder.defaultFavoriteFoods,
    );
  }

  Future<void> saveFavoriteFoods(List<QuickFoodTemplate> foods) async {
    final list = foods.map((f) => f.toJson()).toList();
    await _writeSafely(_keyFavoriteFoods, jsonEncode(list));
  }

  Future<void> saveFavoriteFood(QuickFoodTemplate food) async {
    await _mutex.runLocked(_keyFavoriteFoods, () async {
      final foods = getFavoriteFoods();
      final idx = foods.indexWhere((f) => f.id == food.id);
      if (idx != -1) {
        foods[idx] = food;
      } else {
        foods.add(food);
      }
      final list = foods.map((f) => f.toJson()).toList();
      await _writeKey(_keyFavoriteFoods, jsonEncode(list));
    });
  }

  Future<void> deleteFavoriteFood(String id) async {
    await _mutex.runLocked(_keyFavoriteFoods, () async {
      final foods = getFavoriteFoods();
      foods.removeWhere((f) => f.id == id);
      final list = foods.map((f) => f.toJson()).toList();
      await _writeKey(_keyFavoriteFoods, jsonEncode(list));
    });
  }

  // GYMS & TRAINERS
  List<Gym> getGyms() {
    return _readSafely<List<Gym>>(
      key: _keyGyms,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => Gym.fromJson(e))
          .toList(),
      fallback: DatabaseSeeder.defaultGyms,
    );
  }

  Future<void> saveGyms(List<Gym> gyms) async {
    final list = gyms.map((g) => g.toJson()).toList();
    await _writeSafely(_keyGyms, jsonEncode(list));
  }

  List<Trainer> getTrainers() {
    return _readSafely<List<Trainer>>(
      key: _keyTrainers,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => Trainer.fromJson(e))
          .toList(),
      fallback: DatabaseSeeder.defaultTrainers,
    );
  }

  Future<void> saveTrainers(List<Trainer> trainers) async {
    final list = trainers.map((t) => t.toJson()).toList();
    await _writeSafely(_keyTrainers, jsonEncode(list));
  }

  // BOOKINGS
  List<Booking> getBookings() {
    return _readSafely<List<Booking>>(
      key: _keyBookings,
      parser: (json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => Booking.fromJson(e))
          .toList(),
      fallback: [],
    );
  }

  Future<void> saveBookings(List<Booking> bookings) async {
    final list = bookings.map((b) => b.toJson()).toList();
    await _writeSafely(_keyBookings, jsonEncode(list));
  }

  Future<void> saveBooking(Booking booking) async {
    await _mutex.runLocked(_keyBookings, () async {
      final bookings = getBookings();
      final index = bookings.indexWhere((b) => b.id == booking.id);
      if (index >= 0) {
        bookings[index] = booking;
      } else {
        bookings.insert(0, booking);
      }
      final list = bookings.map((b) => b.toJson()).toList();
      await _writeKey(_keyBookings, jsonEncode(list));
    });
  }

  // GEMINI AI CONFIG
  String getGeminiApiKey() {
    final key = _prefs?.getString(_keyGeminiApiKey) ?? '';
    return key.trim();
  }

  Future<void> saveGeminiApiKey(String key) async {
    final clean = key.trim();
    await _mutex.runLocked(_keyGeminiApiKey, () async {
      await _prefs?.setString(_keyGeminiApiKey, clean);
      await _prefs?.setString('$_keyBackupPrefix$_keyGeminiApiKey', clean);
    });
  }

  String getGeminiModel() {
    return _prefs?.getString(_keyGeminiModel) ?? 'gemini-1.5-flash';
  }

  Future<void> saveGeminiModel(String model) async {
    final clean = model.trim();
    await _mutex.runLocked(_keyGeminiModel, () async {
      await _prefs?.setString(_keyGeminiModel, clean);
      await _prefs?.setString('$_keyBackupPrefix$_keyGeminiModel', clean);
    });
  }

  /// Masks an API key for safe presentation in debug tools, logs, or UI
  static String maskApiKey(String key) {
    final clean = key.trim();
    if (clean.isEmpty) return '(تنظیم نشده)';
    if (clean.length <= 8) return '****';
    final prefix = clean.substring(0, 4);
    final suffix = clean.substring(clean.length - 4);
    return '$prefix...$suffix';
  }

  // --- BODY ANALYTICS & WEIGHT HISTORY ---

  List<WeightRecord> getWeightRecords() {
    return _readSafely<List<WeightRecord>>(
      key: _keyWeightRecords,
      parser: (json) {
        final list = (json as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((item) => WeightRecord.fromJson(item))
            .toList();
        list.sort((a, b) => a.date.compareTo(b.date));
        return list;
      },
      fallback: DatabaseSeeder.defaultWeightRecords,
    );
  }

  Future<void> saveWeightRecords(List<WeightRecord> records) async {
    final list = records.map((r) => r.toJson()).toList();
    await _writeSafely(_keyWeightRecords, jsonEncode(list));
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    await _mutex.runLocked(_keyWeightRecords, () async {
      final records = getWeightRecords();
      records.removeWhere((r) => r.id == record.id);
      records.add(record);
      records.sort((a, b) => a.date.compareTo(b.date));
      final list = records.map((r) => r.toJson()).toList();
      await _writeKey(_keyWeightRecords, jsonEncode(list));
    });
  }

  Future<void> deleteWeightRecord(String id) async {
    await _mutex.runLocked(_keyWeightRecords, () async {
      final records = getWeightRecords();
      records.removeWhere((r) => r.id == id);
      final list = records.map((r) => r.toJson()).toList();
      await _writeKey(_keyWeightRecords, jsonEncode(list));
    });
  }

  List<BodyMeasurementRecord> getBodyMeasurements() {
    return _readSafely<List<BodyMeasurementRecord>>(
      key: _keyBodyMeasurements,
      parser: (json) {
        final list = (json as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((item) => BodyMeasurementRecord.fromJson(item))
            .toList();
        list.sort((a, b) => a.date.compareTo(b.date));
        return list;
      },
      fallback: DatabaseSeeder.defaultBodyMeasurements,
    );
  }

  Future<void> saveBodyMeasurements(List<BodyMeasurementRecord> records) async {
    final list = records.map((r) => r.toJson()).toList();
    await _writeSafely(_keyBodyMeasurements, jsonEncode(list));
  }

  Future<void> addBodyMeasurement(BodyMeasurementRecord record) async {
    await _mutex.runLocked(_keyBodyMeasurements, () async {
      final records = getBodyMeasurements();
      records.removeWhere((r) => r.id == record.id);
      records.add(record);
      records.sort((a, b) => a.date.compareTo(b.date));
      final list = records.map((r) => r.toJson()).toList();
      await _writeKey(_keyBodyMeasurements, jsonEncode(list));
    });
  }

  Future<void> deleteBodyMeasurement(String id) async {
    await _mutex.runLocked(_keyBodyMeasurements, () async {
      final records = getBodyMeasurements();
      records.removeWhere((r) => r.id == id);
      final list = records.map((r) => r.toJson()).toList();
      await _writeKey(_keyBodyMeasurements, jsonEncode(list));
    });
  }

  // OPENROUTER AI CONFIG
  String getApiKey() => getOpenRouterApiKey();
  Future<void> saveApiKey(String key) => saveOpenRouterApiKey(key);

  String getOpenRouterApiKey() {
    final key = _prefs?.getString(_keyApiKey) ?? '';
    return key.trim();
  }

  Future<void> saveOpenRouterApiKey(String key) async {
    final clean = key.trim();
    await _mutex.runLocked(_keyApiKey, () async {
      await _prefs?.setString(_keyApiKey, clean);
      await _prefs?.setString('$_keyBackupPrefix$_keyApiKey', clean);
    });
  }
}
