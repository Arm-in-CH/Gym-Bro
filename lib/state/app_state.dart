import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/storage/local_storage_service.dart';
import '../core/ai/openrouter_ai_service.dart';
import '../core/ai/gemini_service.dart';
import '../core/ai/ai_context_builder.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../models/workout_log.dart';
import '../models/nutrition_plan.dart';
import '../models/calorie_scan_log.dart';
import '../models/marketplace_models.dart';
import '../models/active_workout_progress.dart';
import '../models/timer_settings.dart';
import '../models/body_analytics_models.dart';
import '../models/nutrition_models.dart';
import '../core/repository/workout_repository.dart';
import '../core/repository/nutrition_repository.dart';
import '../core/repository/hydration_repository.dart';
import '../core/repository/profile_repository.dart';
import '../core/repository/settings_repository.dart';
import '../core/repository/marketplace_repository.dart';

import 'workout_state.dart';
import 'nutrition_state.dart';
import 'hydration_state.dart';
import 'profile_state.dart';
import 'ai_state.dart';

export 'workout_state.dart';
export 'nutrition_state.dart';
export 'hydration_state.dart';
export 'profile_state.dart';
export 'ai_state.dart';

/// AppState serves as the modular state aggregator and backward-compatible facade.
/// It delegates domain operations to dedicated, single-responsibility sub-controllers:
/// - [workoutState] for workout plans, execution, sets, timer, and history.
/// - [nutritionState] for meals, calories, macros, and food database.
/// - [hydrationState] for daily water intake and logging.
/// - [profileState] for user biometrics, body measurements, weight records, and progression.
/// - [aiState] for Gemini / OpenRouter AI chat, image vision, and configuration.
class AppState extends ChangeNotifier {
  final LocalStorageService storage;

  late final IWorkoutRepository workoutRepository;
  late final INutritionRepository nutritionRepository;
  late final IHydrationRepository hydrationRepository;
  late final IProfileRepository profileRepository;
  late final ISettingsRepository settingsRepository;
  late final IMarketplaceRepository marketplaceRepository;

  late final WorkoutState workoutState;
  late final NutritionState nutritionState;
  late final HydrationState hydrationState;
  late final ProfileState profileState;
  late final AiState aiState;

  // Marketplace lists
  List<Gym> gyms = [];
  List<Trainer> trainers = [];
  List<Booking> bookings = [];

  AppState({
    required this.storage,
    IWorkoutRepository? repository,
    INutritionRepository? nutritionRepo,
    IHydrationRepository? hydrationRepo,
    IProfileRepository? profileRepo,
    ISettingsRepository? settingsRepo,
    IMarketplaceRepository? marketplaceRepo,
  }) {
    // 1. Initialize repositories (using injected or default local repositories)
    workoutRepository = repository ?? LocalWorkoutRepository(storage: storage);
    nutritionRepository =
        nutritionRepo ?? LocalNutritionRepository(storage: storage);
    hydrationRepository =
        hydrationRepo ?? LocalHydrationRepository(storage: storage);
    profileRepository = profileRepo ?? LocalProfileRepository(storage: storage);
    settingsRepository =
        settingsRepo ?? LocalSettingsRepository(storage: storage);
    marketplaceRepository =
        marketplaceRepo ?? LocalMarketplaceRepository(storage: storage);

    // 2. Initialize modular state controllers with initial storage snapshot
    final initialProfile = storage.getProfile();
    final initialNutritionPlan = storage.getNutritionPlan();
    final initialExercises = storage.getExercises();
    final initialWorkoutPlans = storage.getWorkoutPlans();
    final initialWorkoutLogs = storage.getWorkoutLogs();
    final initialCalorieLogs = storage.getCalorieLogs();
    final initialWaterLogs = storage.getWaterLogs();
    final initialFavoriteFoods = storage.getFavoriteFoods();
    final initialWeightRecords = storage.getWeightRecords();
    final initialBodyMeasurements = storage.getBodyMeasurements();
    final initialTimerSettings = storage.getTimerSettings();
    final initialGeminiApiKey = storage.getGeminiApiKey();
    final initialGeminiModel = storage.getGeminiModel();
    final initialOpenRouterApiKey = storage.getApiKey();

    profileState = ProfileState(
      repository: profileRepository,
      initialProfile: initialProfile,
      initialWeightRecords: initialWeightRecords,
      initialBodyMeasurements: initialBodyMeasurements,
    );

    workoutState = WorkoutState(
      repository: workoutRepository,
      profileRepository: profileRepository,
      onWorkoutCompleted: (streak, _) async {
        await profileState.loadFromRepository();
      },
      initialExercises: initialExercises,
      initialWorkoutPlans: initialWorkoutPlans,
      initialWorkoutLogs: initialWorkoutLogs,
      initialTimerSettings: initialTimerSettings,
    );

    nutritionState = NutritionState(
      repository: nutritionRepository,
      initialNutritionPlan: initialNutritionPlan,
      initialCalorieLogs: initialCalorieLogs,
      initialFavoriteFoods: initialFavoriteFoods,
    );

    hydrationState = HydrationState(
      repository: hydrationRepository,
      getTargetWaterMl: () => nutritionState.nutritionPlan.targetWaterMl,
      initialWaterLogs: initialWaterLogs,
    );

    aiState = AiState(
      settingsRepository: settingsRepository,
      systemPromptBuilder: () => AiContextBuilder.buildSystemPrompt(this),
      initialGeminiApiKey: initialGeminiApiKey,
      initialGeminiModel: initialGeminiModel,
      initialOpenRouterApiKey: initialOpenRouterApiKey,
    );

    // Load marketplace data
    gyms = storage.getGyms();
    trainers = storage.getTrainers();
    bookings = storage.getBookings();

    // 3. Register listeners to propagate sub-controller changes to AppState listeners
    workoutState.addListener(notifyListeners);
    nutritionState.addListener(notifyListeners);
    hydrationState.addListener(notifyListeners);
    profileState.addListener(notifyListeners);
    aiState.addListener(notifyListeners);
  }

  @override
  void dispose() {
    workoutState.removeListener(notifyListeners);
    nutritionState.removeListener(notifyListeners);
    hydrationState.removeListener(notifyListeners);
    profileState.removeListener(notifyListeners);
    aiState.removeListener(notifyListeners);
    workoutState.dispose();
    nutritionState.dispose();
    hydrationState.dispose();
    profileState.dispose();
    aiState.dispose();
    super.dispose();
  }

  // --- REFRESH & SYNCHRONIZATION ---

  Future<void> refreshData() async {
    await Future.wait([
      workoutState.loadFromRepository(),
      nutritionState.loadFromRepository(),
      hydrationState.loadFromRepository(),
      profileState.loadFromRepository(),
      aiState.loadFromRepository(),
    ]);
    gyms = await marketplaceRepository.getGyms();
    trainers = await marketplaceRepository.getTrainers();
    bookings = await marketplaceRepository.getBookings();
    notifyListeners();
  }

  // --- AI SERVICES ---

  OpenRouterAiService get aiService => aiState.aiService;
  GeminiService get geminiService => aiState.geminiService;

  // --- WORKOUT STATE DELEGATES ---

  List<Exercise> get exercises => workoutState.exercises;
  set exercises(List<Exercise> val) => workoutState.exercises = val;

  List<WorkoutPlan> get workoutPlans => workoutState.workoutPlans;
  set workoutPlans(List<WorkoutPlan> val) => workoutState.workoutPlans = val;

  List<WorkoutLog> get workoutLogs => workoutState.workoutLogs;
  set workoutLogs(List<WorkoutLog> val) => workoutState.workoutLogs = val;

  TimerSettings get timerSettings => workoutState.timerSettings;
  set timerSettings(TimerSettings val) => workoutState.timerSettings = val;

  bool get isConvertingHome => workoutState.isConvertingHome;
  set isConvertingHome(bool val) => workoutState.isConvertingHome = val;

  bool get isCompletingWorkoutSession => workoutState.isCompletingWorkoutSession;

  Future<WorkoutPlan> convertGymPlanToHomePlan(String gymPlanId) =>
      workoutState.convertGymPlanToHomePlan(gymPlanId);

  Future<void> createWorkoutPlan({
    required String titleFa,
    String titleEn = '',
    required String descriptionFa,
    String splitType = 'Custom Split',
    bool isHomeWorkout = false,
    int daysPerWeek = 3,
    String difficulty = 'متوسط',
    List<WorkoutPlanExercise> exercises = const [],
  }) =>
      workoutState.createWorkoutPlan(
        titleFa: titleFa,
        titleEn: titleEn,
        descriptionFa: descriptionFa,
        splitType: splitType,
        isHomeWorkout: isHomeWorkout,
        daysPerWeek: daysPerWeek,
        difficulty: difficulty,
        exercises: exercises,
      );

  Future<void> updateWorkoutPlan(WorkoutPlan plan) =>
      workoutState.updateWorkoutPlan(plan);

  Future<void> deleteWorkoutPlan(String planId) =>
      workoutState.deleteWorkoutPlan(planId);

  Future<void> addExerciseToPlan({
    required String planId,
    required String exerciseId,
    required int dayOfWeek,
    required String dayNameFa,
    required int targetSets,
    required int targetReps,
    required double targetWeightKg,
    int restSeconds = 60,
  }) =>
      workoutState.addExerciseToPlan(
        planId: planId,
        exerciseId: exerciseId,
        dayOfWeek: dayOfWeek,
        dayNameFa: dayNameFa,
        targetSets: targetSets,
        targetReps: targetReps,
        targetWeightKg: targetWeightKg,
        restSeconds: restSeconds,
      );

  Future<void> removeExerciseFromPlan({
    required String planId,
    required String planExerciseId,
  }) =>
      workoutState.removeExerciseFromPlan(
        planId: planId,
        planExerciseId: planExerciseId,
      );

  Future<void> reorderPlanExercises({
    required String planId,
    required int dayOfWeek,
    required int oldIndex,
    required int newIndex,
  }) =>
      workoutState.reorderPlanExercises(
        planId: planId,
        dayOfWeek: dayOfWeek,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );

  Future<void> saveExercise(Exercise exercise) =>
      workoutState.saveExercise(exercise);

  Future<void> deleteExercise(String id) => workoutState.deleteExercise(id);

  Future<void> deleteWorkoutHistoryLog(String id) =>
      workoutState.deleteWorkoutHistoryLog(id);

  ActiveWorkoutProgress? getActiveWorkoutDraft(String planId) =>
      storage.getActiveWorkoutProgress(planId);

  Future<void> saveActiveWorkoutDraft(ActiveWorkoutProgress progress) =>
      workoutState.saveActiveWorkoutDraft(progress);

  Future<void> updateWorkoutPlanExerciseRest({
    required String planId,
    required String exercisePlanId,
    required int restSeconds,
  }) =>
      workoutState.updateWorkoutPlanExerciseRest(
        planId: planId,
        exercisePlanId: exercisePlanId,
        restSeconds: restSeconds,
      );

  Future<void> clearActiveWorkoutDraft(String planId) =>
      workoutState.clearActiveWorkoutDraft(planId);

  Future<void> updateTimerSettings(TimerSettings settings) =>
      workoutState.updateTimerSettings(settings);

  Future<ActiveWorkoutProgress> startWorkoutSession({
    required String planId,
    int selectedDay = 1,
  }) =>
      workoutState.startWorkoutSession(
        planId: planId,
        selectedDay: selectedDay,
      );

  Future<ActiveWorkoutProgress> addExerciseToActiveWorkout({
    required String planId,
    required WorkoutPlanExercise exercise,
  }) =>
      workoutState.addExerciseToActiveWorkout(
        planId: planId,
        exercise: exercise,
      );

  Future<ActiveWorkoutProgress> addSetToActiveExercise({
    required String planId,
    required String planExerciseId,
    int? targetReps,
    double? targetWeightKg,
  }) =>
      workoutState.addSetToActiveExercise(
        planId: planId,
        planExerciseId: planExerciseId,
        targetReps: targetReps,
        targetWeightKg: targetWeightKg,
      );

  Future<ActiveWorkoutProgress> editActiveSet({
    required String planId,
    required String planExerciseId,
    required int setNumber,
    int? actualReps,
    double? actualWeightKg,
    bool? isCompleted,
  }) =>
      workoutState.editActiveSet(
        planId: planId,
        planExerciseId: planExerciseId,
        setNumber: setNumber,
        actualReps: actualReps,
        actualWeightKg: actualWeightKg,
        isCompleted: isCompleted,
      );

  Future<ActiveWorkoutProgress> deleteSetFromActiveExercise({
    required String planId,
    required String planExerciseId,
    required int setNumber,
  }) =>
      workoutState.deleteSetFromActiveExercise(
        planId: planId,
        planExerciseId: planExerciseId,
        setNumber: setNumber,
      );

  Future<void> startRestTimer({int? seconds, String? exerciseName}) =>
      workoutState.startRestTimer(
        seconds: seconds,
        exerciseName: exerciseName,
      );

  Future<ActiveWorkoutProgress> pauseWorkoutSession(String planId) =>
      workoutState.pauseWorkoutSession(planId);

  Future<ActiveWorkoutProgress> resumeWorkoutSession(String planId) =>
      workoutState.resumeWorkoutSession(planId);

  Future<void> cancelWorkoutSession(String planId) =>
      workoutState.cancelWorkoutSession(planId);

  Future<WorkoutLog> completeWorkoutSession({
    required WorkoutPlan plan,
    required double totalVolumeKg,
    required int completedSets,
    required List<WorkoutSetLog> setLogs,
    required int durationMinutes,
  }) =>
      workoutState.completeWorkoutSession(
        plan: plan,
        totalVolumeKg: totalVolumeKg,
        completedSets: completedSets,
        setLogs: setLogs,
        durationMinutes: durationMinutes,
      );

  // --- NUTRITION STATE DELEGATES ---

  NutritionPlan get nutritionPlan => nutritionState.nutritionPlan;
  set nutritionPlan(NutritionPlan val) => nutritionState.nutritionPlan = val;

  List<CalorieScanLog> get calorieLogs => nutritionState.calorieLogs;
  set calorieLogs(List<CalorieScanLog> val) => nutritionState.calorieLogs = val;

  List<QuickFoodTemplate> get favoriteFoods => nutritionState.favoriteFoods;
  set favoriteFoods(List<QuickFoodTemplate> val) =>
      nutritionState.favoriteFoods = val;

  DateTime get selectedNutritionDate => nutritionState.selectedNutritionDate;
  set selectedNutritionDate(DateTime val) =>
      nutritionState.selectedNutritionDate = val;

  String get todayDateString =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get selectedNutritionDateString =>
      nutritionState.selectedNutritionDateString;

  void selectNutritionDate(DateTime date) =>
      nutritionState.selectNutritionDate(date);

  void selectPreviousNutritionDay() =>
      nutritionState.selectPreviousNutritionDay();

  void selectNextNutritionDay() => nutritionState.selectNextNutritionDay();

  void selectTodayNutrition() => nutritionState.selectTodayNutrition();

  List<CalorieScanLog> get selectedDateMeals =>
      nutritionState.selectedDateMeals;

  int get selectedConsumedCalories =>
      nutritionState.selectedConsumedCalories;

  double get selectedConsumedProtein =>
      nutritionState.selectedConsumedProtein;

  double get selectedConsumedCarbs => nutritionState.selectedConsumedCarbs;

  double get selectedConsumedFat => nutritionState.selectedConsumedFat;

  int get selectedRemainingCalories =>
      nutritionState.selectedRemainingCalories;

  bool get isSelectedDateOverLimit =>
      nutritionState.isSelectedDateOverLimit;

  int get selectedCalorieOverdraft =>
      nutritionState.selectedCalorieOverdraft;

  List<CalorieScanLog> getMealsByCategory(String category) =>
      nutritionState.getMealsByCategory(category);

  int getCategoryCalories(String category) =>
      nutritionState.getCategoryCalories(category);

  List<CalorieScanLog> get todayMeals => nutritionState.todayMeals;

  int get todayConsumedCalories => nutritionState.todayConsumedCalories;

  double get todayConsumedProtein => nutritionState.todayConsumedProtein;

  double get todayConsumedCarbs => nutritionState.todayConsumedCarbs;

  double get todayConsumedFat => nutritionState.todayConsumedFat;

  bool get isOverCalorieLimit => nutritionState.isOverCalorieLimit;

  int get calorieOverdraft => nutritionState.calorieOverdraft;

  List<DailyNutritionSummary> getPast7DaysSummaries([DateTime? refDate]) =>
      nutritionState.getPast7DaysSummaries(
        refDate: refDate,
        waterLogs: hydrationState.waterLogs,
      );

  List<DailyNutritionSummary> getPast30DaysSummaries([DateTime? refDate]) =>
      nutritionState.getPast30DaysSummaries(
        refDate: refDate,
        waterLogs: hydrationState.waterLogs,
      );

  Future<void> addFoodEntry(CalorieScanLog entry) =>
      nutritionState.addFoodEntry(entry);

  Future<void> updateFoodEntry(CalorieScanLog entry) =>
      nutritionState.updateFoodEntry(entry);

  Future<void> deleteFoodEntry(String id) =>
      nutritionState.deleteFoodEntry(id);

  Future<void> duplicateFoodEntry(CalorieScanLog entry, {String? targetDate}) =>
      nutritionState.duplicateFoodEntry(entry, targetDate: targetDate);

  Future<void> updateNutritionPlanGoals(NutritionPlan plan) =>
      nutritionState.updateNutritionPlanGoals(plan);

  Future<void> saveFavoriteFood(QuickFoodTemplate food) =>
      nutritionState.saveFavoriteFood(food);

  Future<void> deleteFavoriteFood(String id) =>
      nutritionState.deleteFavoriteFood(id);

  Future<void> addMealLog({
    required String foodName,
    required String mealType,
    required int calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required double portionG,
  }) =>
      nutritionState.addMealLog(
        foodName: foodName,
        mealType: mealType,
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        portionG: portionG,
      );

  Future<void> removeMealLog(String id) => nutritionState.removeMealLog(id);

  // --- HYDRATION STATE DELEGATES ---

  List<WaterLog> get waterLogs => hydrationState.waterLogs;
  set waterLogs(List<WaterLog> val) => hydrationState.waterLogs = val;

  int get todayConsumedWaterMl => hydrationState.todayConsumedWaterMl;

  List<WaterLog> get selectedDateWaterLogs =>
      hydrationState.getWaterLogsForDate(selectedNutritionDateString);

  int get selectedConsumedWaterMl =>
      hydrationState.getConsumedWaterMlForDate(selectedNutritionDateString);

  int get selectedRemainingWaterMl =>
      hydrationState.getRemainingWaterMlForDate(
        selectedNutritionDateString,
        nutritionPlan.targetWaterMl,
      );

  Future<void> logWater(int amountMl, {String? dateString}) =>
      hydrationState.logWater(
        amountMl,
        dateString: dateString ?? selectedNutritionDateString,
      );

  Future<void> undoWater(int? amountMl, {String? dateString}) =>
      hydrationState.undoWater(
        amountMl,
        dateString: dateString ?? selectedNutritionDateString,
      );

  WaterLog? getLastWaterLog({String? dateString}) =>
      hydrationState.getLastWaterLogForDate(dateString ?? selectedNutritionDateString);

  // --- PROFILE STATE DELEGATES ---

  UserProfile get userProfile => profileState.userProfile;
  set userProfile(UserProfile val) => profileState.userProfile = val;

  List<WeightRecord> get weightRecords => profileState.weightRecords;
  set weightRecords(List<WeightRecord> val) =>
      profileState.weightRecords = val;

  List<BodyMeasurementRecord> get bodyMeasurements =>
      profileState.bodyMeasurements;
  set bodyMeasurements(List<BodyMeasurementRecord> val) =>
      profileState.bodyMeasurements = val;

  LevelProgressInfo get levelProgress => profileState.levelProgress;

  WeightRecord? get latestWeightRecord => profileState.latestWeightRecord;

  BodyMeasurementRecord? get latestBodyMeasurement =>
      profileState.latestBodyMeasurement;

  double get initialWeightKg => profileState.initialWeightKg;

  double get currentWeightKg => profileState.currentWeightKg;

  double get totalWeightChangeKg => profileState.totalWeightChangeKg;

  double get targetWeightKg => profileState.targetWeightKg;

  double get weightToTargetKg => profileState.weightToTargetKg;

  double? get goalProgressFraction => profileState.goalProgressFraction;

  BmiCategory get bmiCategory => profileState.bmiCategory;

  Future<void> updateUserProfile(UserProfile profile) =>
      profileState.updateUserProfile(profile);

  Future<void> updateProfileMetrics({
    required double weightKg,
    required double heightCm,
    required String goal,
  }) =>
      profileState.updateProfileMetrics(
        weightKg: weightKg,
        heightCm: heightCm,
        goal: goal,
      );

  Future<void> addWeightRecord({
    required double weightKg,
    DateTime? date,
    String? note,
  }) =>
      profileState.addWeightRecord(
        weightKg: weightKg,
        date: date,
        note: note,
      );

  Future<void> deleteWeightRecord(String id) =>
      profileState.deleteWeightRecord(id);

  Future<void> addBodyMeasurement(BodyMeasurementRecord record) =>
      profileState.addBodyMeasurement(record);

  Future<void> deleteBodyMeasurement(String id) =>
      profileState.deleteBodyMeasurement(id);

  Future<void> updateFullProfile(UserProfile updated) =>
      profileState.updateFullProfile(updated);

  // --- AI STATE DELEGATES ---

  List<ChatMessage> get chatMessages => aiState.chatMessages;
  set chatMessages(List<ChatMessage> val) => aiState.chatMessages = val;

  bool get isAiLoading => aiState.isAiLoading;
  set isAiLoading(bool val) => aiState.isAiLoading = val;

  bool get isScanningFood => aiState.isScanningFood;
  set isScanningFood(bool val) => aiState.isScanningFood = val;

  String get geminiApiKey => aiState.geminiApiKey;
  set geminiApiKey(String val) => aiState.geminiApiKey = val;

  String get geminiModel => aiState.geminiModel;
  set geminiModel(String val) => aiState.geminiModel = val;

  String get openRouterApiKey => aiState.openRouterApiKey;
  set openRouterApiKey(String val) => aiState.openRouterApiKey = val;

  Future<void> saveGeminiConfig({
    required String apiKey,
    required String model,
  }) =>
      aiState.saveGeminiConfig(apiKey: apiKey, model: model);

  Future<void> updateApiKey(String key) => aiState.updateApiKey(key);

  Future<bool> testGeminiConnection({
    required String apiKey,
    required String model,
  }) =>
      aiState.testGeminiConnection(apiKey: apiKey, model: model);

  Future<Map<String, dynamic>> scanFoodWithGeminiVision(
    List<int> imageBytes, {
    String mimeType = 'image/jpeg',
  }) =>
      aiState.scanFoodWithGeminiVision(imageBytes, mimeType: mimeType);

  void clearChatMessages() => aiState.clearChatMessages();

  Future<void> sendAiMessage(String userText) => aiState.sendAiMessage(
        userText,
        systemPrompt: AiContextBuilder.buildSystemPrompt(this),
      );
}
