import '../../models/nutrition_models.dart';
import '../storage/local_storage_service.dart';

abstract class IHydrationRepository {
  Future<List<WaterLog>> getWaterLogs();
  Future<void> saveWaterLogs(List<WaterLog> logs);
  Future<void> saveWaterLog(WaterLog log);
  Future<void> deleteWaterLog(String id);
}

class LocalHydrationRepository implements IHydrationRepository {
  final LocalStorageService storage;

  LocalHydrationRepository({required this.storage});

  @override
  Future<List<WaterLog>> getWaterLogs() async {
    return storage.getWaterLogs();
  }

  @override
  Future<void> saveWaterLogs(List<WaterLog> logs) async {
    await storage.saveWaterLogs(logs);
  }

  @override
  Future<void> saveWaterLog(WaterLog log) async {
    await storage.saveWaterLog(log);
  }

  @override
  Future<void> deleteWaterLog(String id) async {
    await storage.deleteWaterLog(id);
  }
}
