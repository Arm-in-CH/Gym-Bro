import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/localization/persian_utils.dart';
import '../core/repository/nutrition_repository.dart';
import '../core/storage/database_seeder.dart';
import '../core/storage/id_generator.dart';
import '../models/calorie_scan_log.dart';
import '../models/nutrition_models.dart';
import '../models/nutrition_plan.dart';

class NutritionState extends ChangeNotifier {
  final INutritionRepository repository;

  late NutritionPlan nutritionPlan;
  List<CalorieScanLog> calorieLogs = [];
  List<QuickFoodTemplate> favoriteFoods = [];
  DateTime selectedNutritionDate = DateTime.now();

  NutritionState({
    required this.repository,
    NutritionPlan? initialNutritionPlan,
    List<CalorieScanLog>? initialCalorieLogs,
    List<QuickFoodTemplate>? initialFavoriteFoods,
    DateTime? initialDate,
  }) {
    nutritionPlan =
        initialNutritionPlan ?? DatabaseSeeder.defaultNutritionPlan;
    if (initialCalorieLogs != null) calorieLogs = initialCalorieLogs;
    if (initialFavoriteFoods != null) favoriteFoods = initialFavoriteFoods;
    if (initialDate != null) selectedNutritionDate = initialDate;
  }

  String get todayDateString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadFromRepository() async {
    nutritionPlan = await repository.getNutritionPlan();
    calorieLogs = await repository.getCalorieLogs();
    favoriteFoods = await repository.getFavoriteFoods();
    notifyListeners();
  }

  // --- DATE NAVIGATION ---

  String get selectedNutritionDateString =>
      PersianUtils.toDateString(selectedNutritionDate);

  void selectNutritionDate(DateTime date) {
    selectedNutritionDate = date;
    notifyListeners();
  }

  void selectPreviousNutritionDay() {
    selectedNutritionDate =
        selectedNutritionDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void selectNextNutritionDay() {
    selectedNutritionDate =
        selectedNutritionDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void selectTodayNutrition() {
    selectedNutritionDate = DateTime.now();
    notifyListeners();
  }

  // --- SELECTED DATE QUERIES ---

  List<CalorieScanLog> get selectedDateMeals =>
      calorieLogs.where((l) => l.dateString == selectedNutritionDateString).toList();

  int get selectedConsumedCalories =>
      selectedDateMeals.fold(0, (sum, item) => sum + item.calories);

  double get selectedConsumedProtein =>
      selectedDateMeals.fold(0.0, (sum, item) => sum + item.proteinG);

  double get selectedConsumedCarbs =>
      selectedDateMeals.fold(0.0, (sum, item) => sum + item.carbsG);

  double get selectedConsumedFat =>
      selectedDateMeals.fold(0.0, (sum, item) => sum + item.fatG);

  int get selectedRemainingCalories =>
      nutritionPlan.dailyCalories - selectedConsumedCalories;

  bool get isSelectedDateOverLimit =>
      selectedConsumedCalories > nutritionPlan.dailyCalories;

  int get selectedCalorieOverdraft => isSelectedDateOverLimit
      ? selectedConsumedCalories - nutritionPlan.dailyCalories
      : 0;

  List<CalorieScanLog> getMealsByCategory(String category) =>
      selectedDateMeals.where((m) => m.mealType == category).toList();

  int getCategoryCalories(String category) =>
      getMealsByCategory(category).fold(0, (sum, m) => sum + m.calories);

  // --- TODAY BACKWARD COMPATIBILITY GETTERS ---

  List<CalorieScanLog> get todayMeals =>
      calorieLogs.where((l) => l.dateString == todayDateString).toList();

  int get todayConsumedCalories =>
      todayMeals.fold(0, (sum, item) => sum + item.calories);

  double get todayConsumedProtein =>
      todayMeals.fold(0.0, (sum, item) => sum + item.proteinG);

  double get todayConsumedCarbs =>
      todayMeals.fold(0.0, (sum, item) => sum + item.carbsG);

  double get todayConsumedFat =>
      todayMeals.fold(0.0, (sum, item) => sum + item.fatG);

  bool get isOverCalorieLimit =>
      todayConsumedCalories > nutritionPlan.dailyCalories;

  int get calorieOverdraft => isOverCalorieLimit
      ? todayConsumedCalories - nutritionPlan.dailyCalories
      : 0;

  // --- SUMMARIES ---

  List<DailyNutritionSummary> getPast7DaysSummaries({
    DateTime? refDate,
    List<WaterLog> waterLogs = const [],
  }) {
    final baseDate = refDate ?? selectedNutritionDate;
    final List<DailyNutritionSummary> summaries = [];
    for (int i = 6; i >= 0; i--) {
      final date = baseDate.subtract(Duration(days: i));
      final dateStr = PersianUtils.toDateString(date);
      final dayMeals = calorieLogs.where((l) => l.dateString == dateStr).toList();
      final dayWater = waterLogs.where((w) => w.dateString == dateStr).toList();

      summaries.add(DailyNutritionSummary(
        dateString: dateStr,
        dateTime: date,
        totalCalories: dayMeals.fold(0, (s, m) => s + m.calories),
        targetCalories: nutritionPlan.dailyCalories,
        totalProtein: dayMeals.fold(0.0, (s, m) => s + m.proteinG),
        totalCarbs: dayMeals.fold(0.0, (s, m) => s + m.carbsG),
        totalFat: dayMeals.fold(0.0, (s, m) => s + m.fatG),
        totalWaterMl: dayWater.fold(0, (s, w) => s + w.amountMl),
        targetWaterMl: nutritionPlan.targetWaterMl,
        mealsCount: dayMeals.length,
      ));
    }
    return summaries;
  }

  List<DailyNutritionSummary> getPast30DaysSummaries({
    DateTime? refDate,
    List<WaterLog> waterLogs = const [],
  }) {
    final baseDate = refDate ?? selectedNutritionDate;
    final List<DailyNutritionSummary> summaries = [];
    for (int i = 29; i >= 0; i--) {
      final date = baseDate.subtract(Duration(days: i));
      final dateStr = PersianUtils.toDateString(date);
      final dayMeals = calorieLogs.where((l) => l.dateString == dateStr).toList();
      final dayWater = waterLogs.where((w) => w.dateString == dateStr).toList();

      summaries.add(DailyNutritionSummary(
        dateString: dateStr,
        dateTime: date,
        totalCalories: dayMeals.fold(0, (s, m) => s + m.calories),
        targetCalories: nutritionPlan.dailyCalories,
        totalProtein: dayMeals.fold(0.0, (s, m) => s + m.proteinG),
        totalCarbs: dayMeals.fold(0.0, (s, m) => s + m.carbsG),
        totalFat: dayMeals.fold(0.0, (s, m) => s + m.fatG),
        totalWaterMl: dayWater.fold(0, (s, w) => s + w.amountMl),
        targetWaterMl: nutritionPlan.targetWaterMl,
        mealsCount: dayMeals.length,
      ));
    }
    return summaries;
  }

  // --- MUTATIONS ---

  Future<void> addFoodEntry(CalorieScanLog entry) async {
    await repository.saveCalorieLog(entry);
    calorieLogs = await repository.getCalorieLogs();
    notifyListeners();
  }

  Future<void> updateFoodEntry(CalorieScanLog entry) async {
    await repository.updateCalorieLog(entry);
    calorieLogs = await repository.getCalorieLogs();
    notifyListeners();
  }

  Future<void> deleteFoodEntry(String id) async {
    await repository.deleteCalorieLog(id);
    calorieLogs = await repository.getCalorieLogs();
    notifyListeners();
  }

  Future<void> duplicateFoodEntry(CalorieScanLog entry, {String? targetDate}) async {
    final date = targetDate ?? selectedNutritionDateString;
    final duplicated = entry.copyWith(
      id: IdGenerator.generate('meal'),
      dateString: date,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await repository.saveCalorieLog(duplicated);
    calorieLogs = await repository.getCalorieLogs();
    notifyListeners();
  }

  Future<void> updateNutritionPlanGoals(NutritionPlan plan) async {
    nutritionPlan = plan;
    await repository.saveNutritionPlan(plan);
    notifyListeners();
  }

  Future<void> saveFavoriteFood(QuickFoodTemplate food) async {
    await repository.saveFavoriteFood(food);
    favoriteFoods = await repository.getFavoriteFoods();
    notifyListeners();
  }

  Future<void> deleteFavoriteFood(String id) async {
    await repository.deleteFavoriteFood(id);
    favoriteFoods = await repository.getFavoriteFoods();
    notifyListeners();
  }

  Future<void> addMealLog({
    required String foodName,
    required String mealType,
    required int calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required double portionG,
  }) async {
    final newLog = CalorieScanLog(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      foodName: foodName,
      mealType: mealType,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      portionG: portionG,
      dateString: todayDateString,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await repository.saveCalorieLog(newLog);
    calorieLogs = await repository.getCalorieLogs();
    notifyListeners();
  }

  Future<void> removeMealLog(String id) async {
    await repository.deleteCalorieLog(id);
    calorieLogs = await repository.getCalorieLogs();
    notifyListeners();
  }
}
