import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/repository/workout_repository.dart';
import 'package:gymbro/core/repository/nutrition_repository.dart';
import 'package:gymbro/core/repository/hydration_repository.dart';
import 'package:gymbro/core/repository/profile_repository.dart';
import 'package:gymbro/core/repository/settings_repository.dart';
import 'package:gymbro/core/repository/marketplace_repository.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/nutrition_models.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/timer_settings.dart';
import 'package:gymbro/models/body_analytics_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AppState appState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    appState = AppState(storage: storage);
  });

  group('GymBro Phase 04: Repository Architecture Tests', () {
    test('1. WorkoutRepository CRUD operations persist and retrieve correctly', () async {
      final repo = LocalWorkoutRepository(storage: storage);
      final initialPlans = await repo.getWorkoutPlans();
      expect(initialPlans, isNotEmpty);

      final newPlan = WorkoutPlan(
        id: 'repo_plan_1',
        titleFa: 'برنامه تست مخزن',
        titleEn: 'Repo Test Plan',
        descriptionFa: 'توضیحات تست مخزن',
        splitType: 'Full Body',
        isHomeWorkout: false,
        daysPerWeek: 3,
        difficulty: 'متوسط',
        exercises: const [],
      );

      await repo.saveWorkoutPlan(newPlan);
      final fetched = await repo.getWorkoutPlanById('repo_plan_1');
      expect(fetched, isNotNull);
      expect(fetched!.titleFa, equals('برنامه تست مخزن'));

      await repo.deleteWorkoutPlan('repo_plan_1');
      final afterDelete = await repo.getWorkoutPlanById('repo_plan_1');
      expect(afterDelete, isNull);
    });

    test('2. NutritionRepository manages nutrition plan, calorie logs, and favorites', () async {
      final repo = LocalNutritionRepository(storage: storage);
      final plan = await repo.getNutritionPlan();
      expect(plan.dailyCalories, greaterThan(0));

      final meal = CalorieScanLog(
        id: 'repo_meal_1',
        foodName: 'سینه مرغ گریل',
        mealType: 'ناهار',
        calories: 320,
        proteinG: 45.0,
        carbsG: 0.0,
        fatG: 5.0,
        portionG: 200.0,
        dateString: '2026-11-14',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await repo.saveCalorieLog(meal);
      final logs = await repo.getCalorieLogs();
      expect(logs.any((l) => l.id == 'repo_meal_1'), isTrue);

      final favorite = QuickFoodTemplate(
        id: 'fav_1',
        name: 'اوتمیل پروتئینی',
        defaultMealType: 'صبحانه',
        calories: 380,
        proteinG: 25.0,
        carbsG: 50.0,
        fatG: 8.0,
        portionG: 100.0,
        category: 'کربوهیدرات',
      );

      await repo.saveFavoriteFood(favorite);
      final favorites = await repo.getFavoriteFoods();
      expect(favorites.any((f) => f.id == 'fav_1'), isTrue);

      await repo.deleteFavoriteFood('fav_1');
      final afterDelete = await repo.getFavoriteFoods();
      expect(afterDelete.any((f) => f.id == 'fav_1'), isFalse);
    });

    test('3. HydrationRepository manages water logs and persistence', () async {
      final repo = LocalHydrationRepository(storage: storage);
      final initialLogs = await repo.getWaterLogs();

      final water = WaterLog(
        id: 'water_test_1',
        dateString: '2026-11-14',
        amountMl: 500,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await repo.saveWaterLog(water);
      final updatedLogs = await repo.getWaterLogs();
      expect(updatedLogs.length, equals(initialLogs.length + 1));
      expect(updatedLogs.any((w) => w.id == 'water_test_1'), isTrue);

      await repo.deleteWaterLog('water_test_1');
      final finalLogs = await repo.getWaterLogs();
      expect(finalLogs.any((w) => w.id == 'water_test_1'), isFalse);
    });

    test('4. ProfileRepository manages user biometrics, weight, and measurements', () async {
      final repo = LocalProfileRepository(storage: storage);
      final profile = await repo.getProfile();
      expect(profile.id, isNotEmpty);

      final updatedProfile = profile.copyWith(
        weightKg: 82.5,
        fitnessGoal: 'افزایش حجم عضلانی',
      );
      await repo.saveProfile(updatedProfile);

      final reloaded = await repo.getProfile();
      expect(reloaded.weightKg, equals(82.5));
      expect(reloaded.fitnessGoal, equals('افزایش حجم عضلانی'));

      final weightRec = WeightRecord(
        id: 'w_test_1',
        date: DateTime.now(),
        weightKg: 82.5,
        note: 'ثبت صبحگاهی',
      );
      await repo.addWeightRecord(weightRec);
      final weightList = await repo.getWeightRecords();
      expect(weightList.any((w) => w.id == 'w_test_1'), isTrue);

      final measurement = BodyMeasurementRecord(
        id: 'm_test_1',
        date: DateTime.now(),
        chestCm: 108.0,
        waistCm: 84.0,
        leftArmCm: 39.5,
        rightArmCm: 39.5,
      );
      await repo.addBodyMeasurement(measurement);
      final measureList = await repo.getBodyMeasurements();
      expect(measureList.any((m) => m.id == 'm_test_1'), isTrue);
    });

    test('5. SettingsRepository and MarketplaceRepository manage configuration & services', () async {
      final settingsRepo = LocalSettingsRepository(storage: storage);
      await settingsRepo.saveGeminiApiKey('test_gemini_key_123');
      await settingsRepo.saveGeminiModel('gemini-1.5-pro');
      await settingsRepo.saveTimerSettings(const TimerSettings(defaultRestSeconds: 90));

      expect(await settingsRepo.getGeminiApiKey(), equals('test_gemini_key_123'));
      expect(await settingsRepo.getGeminiModel(), equals('gemini-1.5-pro'));
      final timer = await settingsRepo.getTimerSettings();
      expect(timer.defaultRestSeconds, equals(90));

      final marketRepo = LocalMarketplaceRepository(storage: storage);
      final gyms = await marketRepo.getGyms();
      expect(gyms, isNotEmpty);
      final trainers = await marketRepo.getTrainers();
      expect(trainers, isNotEmpty);
    });
  });

  group('GymBro Phase 04: State Modularization & Isolation Tests', () {
    test('6. WorkoutState functions independently with mockable repository', () async {
      final workoutRepo = LocalWorkoutRepository(storage: storage);
      final workoutState = WorkoutState(
        repository: workoutRepo,
        initialWorkoutPlans: [
          WorkoutPlan(
            id: 'plan_iso_1',
            titleFa: 'برنامه ایزوله',
            titleEn: 'Isolated Plan',
            descriptionFa: 'تست ماژولار بودن',
            splitType: 'PPL',
            isHomeWorkout: false,
            daysPerWeek: 4,
            difficulty: 'پیشرفته',
            exercises: const [],
          ),
        ],
      );

      expect(workoutState.workoutPlans.length, equals(1));
      expect(workoutState.workoutPlans.first.id, equals('plan_iso_1'));

      await workoutState.createWorkoutPlan(
        titleFa: 'برنامه جدید ایزوله',
        descriptionFa: 'توضیحات ایزوله',
      );
      expect(workoutState.workoutPlans.any((p) => p.titleFa == 'برنامه جدید ایزوله'), isTrue);
    });

    test('7. NutritionState functions independently and isolates calorie/macro calculations', () async {
      final nutritionRepo = LocalNutritionRepository(storage: storage);
      final nutritionState = NutritionState(
        repository: nutritionRepo,
      );
      await nutritionState.loadFromRepository();

      final initialCalories = nutritionState.todayConsumedCalories;
      final initialProtein = nutritionState.todayConsumedProtein;
      final initialFat = nutritionState.todayConsumedFat;

      await nutritionState.addMealLog(
        foodName: 'تخم مرغ آب‌پز ۳ عدد',
        mealType: 'صبحانه',
        calories: 210,
        proteinG: 18.0,
        carbsG: 1.5,
        fatG: 15.0,
        portionG: 150.0,
      );

      expect(nutritionState.todayConsumedCalories, equals(initialCalories + 210));
      expect(nutritionState.todayConsumedProtein, equals(initialProtein + 18.0));
      expect(nutritionState.todayConsumedFat, equals(initialFat + 15.0));
    });

    test('8. HydrationState functions independently without touching workout models', () async {
      final hydrationRepo = LocalHydrationRepository(storage: storage);
      final hydrationState = HydrationState(
        repository: hydrationRepo,
      );
      await hydrationState.loadFromRepository();

      final initialWater = hydrationState.todayConsumedWaterMl;

      await hydrationState.logWater(300, dateString: hydrationState.todayDateString);
      expect(hydrationState.todayConsumedWaterMl, equals(initialWater + 300));

      await hydrationState.undoWater(100, dateString: hydrationState.todayDateString);
      expect(hydrationState.todayConsumedWaterMl, equals(initialWater + 200));
    });

    test('9. ProfileState calculates gamified levels and biometrics accurately', () async {
      final profileRepo = LocalProfileRepository(storage: storage);
      final profileState = ProfileState(
        repository: profileRepo,
        initialProfile: UserProfile(
          id: 'user_athlete',
          firstName: 'سهراب',
          lastName: 'مرادی',
          phone: '+989121111111',
          email: 'sohrab@gymbro.ir',
          gender: Gender.male,
          heightCm: 180.0,
          weightKg: 85.0,
          targetWeightKg: 82.0,
          fitnessGoal: 'قدرتی',
          fitnessLevel: 'پیشرفته',
          activityLevel: ActivityLevel.veryActive,
          level: UserLevel.athlete,
          streakDays: 14,
          totalWorkoutsCompleted: 20,
          activeSinceMonths: 3,
          coins: 100,
          dailyFreeScans: 3,
        ),
      );

      expect(profileState.levelProgress.currentLevel, equals(UserLevel.athlete));
      expect(profileState.levelProgress.nextLevel, equals(UserLevel.pro));
      expect(profileState.goalProgressFraction, isNotNull);
      expect(profileState.currentWeightKg, equals(85.0));
    });

    test('10. AiState handles chat and configuration independently', () async {
      final settingsRepo = LocalSettingsRepository(storage: storage);
      final aiState = AiState(
        settingsRepository: settingsRepo,
        initialGeminiApiKey: 'test_key',
        initialGeminiModel: 'gemini-1.5-flash',
      );

      expect(aiState.chatMessages, isNotEmpty);
      expect(aiState.chatMessages.first.id, equals('welcome_msg'));

      await aiState.saveGeminiConfig(apiKey: 'new_gemini_key', model: 'gemini-2.0-flash');
      expect(aiState.geminiApiKey, equals('new_gemini_key'));
      expect(aiState.geminiModel, equals('gemini-2.0-flash'));

      aiState.clearChatMessages();
      expect(aiState.chatMessages.length, equals(1));
      expect(aiState.chatMessages.first.id, startsWith('welcome_'));
    });
  });

  group('GymBro Phase 04: Notification Optimization & Isolation Tests', () {
    test('11. Changes to hydration notify hydrationState without notifying workoutState', () async {
      int hydrationNotifications = 0;
      int workoutNotifications = 0;
      int nutritionNotifications = 0;

      appState.hydrationState.addListener(() {
        hydrationNotifications++;
      });
      appState.workoutState.addListener(() {
        workoutNotifications++;
      });
      appState.nutritionState.addListener(() {
        nutritionNotifications++;
      });

      // Log water directly via hydrationState
      await appState.hydrationState.logWater(
        250,
        dateString: appState.todayDateString,
      );

      // Hydration state must be notified
      expect(hydrationNotifications, greaterThan(0));
      // Workout state MUST NOT be notified (notification isolation!)
      expect(workoutNotifications, equals(0));
      // Nutrition state MUST NOT be notified
      expect(nutritionNotifications, equals(0));
    });

    test('12. Changes to workout notify workoutState without notifying hydrationState', () async {
      int hydrationNotifications = 0;
      int workoutNotifications = 0;

      appState.hydrationState.addListener(() {
        hydrationNotifications++;
      });
      appState.workoutState.addListener(() {
        workoutNotifications++;
      });

      // Create a workout plan via workoutState
      await appState.workoutState.createWorkoutPlan(
        titleFa: 'برنامه آزمایشی بهینه‌سازی ناتیفیکیشن',
        descriptionFa: 'بررسی عدم نشت ناتیفیکیشن به هیدراتاسیون',
      );

      // Workout state must be notified
      expect(workoutNotifications, greaterThan(0));
      // Hydration state MUST NOT be notified
      expect(hydrationNotifications, equals(0));
    });
  });

  group('GymBro Phase 04: Backward Compatibility & Full AppState Facade Tests', () {
    test('13. AppState exposes all existing public properties and delegates seamlessly', () async {
      expect(appState.workoutPlans, isNotEmpty);
      expect(appState.exercises, isNotEmpty);
      expect(appState.nutritionPlan, isNotNull);
      expect(appState.userProfile, isNotNull);
      expect(appState.todayDateString, isNotEmpty);
      expect(appState.selectedNutritionDateString, isNotEmpty);
      expect(appState.todayConsumedCalories, isA<int>());
      expect(appState.todayConsumedWaterMl, isA<int>());
      expect(appState.levelProgress, isNotNull);
    });

    test('14. AppState.refreshData synchronizes all sub-states in parallel', () async {
      await appState.refreshData();
      expect(appState.workoutPlans, isNotEmpty);
      expect(appState.exercises, isNotEmpty);
      expect(appState.userProfile, isNotNull);
      expect(appState.nutritionPlan, isNotNull);
      expect(appState.gyms, isNotEmpty);
      expect(appState.trainers, isNotEmpty);
    });
  });
}
