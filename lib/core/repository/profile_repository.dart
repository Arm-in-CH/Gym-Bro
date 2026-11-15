import '../../models/user_profile.dart';
import '../../models/body_analytics_models.dart';
import '../storage/local_storage_service.dart';

abstract class IProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<List<WeightRecord>> getWeightRecords();
  Future<void> saveWeightRecords(List<WeightRecord> records);
  Future<void> addWeightRecord(WeightRecord record);
  Future<void> deleteWeightRecord(String id);

  Future<List<BodyMeasurementRecord>> getBodyMeasurements();
  Future<void> saveBodyMeasurements(List<BodyMeasurementRecord> records);
  Future<void> addBodyMeasurement(BodyMeasurementRecord record);
  Future<void> deleteBodyMeasurement(String id);
}

class LocalProfileRepository implements IProfileRepository {
  final LocalStorageService storage;

  LocalProfileRepository({required this.storage});

  @override
  Future<UserProfile> getProfile() async {
    return storage.getProfile();
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await storage.saveProfile(profile);
  }

  @override
  Future<List<WeightRecord>> getWeightRecords() async {
    return storage.getWeightRecords();
  }

  @override
  Future<void> saveWeightRecords(List<WeightRecord> records) async {
    await storage.saveWeightRecords(records);
  }

  @override
  Future<void> addWeightRecord(WeightRecord record) async {
    await storage.addWeightRecord(record);
  }

  @override
  Future<void> deleteWeightRecord(String id) async {
    await storage.deleteWeightRecord(id);
  }

  @override
  Future<List<BodyMeasurementRecord>> getBodyMeasurements() async {
    return storage.getBodyMeasurements();
  }

  @override
  Future<void> saveBodyMeasurements(List<BodyMeasurementRecord> records) async {
    await storage.saveBodyMeasurements(records);
  }

  @override
  Future<void> addBodyMeasurement(BodyMeasurementRecord record) async {
    await storage.addBodyMeasurement(record);
  }

  @override
  Future<void> deleteBodyMeasurement(String id) async {
    await storage.deleteBodyMeasurement(id);
  }
}
