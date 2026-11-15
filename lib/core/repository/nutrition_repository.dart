import '../../models/nutrition_plan.dart';
import '../../models/calorie_scan_log.dart';
import '../../models/nutrition_models.dart';
import '../storage/local_storage_service.dart';

abstract class INutritionRepository {
  Future<NutritionPlan> getNutritionPlan();
  Future<void> saveNutritionPlan(NutritionPlan plan);

  Future<List<CalorieScanLog>> getCalorieLogs();
  Future<void> saveCalorieLogs(List<CalorieScanLog> logs);
  Future<void> saveCalorieLog(CalorieScanLog log);
  Future<void> updateCalorieLog(CalorieScanLog log);
  Future<void> deleteCalorieLog(String id);

  Future<List<QuickFoodTemplate>> getFavoriteFoods();
  Future<void> saveFavoriteFoods(List<QuickFoodTemplate> foods);
  Future<void> saveFavoriteFood(QuickFoodTemplate food);
  Future<void> deleteFavoriteFood(String id);
}

class LocalNutritionRepository implements INutritionRepository {
  final LocalStorageService storage;

  LocalNutritionRepository({required this.storage});

  @override
  Future<NutritionPlan> getNutritionPlan() async {
    return storage.getNutritionPlan();
  }

  @override
  Future<void> saveNutritionPlan(NutritionPlan plan) async {
    await storage.saveNutritionPlan(plan);
  }

  @override
  Future<List<CalorieScanLog>> getCalorieLogs() async {
    return storage.getCalorieLogs();
  }

  @override
  Future<void> saveCalorieLogs(List<CalorieScanLog> logs) async {
    await storage.saveCalorieLogs(logs);
  }

  @override
  Future<void> saveCalorieLog(CalorieScanLog log) async {
    await storage.saveCalorieLog(log);
  }

  @override
  Future<void> updateCalorieLog(CalorieScanLog log) async {
    await storage.updateCalorieLog(log);
  }

  @override
  Future<void> deleteCalorieLog(String id) async {
    await storage.deleteCalorieLog(id);
  }

  @override
  Future<List<QuickFoodTemplate>> getFavoriteFoods() async {
    return storage.getFavoriteFoods();
  }

  @override
  Future<void> saveFavoriteFoods(List<QuickFoodTemplate> foods) async {
    await storage.saveFavoriteFoods(foods);
  }

  @override
  Future<void> saveFavoriteFood(QuickFoodTemplate food) async {
    await storage.saveFavoriteFood(food);
  }

  @override
  Future<void> deleteFavoriteFood(String id) async {
    await storage.deleteFavoriteFood(id);
  }
}
